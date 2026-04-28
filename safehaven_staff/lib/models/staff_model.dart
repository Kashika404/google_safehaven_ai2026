class StaffMember {
  final String key;
  final String name;
  final String role;
  final String status;
  final String? assignedIncident;

  StaffMember({
    required this.key,
    required this.name,
    required this.role,
    required this.status,
    this.assignedIncident,
  });

  bool get isDispatched => status == 'dispatched' || status == 'assigned';

  String get emoji {
    switch (role.toLowerCase()) {
      case 'medical':
      case 'first_aider':
        return '🚑';
      case 'security':
        return '🔒';
      case 'concierge':
        return '🏨';
      default:
        return '👤';
    }
  }
}
