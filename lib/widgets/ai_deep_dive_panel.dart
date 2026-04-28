import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';
import 'package:safehaven_dashboard/models/incident.dart';
import 'package:safehaven_dashboard/services/firebase_service.dart';
import 'package:safehaven_dashboard/widgets/audio_brief_player.dart';
import 'package:safehaven_dashboard/widgets/eta_countdown.dart';
import 'package:safehaven_dashboard/widgets/multilingual_alerts.dart';
import 'package:safehaven_dashboard/widgets/report_downloader.dart';

class AiDeepDivePanel extends StatelessWidget {
  final Incident? selectedIncident;
  final FirebaseService firebaseService;
  final Function(String, String, String) onAssignStaff;
  final Function(String) onResolve;

  const AiDeepDivePanel({
    super.key,
    required this.selectedIncident,
    required this.firebaseService,
    required this.onAssignStaff,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: selectedIncident == null
          ? const Center(
              child: Text(
                '← Select an incident to view AI analysis',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            )
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final incident = selectedIncident!;
    final isAssigned = incident.status == 'assigned';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          const Text(
            '🤖 AI DEEP DIVE (GEMINI)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // ── Raw Input
          const Text(
            'RAW GUEST INPUT',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.accentGreen, width: 3),
              ),
              color: Colors.white.withOpacity(0.03),
            ),
            child: Text(
              '"${incident.type} emergency reported at ${incident.location}"',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Threat + Location
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THREAT ASSESSMENT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '5/5',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HIGH SEVERITY',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOCATION CONTEXT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── AI Action Plan
          const Text(
            'ACTION PLAN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              incident.aiReport ?? '⏳ Generating AI report...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.8,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 911 Audio Brief
          AudioBriefPlayer(briefText: incident.aiReport ?? ''),

          const SizedBox(height: 20),

          // ── ETA (only if assigned)
          if (isAssigned && incident.assignedStaff != null) ...[
            const Text(
              'ASSIGNED RESPONDER',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            EtaCountdown(
              assignedStaff: incident.assignedStaff!,
              assignedRole: incident.assignedRole ?? 'Staff',
            ),
            const SizedBox(height: 20),
          ],

          // ── Multilingual Alerts
          const MultilingualAlerts(),

          const SizedBox(height: 20),

          // ── Action Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () =>
                      onAssignStaff(incident.id, 'Ravi Kumar', 'Medical'),
                  child: const Text(
                    'MEDICAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    side: BorderSide(color: AppColors.accentGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () =>
                      onAssignStaff(incident.id, 'Priya Sharma', 'Security'),
                  child: Text(
                    'SECURITY',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => onResolve(incident.id),
                  child: const Text(
                    'RESOLVE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Download Report
          SizedBox(
            width: double.infinity,
            child: ReportDownloader(incident: incident),
          ),
        ],
      ),
    );
  }
}
