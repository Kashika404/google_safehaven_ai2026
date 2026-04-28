import 'package:firebase_database/firebase_database.dart';
import 'package:safehaven_dashboard/models/incident.dart';
import 'package:safehaven_dashboard/services/gemini_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _incidentsRef = FirebaseDatabase.instance.ref(
    'incidents',
  );

  // Stream of all incidents
  Stream<List<Incident>> get incidentsStream {
    return _incidentsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final rawData = event.snapshot.value;
      if (rawData == null) return [];

      final data = Map<String, dynamic>.from(rawData as Map<dynamic, dynamic>);
      final incidents = data.entries
          .map((e) {
            try {
              return Incident.fromMap(
                e.key,
                Map<dynamic, dynamic>.from(e.value as Map),
              );
            } catch (err) {
              print('❌ Error parsing incident: $err');
              return null;
            }
          })
          .whereType<Incident>()
          .toList();
      return incidents;
    });
  }

  Stream<DatabaseEvent> get staffStream =>
      FirebaseDatabase.instance.ref('staff').onValue;

  Stream<DatabaseEvent> get zonesStream =>
      FirebaseDatabase.instance.ref('zones').onValue;

  Future<String> addIncident(String type, String location) async {
    final ref = _incidentsRef.push();
    final id = ref.key ?? '';

    await ref.set({
      'type': type,
      'location': location,
      'status': 'active',
      'timestamp': DateTime.now().toIso8601String(),
      'aiReport': '⏳ Generating AI report...',
    });

    // ✅ NEW — update zone to emergency
    final zoneKey = _getZoneFromLocation(location);
    if (zoneKey != null) {
      await FirebaseDatabase.instance.ref('zones/$zoneKey').update({
        'status': 'emergency',
      });
    }

    // Generate AI report in background
    GeminiService.generateIncidentReport(type: type, location: location).then((
      report,
    ) {
      updateAiReport(id, report);
    });

    return id;
  }

  String? _getZoneFromLocation(String location) {
    final loc = location.toLowerCase();
    if (loc.contains('lobby')) return 'floor_0';
    if (loc.contains('floor 1') || loc.contains('room 1')) return 'floor_1';
    if (loc.contains('floor 2') || loc.contains('room 2')) return 'floor_2';
    if (loc.contains('floor 3') || loc.contains('room 3')) return 'floor_3';
    if (loc.contains('floor 4') || loc.contains('room 4')) return 'floor_4';
    return null;
  }

  // Update AI report on incident
  Future<void> updateAiReport(String id, String report) async {
    await _incidentsRef.child(id).update({'aiReport': report});
  }

  // Resolve incident
  Future<void> resolveIncident(String id) async {
    await _incidentsRef.child(id).update({'status': 'resolved'});

    for (int i = 0; i <= 4; i++) {
      await FirebaseDatabase.instance.ref('zones/floor_$i').update({
        'status': 'safe',
      });
    }
    final staffRef = FirebaseDatabase.instance.ref('staff');
    final snapshot = await staffRef.get();
    if (snapshot.exists) {
      final staffMap = Map<String, dynamic>.from(snapshot.value as Map);
      for (final entry in staffMap.entries) {
        await staffRef.child(entry.key).update({
          'status': 'available',
          'assigned_incident': null,
        });
      }
    }
  }

  // Future<void> assignStaff(
  //   String incidentId,
  //   String staffName,
  //   String role,
  // ) async {
  //   await _incidentsRef.child(incidentId).update({
  //     'assigned_staff': staffName,
  //     'assigned_role': role,
  //     'status': 'assigned',
  //   });
  // }
  Future<void> assignStaff(
    String incidentId,
    String staffName,
    String role,
  ) async {
    // existing — update incident
    await _incidentsRef.child(incidentId).update({
      'assigned_staff': staffName,
      'assigned_role': role,
      'status': 'assigned',
    });

    // ✅ NEW — also update the staff record in /staff node
    final staffRef = FirebaseDatabase.instance.ref('staff');
    final snapshot = await staffRef.get();

    if (snapshot.exists) {
      final staffMap = Map<String, dynamic>.from(snapshot.value as Map);
      for (final entry in staffMap.entries) {
        final staff = Map<String, dynamic>.from(entry.value as Map);
        if (staff['name'] == staffName) {
          await staffRef.child(entry.key).update({
            'status': 'dispatched',
            'assigned_incident': incidentId,
          });
          break;
        }
      }
    }
  }
}
