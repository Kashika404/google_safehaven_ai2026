import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class AssignmentScreen extends StatefulWidget {
  final String staffKey;
  final String staffName;
  final String staffRole;
  final String incidentId;

  const AssignmentScreen({
    super.key,
    required this.staffKey,
    required this.staffName,
    required this.staffRole,
    required this.incidentId,
  });

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final _service = StaffFirebaseService();
  final _msgController = TextEditingController();
  bool _onMyWay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E12),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _service.incidentsStream,
        builder: (context, snapshot) {
          final incidents = snapshot.data ?? {};
          final incident = incidents.containsKey(widget.incidentId)
              ? Map<String, dynamic>.from(incidents[widget.incidentId] as Map)
              : {};

          if (incident.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
            );
          }

          final type = incident['type'] ?? 'Unknown';
          final location = incident['location'] ?? 'Unknown';
          final aiReport = incident['aiReport'] ?? '';

          return SafeArea(
            child: Column(
              children: [
                // ── Alert Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A0000),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFFF4444)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '🚨 EMERGENCY ASSIGNMENT',
                            style: TextStyle(
                              color: Color(0xFFFF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$type Emergency',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF00D4FF),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── AI Brief
                        if (aiReport.isNotEmpty) ...[
                          const Text(
                            'AI BRIEF',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1B22),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              aiReport,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Navigate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A73E8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.navigation,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'NAVIGATE THERE — Google Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            onPressed: () => _openMaps(location),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── AED Location
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1500),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF8800).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AED / EQUIPMENT LOCATION',
                                    style: TextStyle(
                                      color: Color(0xFFFF8800),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getAedLocation(location),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _onMyWay
                                      ? Colors.grey
                                      : const Color(0xFF00D4FF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _onMyWay
                                    ? null
                                    : () {
                                        setState(() => _onMyWay = true);
                                        _service.updateStaffStatus(
                                          widget.staffKey,
                                          'en_route',
                                        );
                                      },
                                child: Text(
                                  _onMyWay ? '✅ ON MY WAY' : "🏃 I'M ON MY WAY",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00FF88),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  await _service.markComplete(
                                    widget.staffKey,
                                    widget.incidentId,
                                  );
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HomeScreen(
                                          staffKey: widget.staffKey,
                                          staffName: widget.staffName,
                                          staffRole: widget.staffRole,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  '✅ MARK COMPLETE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Chat Box
                        const Text(
                          'MESSAGE MANAGER',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Messages List
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _service.messagesStream(widget.incidentId),
                          builder: (context, msgSnap) {
                            final messages = msgSnap.data ?? [];
                            return Container(
                              height: 160,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1B22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: messages.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No messages yet',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: messages.length,
                                      itemBuilder: (ctx, i) {
                                        final msg = messages[i];
                                        final isMe =
                                            msg['sender'] == widget.staffName;
                                        return Align(
                                          alignment: isMe
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? const Color(
                                                      0xFF00D4FF,
                                                    ).withOpacity(0.2)
                                                  : Colors.white.withOpacity(
                                                      0.05,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${msg['sender']}: ${msg['text']}',
                                              style: TextStyle(
                                                color: isMe
                                                    ? const Color(0xFF00D4FF)
                                                    : Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Message Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: const TextStyle(
                                    color: Colors.white38,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1B22),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white12,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white12,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final text = _msgController.text.trim();
                                if (text.isNotEmpty) {
                                  _service.sendMessage(
                                    widget.incidentId,
                                    widget.staffName,
                                    text,
                                  );
                                  _msgController.clear();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D4FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMaps(String location) async {
    final query = Uri.encodeComponent('$location hotel');
    final url = Uri.parse('https://www.google.com/maps/search/$query');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  String _getAedLocation(String location) {
    final loc = location.toLowerCase();
    if (loc.contains('lobby')) return 'Main Reception Desk — Ground Floor';
    if (loc.contains('floor 1') || loc.contains('room 1'))
      return 'Floor 1 — Near Elevator Bank';
    if (loc.contains('floor 2') || loc.contains('room 2'))
      return 'Floor 2 — Nurse Station';
    if (loc.contains('floor 3') || loc.contains('room 3'))
      return 'Floor 3 — Emergency Cabinet (Room 301)';
    return 'Reception Desk — Ground Floor';
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }
}
