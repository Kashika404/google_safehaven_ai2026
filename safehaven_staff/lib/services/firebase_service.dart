import 'package:firebase_database/firebase_database.dart';

class StaffFirebaseService {
  final _db = FirebaseDatabase.instance;

  Stream<Map<String, dynamic>> get staffStream =>
      _db.ref('staff').onValue.map((e) {
        if (e.snapshot.value == null) return {};
        return Map<String, dynamic>.from(e.snapshot.value as Map);
      });

  Stream<Map<String, dynamic>> get incidentsStream =>
      _db.ref('incidents').onValue.map((e) {
        if (e.snapshot.value == null) return {};
        return Map<String, dynamic>.from(e.snapshot.value as Map);
      });

  Stream<Map<String, dynamic>> get zonesStream =>
      _db.ref('zones').onValue.map((e) {
        if (e.snapshot.value == null) return {};
        return Map<String, dynamic>.from(e.snapshot.value as Map);
      });

  Future<void> updateStaffStatus(String key, String status) async {
    await _db.ref('staff/$key').update({'status': status});
  }

  Future<void> markComplete(String key, String incidentId) async {
    await _db.ref('staff/$key').update({
      'status': 'available',
      'assigned_incident': null,
    });
    await _db.ref('incidents/$incidentId').update({'status': 'resolved'});
  }

  Future<void> sendMessage(
    String incidentId,
    String staffName,
    String message,
  ) async {
    await _db.ref('incidents/$incidentId/messages').push().set({
      'sender': staffName,
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<Map<String, dynamic>>> messagesStream(String incidentId) =>
      _db.ref('incidents/$incidentId/messages').onValue.map((e) {
        if (e.snapshot.value == null) return [];
        final map = Map<String, dynamic>.from(e.snapshot.value as Map);
        final list = map.values
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        list.sort(
          (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int),
        );
        return list;
      });
}
