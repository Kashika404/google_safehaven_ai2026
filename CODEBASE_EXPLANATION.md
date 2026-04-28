# SafeHaven Dashboard - Complete Codebase Explanation

## 📋 Project Overview

**SafeHaven** is a Flutter-based emergency response dashboard for hotels/hospitals. It allows staff to:
- Simulate and track emergency incidents (Medical, Fire, Security, SOS)
- View real-time incident data from Firebase
- Get AI-powered incident reports using Google Gemini API
- Monitor incident statistics (Critical, Total, Resolved)

---

## 🏗️ Architecture & Tech Stack

### Technologies Used:
- **Framework**: Flutter (Dart)
- **Backend**: Firebase Realtime Database
- **AI**: Google Gemini API 2.0 Flash
- **HTTP**: http package for API calls
- **Environment**: flutter_dotenv for secure API key management

### Project Structure:
```
lib/
├── main.dart                           # App entry point & initialization
├── firebase_options.dart               # Firebase configuration
├── constants/
│   └── app_colors.dart                # Color theme definitions
├── models/
│   └── incident.dart                  # Data model for incidents
├── services/
│   ├── firebase_service.dart          # Firebase Realtime DB operations
│   └── gemini_service.dart            # Google Gemini API integration
├── screens/
│   └── dashboard/
│       └── dashboard_screen.dart       # Main UI screen
└── widgets/
    ├── incident_card.dart             # Individual incident display
    ├── ai_report_card.dart            # AI report display
    ├── sim_button.dart                # Simulation buttons
    └── stat_card.dart                 # Statistics cards
```

---

## 🔄 Complete Application Flow

### **STEP 1: Application Initialization** (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();                              // Load .env file with API keys
  await Firebase.initializeApp(...)                 // Initialize Firebase
  runApp(const SafeHavenApp());                     // Run Flutter app
}
```

**What happens:**
1. Ensures Flutter binding is initialized
2. Loads environment variables from `.env` file (API keys, credentials)
3. Initializes Firebase with platform-specific options
4. Launches the SafeHavenApp widget

---

### **STEP 2: Theme & UI Setup** (`SafeHavenApp`)

```dart
class SafeHavenApp extends StatelessWidget {
  MaterialApp(
    title: 'SafeHaven',
    theme: ThemeData.dark(),              // Dark theme
    home: const DashboardScreen(),        // Set home to dashboard
  )
}
```

**What happens:**
- Sets up Material Design with dark theme
- Navigates to `DashboardScreen` as the main interface

---

### **STEP 3: Dashboard Screen** (`dashboard_screen.dart`)

This is the **main UI** with 3 key components:

#### **Component 1: Navigation Bar**
- Shows "🛡️ SAFEHAVEN COMMAND" title
- Green "LIVE SYSTEM" indicator

#### **Component 2: Statistics Row**
```
┌─────────────┐  ┌──────────┐  ┌──────────────┐
│   🚨 CRIT   │  │⚡ TOTAL  │  │  ✅ RESOLVED │
│      2      │  │    2     │  │       0      │
└─────────────┘  └──────────┘  └──────────────┘
```
- Displays incident counts from Firebase
- Updates in real-time via `StreamBuilder`

#### **Component 3: Main Layout (Two-Column)**

**LEFT SIDE: Live Incidents Feed**
- Lists all incidents from Firebase
- Shows as `ListView` of `IncidentCard` widgets
- Real-time updates via Firebase stream

**RIGHT SIDE: Incident Simulator Panel**
- 4 buttons to trigger incidents:
  - 🚨 Medical Emergency (Room 204)
  - 🔥 Fire Alert (Floor 3 Kitchen)
  - 🔒 Security Threat (Main Lobby)
  - 🆘 Guest SOS (Room 101)

---

### **STEP 4: Triggering an Incident**

**User Action → Incident Creation:**

```
User clicks "🚨 Medical Emergency"
    ↓
_triggerIncident('Medical', 'Room 204')
    ↓
FirebaseService.addIncident(type, location)
```

**In `FirebaseService.addIncident()`:**

```dart
Future<String> addIncident(String type, String location) async {
  // 1. Create new incident reference in Firebase
  final ref = _incidentsRef.push();
  final id = ref.key ?? '';

  // 2. Write incident data to Firebase
  await ref.set({
    'type': type,
    'location': location,
    'status': 'active',
    'timestamp': DateTime.now().toIso8601String(),
    'aiReport': '⏳ Generating AI report...',        // Placeholder
  });

  // 3. Trigger AI report generation (background)
  GeminiService.generateIncidentReport(type: type, location: location)
    .then((report) {
      updateAiReport(id, report);                   // Update once ready
    });

  return id;
}
```

**What happens:**
1. Creates a new incident node in Firebase Realtime Database
2. Sets initial status to "active" with timestamp
3. Shows placeholder "⏳ Generating AI report..."
4. Calls Gemini API in background to generate AI report
5. Updates Firebase with the AI report when ready

---

### **STEP 5: Firebase Real-time Sync** 

**Data Model:** `Incident` class

```dart
class Incident {
  final String id;              // Unique identifier
  final String type;            // 'Medical', 'Fire', 'Security', 'SOS'
  final String location;        // Where it happened
  final String status;          // 'active' or 'resolved'
  final String timestamp;       // ISO 8601 format
  final String? aiReport;       // AI-generated response (nullable)
  
  String get emoji {            // Returns appropriate emoji for type
    switch (type) {
      case 'Medical': return '🚨';
      case 'Fire': return '🔥';
      // ...
    }
  }
}
```

**Firebase Realtime Database Structure:**
```
incidents/
  ├─ -NK_a1b2c3d4e5f6/ (auto-generated ID)
  │  ├─ type: "Medical"
  │  ├─ location: "Room 204"
  │  ├─ status: "active"
  │  ├─ timestamp: "2025-04-21T15:30:45.123Z"
  │  └─ aiReport: "SITUATION: Patient experiencing chest pain..."
  │
  └─ -NK_x9y8z7w6v5u/ (another incident)
     └─ ...
```

**Real-time Stream in Dashboard:**

```dart
StreamBuilder<List<Incident>>(
  stream: _firebaseService.incidentsStream,  // Listen to changes
  builder: (context, snapshot) {
    final incidents = snapshot.data ?? [];
    // Rebuild UI whenever Firebase data changes
  }
)
```

The `StreamBuilder` automatically rebuilds the UI when:
- New incident is added
- Existing incident is updated (AI report arrives)
- Incident status changes

---

### **STEP 6: AI Report Generation** (`gemini_service.dart`)

**Background Process:**

```
addIncident() called
    ↓
GeminiService.generateIncidentReport()
    ↓
HTTP POST to Google Gemini API
    ↓
API returns AI-generated report
    ↓
updateAiReport() updates Firebase
    ↓
StreamBuilder detects change
    ↓
UI refreshes with report
```

**API Call Details:**

```dart
static Future<String> generateIncidentReport({
  required String type,
  required String location,
}) async {
  
  // 1. Create prompt for Gemini
  final prompt = '''
You are an emergency response AI for SafeHaven hotel safety system.
Generate a brief incident report in under 60 words.

Incident: $type emergency at $location
Format exactly like this:
SITUATION: [one sentence]
ACTION: [two immediate steps]
PRIORITY: CRITICAL
ETA: 3 minutes
  ''';

  // 2. Send to Gemini API
  final uri = Uri.parse('$_url?key=$_apiKey');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [{
        'parts': [{'text': prompt}]
      }],
      'generationConfig': {
        'temperature': 0.3,           // Lower = more deterministic
        'maxOutputTokens': 120        // Limit response length
      }
    }),
  );

  // 3. Parse response
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  } else {
    return 'Error ${response.statusCode}';
  }
}
```

**Gemini API Flow:**
1. Sends structured prompt with incident details
2. API generates contextual emergency response
3. Response includes SITUATION, ACTION, PRIORITY, ETA
4. Response is returned and stored in Firebase
5. UI updates automatically via StreamBuilder

---

### **STEP 7: Displaying Incidents** (`incident_card.dart`)

**Card Structure:**
```
┌─────────────────────────────────────────┐
│ 🚨 Medical Emergency          [ACTIVE]  │
│ 📍 Room 204                             │
│ 🕐 2025-04-21 15:30:45                  │
├─────────────────────────────────────────┤
│ 🤖 AI INCIDENT REPORT                   │
│ SITUATION: Patient experiencing chest.. │
│ ACTION: Contact cardiology, Prepare...  │
│ PRIORITY: CRITICAL                      │
│ ETA: 3 minutes                          │
└─────────────────────────────────────────┘
```

**Color Coding:**
- Red border (🔴) → Medical
- Orange border (🟠) → Fire  
- Blue border (🔵) → Security
- Purple border (🟣) → SOS

**Status Badge:**
- Red badge → "ACTIVE"
- Green badge → "RESOLVED"

---

### **STEP 8: Incident Resolution Flow**

**Option 1: Mark as Resolved (Backend)**
```dart
Future<void> resolveIncident(String id) async {
  await _incidentsRef.child(id).update({'status': 'resolved'});
}
```

**Option 2: Delete Incident**
```dart
// Can be implemented to remove resolved incidents
```

When status changes:
1. Firebase updates the incident
2. StreamBuilder detects change
3. UI re-renders with green "RESOLVED" badge
4. Incident moves to resolved counter

---

## 🔐 Security Architecture

### **Environment Variables (.env)**
```
GEMINI_API_KEY=AIzaSyCCk9D0TBIygHSwn862fgYDHIWm9xKccC4
```

**Why .env?**
- ✅ API key NOT hardcoded in source
- ✅ .env file added to .gitignore
- ✅ Loaded at runtime via flutter_dotenv
- ✅ Can be rotated without code changes

### **Firebase Security Rules**
- Uses Firebase Realtime Database
- Can implement rules to restrict who can:
  - Read incidents
  - Create new incidents
  - Modify incidents

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE                           │
│  ┌──────────────────┐           ┌──────────────────┐        │
│  │   Stat Cards     │           │  Incident Cards  │        │
│  │ (Critical/Total) │           │  (Live Feed)     │        │
│  └──────────────────┘           └──────────────────┘        │
│         ↓                               ↓                    │
│      Reads                         Displays                 │
└─────────────────────────────────────────────────────────────┘
                          ↑
                          │
          StreamBuilder (Real-time)
                          │
┌─────────────────────────────────────────────────────────────┐
│            FIREBASE REALTIME DATABASE                       │
│  incidents/                                                 │
│    ├─ incident_1 {type, location, status, timestamp}       │
│    └─ incident_2 {type, location, status, timestamp}       │
└─────────────────────────────────────────────────────────────┘
          ↑                                  ↑
          │                                  │
      Write                          Generate AI Report
          │                                  │
┌─────────────────────┐       ┌──────────────────────┐
│  Simulator Buttons  │       │  Gemini AI Service   │
│  (Trigger Incident) │       │  (HTTP POST)         │
└─────────────────────┘       └──────────────────────┘
```

---

## 🎯 Key Features Implemented

✅ **Real-time Incident Tracking** - StreamBuilder syncs with Firebase
✅ **AI-Powered Reports** - Google Gemini generates contextual responses
✅ **Live Statistics** - Shows critical, total, resolved counts
✅ **Incident Simulation** - 4 pre-configured incident types
✅ **Beautiful Dark UI** - Custom color scheme and layout
✅ **Secure API Keys** - Environment variables via .env
✅ **Responsive Design** - Two-column layout (feed + simulator)

---

## 🔧 Fix Applied

**Issue:** AI reports showing "error 404"
**Root Cause:** Model `gemini-1.5-flash` not available in `v1beta` API

**Solution:**
- Updated to `gemini-2.0-flash` model
- Changed API endpoint from `v1beta` to `v1`
- Added error logging for debugging
- Implemented safe navigation in response parsing

---

## 📝 Summary

This is a **complete emergency response dashboard** where:

1. **User** clicks an incident button
2. **Incident** is created in Firebase with placeholder AI report
3. **Gemini API** generates contextual response in background
4. **Firebase** is updated with AI report
5. **StreamBuilder** detects change and refreshes UI
6. **Dashboard** shows live incident with AI analysis
7. **Stats** update in real-time
8. **Staff** can manage incidents (resolve, etc.)

All happening **real-time** with a **beautiful dark-themed UI**! 🚀
