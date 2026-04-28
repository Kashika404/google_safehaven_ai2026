import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';

class AiReportCard extends StatelessWidget {
  final String report;

  const AiReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🤖', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'AI INCIDENT REPORT',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
