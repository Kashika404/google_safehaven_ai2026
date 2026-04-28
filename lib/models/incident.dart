class Incident {
  final String id;
  final String type;
  final String location;
  final String status;
  final String timestamp;
  final String? aiReport;
  final String? assignedStaff;
  final String? assignedRole;

  Incident({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.timestamp,
    this.aiReport,
    this.assignedStaff,
    this.assignedRole,
  });

  factory Incident.fromMap(String id, Map map) {
    return Incident(
      id: id,
      type: _safe(map['type']) ?? 'Unknown',
      location: _safe(map['location']) ?? 'Unknown',
      status: _safe(map['status']) ?? 'active',
      timestamp: _safe(map['timestamp']) ?? '',
      aiReport: _safe(map['aiReport']),
      assignedStaff: _safeName(map['assigned_staff']),
      assignedRole: _safeRole(map['assigned_staff'], map['assigned_role']),
    );
  }

  static String? _safe(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  // static String? _safeName(dynamic v) {
  //   if (v == null) return null;
  //   if (v is String) return v;
  //   if (v is Map) return v['name']?.toString();
  //   return v.toString();
  // }

  // static String? _safeRole(dynamic staffVal, dynamic roleVal) {
  //   if (staffVal is Map) return staffVal['role']?.toString();
  //   if (roleVal != null) return roleVal.toString();
  //   return null;
  // }
  static String? _safeName(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map) return v['name']?.toString();

    // NEW: Handle Array of multiple staff members for Fire emergencies!
    if (v is List) {
      try {
        final names = v.map((staff) {
          if (staff is Map) return staff['name']?.toString() ?? 'Staff';
          return staff.toString();
        }).toList();
        return names.join(', '); // Turns into "Ahmed Khan, Priya Sharma"
      } catch (e) {
        return '${v.length} Responders Dispatched';
      }
    }

    return v.toString();
  }

  static String? _safeRole(dynamic staffVal, dynamic roleVal) {
    if (staffVal is Map) return staffVal['role']?.toString();
    // NEW: Handle Array of roles
    if (staffVal is List) return 'Emergency Response Team';
    if (roleVal != null) return roleVal.toString();
    return null;
  }

  Map toMap() => {
    'type': type,
    'location': location,
    'status': status,
    'timestamp': timestamp,
    if (aiReport != null) 'aiReport': aiReport,
  };

  String get emoji {
    switch (type) {
      case 'Medical':
        return '🚨';
      case 'Fire':
        return '🔥';
      case 'Security':
        return '🔒';
      case 'SOS':
        return '🆘';
      default:
        return '⚠️';
    }
  }
}
