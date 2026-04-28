import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';
import 'package:safehaven_dashboard/models/incident.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final bool isSelected;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    this.isSelected = false,
    this.onTap,
  });

  Color get _accentColor {
    switch (incident.type) {
      case 'Medical':
        return AppColors.accentRed;
      case 'Fire':
        return AppColors.accentOrange;
      case 'Security':
        return AppColors.accentBlue;
      case 'SOS':
        return AppColors.accentPurple;
      default:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _accentColor : Colors.white12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(width: 4, color: _accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${incident.emoji} ${incident.type} Emergency',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (incident.status == 'active'
                                          ? AppColors.accentRed
                                          : AppColors.accentGreen)
                                      .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: incident.status == 'active'
                                    ? AppColors.accentRed
                                    : AppColors.accentGreen,
                              ),
                            ),
                            child: Text(
                              incident.status.toUpperCase(),
                              style: TextStyle(
                                color: incident.status == 'active'
                                    ? AppColors.accentRed
                                    : AppColors.accentGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white38,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              incident.location,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white24,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            incident.timestamp,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🤖 AI INCIDENT REPORT',
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              incident.aiReport ?? '⏳ Generating AI report...',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
