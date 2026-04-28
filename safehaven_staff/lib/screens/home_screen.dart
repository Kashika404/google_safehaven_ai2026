import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'assignment_screen.dart';

class HomeScreen extends StatelessWidget {
  final String staffKey;
  final String staffName;
  final String staffRole;

  const HomeScreen({
    super.key,
    required this.staffKey,
    required this.staffName,
    required this.staffRole,
  });

  @override
  Widget build(BuildContext context) {
    final service = StaffFirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E12),
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: service.staffStream,
          builder: (context, staffSnap) {
            final staffMap = staffSnap.data ?? {};
            final myData = staffMap.containsKey(staffKey)
                ? Map<String, dynamic>.from(staffMap[staffKey] as Map)
                : {};
            final myStatus = myData['status'] ?? 'available';
            final myIncidentId = myData['assigned_incident'];
            final isDispatched =
                myStatus == 'dispatched' || myStatus == 'assigned';

            // Auto-navigate to assignment screen when dispatched
            if (isDispatched && myIncidentId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignmentScreen(
                      staffKey: staffKey,
                      staffName: staffName,
                      staffRole: staffRole,
                      incidentId: myIncidentId,
                    ),
                  ),
                );
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header
                  Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      const Text(
                        'SAFEHAVEN',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF88),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Staff Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.15),
                          const Color(0xFF1A1B22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getRoleEmoji(staffRole),
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                staffName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                staffRole.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDispatched
                                      ? const Color(0xFFFF4444).withOpacity(0.2)
                                      : const Color(
                                          0xFF00FF88,
                                        ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDispatched
                                        ? const Color(0xFFFF4444)
                                        : const Color(0xFF00FF88),
                                  ),
                                ),
                                child: Text(
                                  isDispatched
                                      ? '🔴 DISPATCHED'
                                      : '🟢 AVAILABLE',
                                  style: TextStyle(
                                    color: isDispatched
                                        ? const Color(0xFFFF4444)
                                        : const Color(0xFF00FF88),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Hotel Status Summary
                  const Text(
                    'HOTEL STATUS',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<Map<String, dynamic>>(
                    stream: service.incidentsStream,
                    builder: (context, incSnap) {
                      final incidents = incSnap.data ?? {};
                      final active = incidents.values
                          .where((v) => (v as Map)['status'] == 'active')
                          .length;
                      final assigned = incidents.values
                          .where((v) => (v as Map)['status'] == 'assigned')
                          .length;
                      final resolved = incidents.values
                          .where((v) => (v as Map)['status'] == 'resolved')
                          .length;

                      return Row(
                        children: [
                          _statCard(
                            '🚨',
                            'ACTIVE',
                            active,
                            const Color(0xFFFF4444),
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            '⚡',
                            'ASSIGNED',
                            assigned,
                            const Color(0xFFFF8800),
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            '✅',
                            'RESOLVED',
                            resolved,
                            const Color(0xFF00FF88),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Floor Status
                  const Text(
                    'FLOOR STATUS',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<Map<String, dynamic>>(
                    stream: service.zonesStream,
                    builder: (context, zoneSnap) {
                      final zones = zoneSnap.data ?? {};
                      final sortedKeys = zones.keys.toList()..sort();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1B22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: sortedKeys.map((key) {
                            final zone = Map<String, dynamic>.from(
                              zones[key] as Map,
                            );
                            final isEmergency = zone['status'] == 'emergency';
                            final name = (zone['name'] ?? key)
                                .toString()
                                .toUpperCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isEmergency
                                          ? const Color(0xFFFF4444)
                                          : const Color(0xFF00FF88),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    isEmergency ? 'EMERGENCY' : 'CLEAR',
                                    style: TextStyle(
                                      color: isEmergency
                                          ? const Color(0xFFFF4444)
                                          : const Color(0xFF00FF88),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Standby message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.notifications_active,
                          color: Color(0xFF00D4FF),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Standing by — you\'ll be alerted automatically when assigned to an incident.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String icon, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleEmoji(String role) {
    switch (role.toLowerCase()) {
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
