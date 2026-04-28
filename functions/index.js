const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const { onRequest } = require("firebase-functions/v2/https");
const { PubSub } = require("@google-cloud/pubsub");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const admin = require("firebase-admin");

admin.initializeApp();

const GEMINI_KEY = defineSecret("GEMINI_KEY");

// ─────────────────────────────────────────────
// FUNCTION 1: Process Crisis Event (Pub/Sub)
// ─────────────────────────────────────────────
exports.processCrisisEvent = onMessagePublished(
  {
    topic: "crisis-events",
    secrets: [GEMINI_KEY],
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (event) => {
    console.log("🚨 Crisis event received");

    // STEP 1: Decode Pub/Sub message safely
    let crisis;
    try {
      const raw = Buffer.from(event.data.message.data, "base64").toString("utf-8");
      crisis = JSON.parse(raw);
      console.log("✅ Crisis data parsed:", crisis);
    } catch (err) {
      console.error("❌ Failed to parse message:", err);
      return null; // Exit gracefully
    }

    const genAI = new GoogleGenerativeAI(GEMINI_KEY.value());
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-pro" });

    // STEP 2: Classify with Gemini — with fallback
    let classification;
    try {
      const classifyResult = await model.generateContent(`
        You are a hotel crisis classifier AI.
        Sensor data: ${JSON.stringify(crisis)}
        Return ONLY valid JSON, no markdown, no explanation:
        {
          "crisis_type": "cardiac_arrest or fire or security or flood or elevator or guest_sos",
          "severity": <1-5>,
          "protocol": "<step by step response>",
          "staff_roles_needed": ["first_aider"],
          "zone_action": "evacuate or lockdown or monitor or assist",
          "estimated_response_time_seconds": <number>
        }
      `);
      const cleaned = classifyResult.response
        .text()
        .trim()
        .replace(/```json|```/g, "")
        .trim();
      classification = JSON.parse(cleaned);
      console.log("✅ Classification done:", classification);
    } catch (err) {
      console.error("❌ Gemini classification failed, using fallback:", err);
      // Fallback so system never stops
      classification = {
        crisis_type: crisis.type || "unknown",
        severity: 3,
        protocol: "Follow standard emergency protocol. Contact manager immediately.",
        staff_roles_needed: ["manager"],
        zone_action: "monitor",
        estimated_response_time_seconds: 120,
      };
    }

    // STEP 3: Save incident to Firebase
    let incidentId;
    try {
      const incidentRef = admin.database().ref("incidents").push();
      incidentId = incidentRef.key;
      await incidentRef.set({
        ...crisis,
        ...classification,
        status: "active",
        timestamp: Date.now(),
        incidentId,
        brief_text: null,
        brief_audio_url: null,
        translations: null,
        assigned_staff: [],
      });
      console.log(`✅ Incident saved: ${incidentId}`);
    } catch (err) {
      console.error("❌ Firebase write failed:", err);
      return null;
    }

    // Update zone status
    try {
      if (crisis.floor !== undefined) {
        await admin.database().ref(`zones/floor_${crisis.floor}`).update({
          status:
            classification.zone_action === "evacuate" ? "emergency" :
            classification.zone_action === "lockdown" ? "lockdown" : "watch",
        });
        console.log(`✅ Zone floor_${crisis.floor} updated`);
      }
    } catch (err) {
      console.error("❌ Zone update failed:", err);
    }

    // STEP 4: Generate 911 Brief — with fallback
    let briefText = "";
    try {
      const briefResult = await model.generateContent(`
        You are an emergency dispatcher.
        Generate a 911 brief in UNDER 60 words.
        Incident: ${JSON.stringify({ ...crisis, ...classification })}
        Format: "Location: [floor/room]. Incident: [type]. Severity: [1-5].
        People present: [estimated]. Access route: [best entry]. Special notes: [hazards]."
        Be factual and clear. No filler words.
      `);
      briefText = briefResult.response.text().trim();
      await admin.database().ref(`incidents/${incidentId}`).update({ brief_text: briefText });
      console.log("✅ 911 Brief saved");
    } catch (err) {
      console.error("❌ Brief generation failed:", err);
      briefText = `Emergency at floor ${crisis.floor}. Type: ${classification.crisis_type}. Severity ${classification.severity}. Respond immediately.`;
      // Still save the fallback brief
      try {
        await admin.database().ref(`incidents/${incidentId}`).update({ brief_text: briefText });
      } catch (e) {
        console.error("❌ Could not save fallback brief:", e);
      }
    }

    // STEP 5: Text-to-Speech → MP3 — with fallback
    try {
      const textToSpeech = require("@google-cloud/text-to-speech");
      const { Storage } = require("@google-cloud/storage");

      const ttsClient = new textToSpeech.TextToSpeechClient();
      const storageClient = new Storage();

      const [ttsResponse] = await ttsClient.synthesizeSpeech({
        input: { text: briefText },
        voice: { languageCode: "en-US", name: "en-US-Neural2-D" },
        audioConfig: { audioEncoding: "MP3" },
      });

      const bucket = storageClient.bucket("safehaven-2026-audio");
      const file = bucket.file(`briefs/${incidentId}.mp3`);
      await file.save(ttsResponse.audioContent, {
        metadata: { contentType: "audio/mpeg" },
        public: true,
      });

      const audioUrl = `https://storage.googleapis.com/safehaven-2026-audio/briefs/${incidentId}.mp3`;
      await admin.database().ref(`incidents/${incidentId}`).update({ brief_audio_url: audioUrl });
      console.log("✅ Audio saved:", audioUrl);
    } catch (err) {
      console.error("❌ Text-to-Speech failed (non-critical, continuing):", err);
      // Not fatal — system continues without audio
    }

    // STEP 6: Multilingual Translations — with fallback
    await new Promise(resolve => setTimeout(resolve, 2000));
    try {
      const alertMessage =
        "Help is on the way. Please stay calm. Staff will reach you in 90 seconds. Do not use elevators.";
      const translateResult = await model.generateContent(`
        Translate this emergency message into these languages.
        Message: "${alertMessage}"
        Return ONLY valid JSON, no markdown:
        {
          "en": "${alertMessage}",
          "hi": "<Hindi translation>",
          "fr": "<French translation>",
          "ja": "<Japanese translation>",
          "ar": "<Arabic translation>",
          "es": "<Spanish translation>"
        }
      `);
      const cleanedT = translateResult.response
        .text()
        .trim()
        .replace(/```json|```/g, "")
        .trim();
      const translations = JSON.parse(cleanedT);
      await admin.database().ref(`incidents/${incidentId}`).update({ translations });
      console.log("✅ Translations saved");
    } catch (err) {
      console.error("❌ Translation failed (non-critical, continuing):", err);
      // Save fallback translations
      try {
        await admin.database().ref(`incidents/${incidentId}`).update({
          translations: {
            en: "Help is on the way. Please stay calm.",
            hi: "मदद आ रही है। कृपया शांत रहें।",
            fr: "Les secours arrivent. Restez calme.",
            ja: "助けが来ています。落ち着いてください。",
            ar: "المساعدة في الطريق. يرجى البقاء هادئاً.",
            es: "La ayuda está en camino. Por favor mantenga la calma.",
          },
        });
      } catch (e) {
        console.error("❌ Could not save fallback translations:", e);
      }
    }

    console.log(`🎉 Pipeline complete for incident ${incidentId}`);
    return null;
  }
);

// ─────────────────────────────────────────────
// FUNCTION 2 & 3: Staff Assignment (from assignStaff.js)
// ─────────────────────────────────────────────
const { assignStaffOnIncident, releaseStaffOnResolve } = require("./assignStaff");
exports.assignStaffOnIncident = assignStaffOnIncident;
exports.releaseStaffOnResolve = releaseStaffOnResolve;

// ─────────────────────────────────────────────
// FUNCTION 4: HTTP Trigger (for Kashika's buttons)
// ─────────────────────────────────────────────
exports.triggerIncident = onRequest(
  { cors: true, region: "us-central1" },
  async (req, res) => {
    try {
      const pubsub = new PubSub();
      const data = Buffer.from(JSON.stringify(req.body));
      await pubsub.topic("crisis-events").publish(data);
      console.log("✅ Incident published to Pub/Sub:", req.body);
      res.json({ success: true, message: "Incident triggered" });
    } catch (err) {
      console.error("❌ triggerIncident failed:", err);
      res.status(500).json({ success: false, error: err.message });
    }
  }
);