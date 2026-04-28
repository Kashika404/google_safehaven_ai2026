const { onValueCreated, onValueUpdated } = require('firebase-functions/v2/database');
const admin = require('firebase-admin');

// Role mapping per crisis type
const ROLE_MAP = {
  medical_emergency: ['first_aider'],
  cardiac_arrest:    ['first_aider'],
  fire:              ['security', 'concierge'],
  guest_sos:         ['concierge'],
  security_threat:   ['security'],
  elevator_stuck:    ['concierge'],
  flood:             ['security', 'concierge'],
  unknown:           ['concierge'],
};

// ─────────────────────────────────────────────
// FUNCTION 1: Assign Staff When Incident Created
// ─────────────────────────────────────────────
exports.assignStaffOnIncident = onValueCreated(
  { ref: '/incidents/{incidentId}', region: 'us-central1' },
  async (event) => {
    try {
      const incidentId = event.params.incidentId;
      const incident   = event.data.val();

      // Safety check — skip if no data
      if (!incident) {
        console.log('⚠️ No incident data found, skipping');
        return null;
      }

      // Skip if already has assigned staff
      if (incident.assigned_staff && Object.keys(incident.assigned_staff).length > 0) {
        console.log(`⚠️ Incident ${incidentId} already has staff assigned, skipping`);
        return null;
      }

      // Skip if status is not active (e.g. already resolved)
      if (incident.status && incident.status !== 'active') {
        console.log(`⚠️ Incident ${incidentId} status is ${incident.status}, skipping`);
        return null;
      }

      const db = admin.database();

      // Determine required roles
      const crisisType    = incident.crisis_type || incident.type || 'guest_sos';
      const neededRoles   = ROLE_MAP[crisisType] || ['concierge'];
      const incidentFloor = incident.floor ?? 0;

      console.log(`🔍 Finding staff for: ${crisisType} on floor ${incidentFloor}`);
      console.log(`📋 Roles needed: ${neededRoles.join(', ')}`);

      // Read all staff
      let staffData;
      try {
        const staffSnap = await db.ref('staff').once('value');
        staffData = staffSnap.val();
      } catch (err) {
        console.error('❌ Failed to read staff from Firebase:', err);
        return null;
      }

      if (!staffData) {
        console.error('❌ No staff data found in Firebase — check /staff node exists');
        return null;
      }

      const assigned = [];

      for (const role of neededRoles) {
        try {
          // Filter available staff with matching role
          const candidates = Object.entries(staffData)
            .filter(([id, s]) =>
              s.role === role &&
              s.status === 'available' &&
              !assigned.includes(id)
            )
            .map(([id, s]) => ({
              id,
              ...s,
              floorDistance: Math.abs((s.floor ?? 0) - incidentFloor)
            }))
            .sort((a, b) => a.floorDistance - b.floorDistance);

          if (candidates.length === 0) {
            console.log(`⚠️ No available staff for role: ${role}`);
            continue;
          }

          const best = candidates[0];
          assigned.push(best.id);

          // ETA: 30 sec per floor, minimum 60 sec
          const etaSeconds = Math.max(60, best.floorDistance * 30 + 60);

          console.log(`👤 Assigning ${best.name} (${role}) — ETA: ${etaSeconds}s`);

          // Atomic update: staff + incident in ONE write
          const updates = {};
          updates[`staff/${best.id}/status`]            = 'assigned';
          updates[`staff/${best.id}/assigned_incident`] = incidentId;
          updates[`incidents/${incidentId}/assigned_staff/${best.id}`] = {
            name:          best.name,
            role:          best.role,
            eta_seconds:   etaSeconds,
            dispatched_at: Date.now(),
          };
          updates[`zones/floor_${incidentFloor}/status`] = 'emergency';

          await db.ref().update(updates);
          console.log(`✅ Successfully assigned ${best.name} to incident ${incidentId}`);

          // Update local staffData so next role doesn't pick same person
          staffData[best.id].status = 'assigned';

        } catch (err) {
          console.error(`❌ Failed to assign staff for role ${role}:`, err);
          // Continue to next role even if this one fails
        }
      }

      // If nobody was assigned at all
      if (assigned.length === 0) {
        console.log('⚠️ No staff could be assigned for any role');
        try {
          await db.ref(`incidents/${incidentId}`).update({
            assignment_error: 'No available staff found for any required role',
          });
        } catch (err) {
          console.error('❌ Could not write assignment_error to Firebase:', err);
        }
      } else {
        console.log(`🎉 Assignment complete — ${assigned.length} staff dispatched`);
      }

    } catch (err) {
      // Top-level catch — function never crashes Firebase
      console.error('❌ assignStaffOnIncident crashed unexpectedly:', err);
    }

    return null;
  }
);

// ─────────────────────────────────────────────
// FUNCTION 2: Release Staff When Incident Resolved
// ─────────────────────────────────────────────
exports.releaseStaffOnResolve = onValueUpdated(
  { ref: '/incidents/{incidentId}/status', region: 'us-central1' },
  async (event) => {
    try {
      const newStatus = event.data.after.val();
      const oldStatus = event.data.before.val();

      // Only trigger when status changes TO resolved
      if (newStatus !== 'resolved') {
        return null;
      }

      // Skip if it was already resolved (prevents double firing)
      if (oldStatus === 'resolved') {
        console.log('⚠️ Status was already resolved, skipping');
        return null;
      }

      const incidentId = event.params.incidentId;
      console.log(`🔓 Releasing staff for resolved incident: ${incidentId}`);

      const db = admin.database();

      // Get assigned staff from incident
      let assignedStaff;
      try {
        const incidentSnap = await db.ref(`incidents/${incidentId}/assigned_staff`).once('value');
        assignedStaff = incidentSnap.val();
      } catch (err) {
        console.error('❌ Failed to read assigned_staff from Firebase:', err);
        return null;
      }

      if (!assignedStaff) {
        console.log(`⚠️ No assigned staff found for incident ${incidentId}`);
        return null;
      }

      const updates = {};

      // Release each assigned staff member
      Object.keys(assignedStaff).forEach(staffId => {
        updates[`staff/${staffId}/status`]            = 'available';
        updates[`staff/${staffId}/assigned_incident`] = null;
        console.log(`👤 Releasing staff: ${staffId}`);
      });

      // Reset zone status to safe
      try {
        const floorSnap = await db.ref(`incidents/${incidentId}/floor`).once('value');
        const floor = floorSnap.val();
        if (floor !== null && floor !== undefined) {
          updates[`zones/floor_${floor}/status`] = 'safe';
          console.log(`🟢 Zone floor_${floor} reset to safe`);
        }
      } catch (err) {
        console.error('❌ Failed to read floor number — zone will not reset:', err);
        // Non-fatal, continue with staff release
      }

      // Write all updates atomically
      try {
        await db.ref().update(updates);
        console.log(`✅ Staff released successfully for incident ${incidentId}`);
      } catch (err) {
        console.error('❌ Failed to write release updates to Firebase:', err);
      }

    } catch (err) {
      // Top-level catch — function never crashes
      console.error('❌ releaseStaffOnResolve crashed unexpectedly:', err);
    }

    return null;
  }
);