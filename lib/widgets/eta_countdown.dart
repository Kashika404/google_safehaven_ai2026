import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';

class EtaCountdown extends StatefulWidget {
  final String assignedStaff;
  final String assignedRole;

  const EtaCountdown({
    super.key,
    required this.assignedStaff,
    required this.assignedRole,
  });

  @override
  State<EtaCountdown> createState() => _EtaCountdownState();
}

class _EtaCountdownState extends State<EtaCountdown> {
  int _seconds = 180; // 3 min ETA
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formatted {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _seconds < 60;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppColors.accentGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assignedStaff,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.assignedRole,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ETA', style: TextStyle(color: Colors.white38, fontSize: 9)),
              Text(
                _formatted,
                style: TextStyle(
                  color: isUrgent ? AppColors.accentRed : AppColors.accentGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
