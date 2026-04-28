import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class StaffSelectorScreen extends StatefulWidget {
  const StaffSelectorScreen({super.key});

  @override
  State<StaffSelectorScreen> createState() => _StaffSelectorScreenState();
}

class _StaffSelectorScreenState extends State<StaffSelectorScreen> {
  String? _selectedKey;
  Map<String, dynamic> _staffMap = {};
  final _service = StaffFirebaseService();

  @override
  void initState() {
    super.initState();
    _service.staffStream.first.then((map) {
      setState(() => _staffMap = map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0E12), Color(0xFF1A1B22)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'SAFEHAVEN',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  'Staff Portal',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 64),
                const Text(
                  'WHO ARE YOU?',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Staff Cards
                StreamBuilder<Map<String, dynamic>>(
                  stream: _service.staffStream,
                  builder: (context, snapshot) {
                    final staffMap = snapshot.data ?? {};
                    return Column(
                      children: staffMap.entries.map((entry) {
                        final staff = Map<String, dynamic>.from(
                          entry.value as Map,
                        );
                        final isSelected = _selectedKey == entry.key;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedKey = entry.key),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00D4FF).withOpacity(0.1)
                                  : const Color(0xFF1A1B22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.white12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getRoleEmoji(staff['role'] ?? ''),
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staff['name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      (staff['role'] ?? '').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00D4FF),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectedKey == null
                        ? null
                        : () {
                            final staff = Map<String, dynamic>.from(
                              _staffMap[_selectedKey] as Map? ?? {},
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeScreen(
                                  staffKey: _selectedKey!,
                                  staffName: staff['name'] ?? '',
                                  staffRole: staff['role'] ?? '',
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      'ENTER PORTAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
