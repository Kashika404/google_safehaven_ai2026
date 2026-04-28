import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/services/firebase_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _helpSent = false;
  String _selectedType = '';

  // Read room + floor from URL params (for QR code)
  String room = '412';
  String floor = '4';

  Future<void> _sendSOS(String type) async {
    setState(() {
      _selectedType = type;
      _helpSent = true;
    });
    await _firebaseService.addIncident(type, 'Room $room · Floor $floor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: _helpSent ? _buildConfirmation() : _buildSOSButtons(),
        ),
      ),
    );
  }

  Widget _buildSOSButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        const Text('🆘', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        const Text(
          'NEED HELP?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Room $room · Floor $floor',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),

        const SizedBox(height: 40),

        const Text(
          'What do you need help with?',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),

        const SizedBox(height: 24),

        // Emergency buttons
        _sosButton(
          '❤️  MEDICAL EMERGENCY',
          const Color(0xFFFF4444),
          () => _sendSOS('Medical'),
        ),
        const SizedBox(height: 12),
        _sosButton(
          '🔥  FIRE / SMOKE',
          const Color(0xFFFF6D00),
          () => _sendSOS('Fire'),
        ),
        const SizedBox(height: 12),
        _sosButton(
          '🔒  SECURITY THREAT',
          const Color(0xFF2196F3),
          () => _sendSOS('Security'),
        ),
        const SizedBox(height: 12),
        _sosButton(
          '🛗  ELEVATOR STUCK',
          const Color(0xFF9C27B0),
          () => _sendSOS('Elevator'),
        ),
        const SizedBox(height: 12),
        _sosButton(
          '🆘  OTHER EMERGENCY',
          const Color(0xFF607D8B),
          () => _sendSOS('SOS'),
        ),
      ],
    );
  }

  Widget _sosButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✅', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        const Text(
          'HELP IS ON THE WAY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$_selectedType team dispatched to\nRoom $room · Floor $floor',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: const Column(
            children: [
              Text(
                'Staff arriving in ~90 seconds',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'मदद आ रही है • Aide en route • 助けが来ています',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => setState(() {
            _helpSent = false;
            _selectedType = '';
          }),
          child: const Text('← Back', style: TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }
}
