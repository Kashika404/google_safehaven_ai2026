import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';
import 'package:safehaven_dashboard/models/incident.dart';
import 'package:safehaven_dashboard/services/firebase_service.dart';
import 'package:safehaven_dashboard/widgets/incident_card.dart';
import 'package:safehaven_dashboard/widgets/sim_button.dart';
import 'package:safehaven_dashboard/widgets/stat_card.dart';
import 'package:safehaven_dashboard/widgets/ai_deep_dive_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Incident? _selectedIncident;

  Future<void> _triggerIncident(String type, String location) async {
    await _firebaseService.addIncident(type, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _buildNavBar(),
          Expanded(
            child: StreamBuilder<List<Incident>>(
              stream: _firebaseService.incidentsStream,
              builder: (context, snapshot) {
                final incidents = snapshot.data ?? [];

                // Auto-refresh selected incident from Firebase
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_selectedIncident != null &&
                      snapshot.hasData &&
                      mounted) {
                    final updated = snapshot.data!
                        .where((i) => i.id == _selectedIncident!.id)
                        .toList();
                    if (updated.isNotEmpty) {
                      setState(() => _selectedIncident = updated.first);
                    }
                  }
                });

                final critical = incidents
                    .where(
                      (i) => i.status == 'active' || i.status == 'assigned',
                    )
                    .length;
                final resolved = incidents
                    .where((i) => i.status == 'resolved')
                    .length;

                return Column(
                  children: [
                    _buildStatsRow(critical, resolved, incidents.length),
                    Expanded(child: _buildThreePanels(incidents)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP NAV BAR ───────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.bgSecondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '🛡️ SAFEHAVEN COMMAND',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE SYSTEM',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STATS ROW ─────────────────────────────────────────────
  Widget _buildStatsRow(int critical, int resolved, int total) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'CRITICAL',
              count: critical,
              color: AppColors.accentRed,
              icon: '🚨',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'TOTAL',
              count: total,
              color: AppColors.accentOrange,
              icon: '⚡',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'RESOLVED',
              count: resolved,
              color: AppColors.accentGreen,
              icon: '✅',
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3 PANEL LAYOUT ────────────────────────────────────────
  Widget _buildThreePanels(List<Incident> incidents) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: _buildLeftPanel(incidents),
        ),
        Expanded(child: _buildCenterPanel()),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.28,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  // Add this to your state variables at top of _DashboardScreenState:
  String _activeTab = 'active'; // 'active', 'assigned', 'resolved'

  Widget _buildLeftPanel(List<Incident> incidents) {
    final active = incidents.where((i) => i.status != 'resolved').toList();
    final assigned = incidents.where((i) => i.status == 'assigned').toList();
    final resolved = incidents.where((i) => i.status == 'resolved').toList();

    List<Incident> displayed = switch (_activeTab) {
      'active' => active,
      'assigned' => assigned,
      'resolved' => resolved,
      _ => active,
    };

    return Container(
      color: AppColors.bgPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LIVE INCIDENTS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentRed),
                  ),
                  child: Text(
                    '${active.length} ACTIVE',
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Subtabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _tab('ACTIVE', 'active', active.length, AppColors.accentRed),
                const SizedBox(width: 4),
                _tab(
                  'ASSIGNED',
                  'assigned',
                  assigned.length,
                  AppColors.accentOrange,
                ),
                const SizedBox(width: 4),
                _tab(
                  'RESOLVED',
                  'resolved',
                  resolved.length,
                  AppColors.accentGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Incident List
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Text(
                      'No ${_activeTab} incidents',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: displayed
                            .map(
                              (i) => IncidentCard(
                                incident: i,
                                isSelected: _selectedIncident?.id == i.id,
                                onTap: () =>
                                    setState(() => _selectedIncident = i),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Tab widget
  Widget _tab(String label, String key, int count, Color color) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? color : Colors.white12),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? color : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPanel() {
    return AiDeepDivePanel(
      selectedIncident: _selectedIncident,
      firebaseService: _firebaseService,
      onAssignStaff: (incidentId, staffName, role) async {
        await _firebaseService.assignStaff(incidentId, staffName, role);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $staffName dispatched — $role'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onResolve: (incidentId) async {
        await _firebaseService.resolveIncident(incidentId);
        setState(() => _selectedIncident = null);
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: AppColors.bgSecondary,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STAFF ROSTER FROM FIREBASE
            const Text(
              'STAFF ROSTER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder(
              stream: _firebaseService.staffStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final staffMap = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map? ?? {},
                );
                final staffList = staffMap.entries.toList();
                return Column(
                  children: staffList.map((entry) {
                    final staff = Map<String, dynamic>.from(entry.value);
                    final isDispatched =
                        staff['status'] == 'dispatched' ||
                        staff['status'] == 'assigned';
                    return _staffRow(
                      staff['name'] ?? '',
                      staff['role'] ?? '',
                      isDispatched,
                    );
                  }).toList(),
                );
              },
            ),

            const Divider(color: Colors.white12, height: 32),

            // ── FLOOR STATUS FROM FIREBASE
            const Text(
              'FLOOR STATUS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder(
              stream: _firebaseService.zonesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final zonesMap = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map? ?? {},
                );
                // Sort so floor_0 (Lobby) comes first
                final sortedKeys = zonesMap.keys.toList()..sort();
                return Column(
                  children: sortedKeys.map((key) {
                    final zone = Map<String, dynamic>.from(zonesMap[key]);
                    final isEmergency = zone['status'] == 'emergency';
                    final name = zone['name'] ?? key.toUpperCase();
                    return _floorStatus(name.toUpperCase(), isEmergency);
                  }).toList(),
                );
              },
            ),

            const Divider(color: Colors.white12, height: 32),

            // ── SIMULATE INCIDENT
            const Text(
              'SIMULATE INCIDENT',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Grid layout for buttons
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                SimButton(
                  label: '🚨\nMedical',
                  color: AppColors.accentRed,
                  onPressed: () => _triggerIncident('Medical', 'Room 204'),
                ),
                SimButton(
                  label: '🔥\nFire',
                  color: AppColors.accentOrange,
                  onPressed: () => _triggerIncident('Fire', 'Floor 3 Kitchen'),
                ),
                SimButton(
                  label: '🔒\nSecurity',
                  color: AppColors.accentBlue,
                  onPressed: () => _triggerIncident('Security', 'Main Lobby'),
                ),
                SimButton(
                  label: '🆘\nSOS',
                  color: AppColors.accentPurple,
                  onPressed: () => _triggerIncident('SOS', 'Room 101'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffRow(String name, String role, bool dispatched) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  role,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (dispatched ? AppColors.accentRed : AppColors.accentGreen)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              dispatched ? 'DISPATCHED' : 'IDLE',
              style: TextStyle(
                color: dispatched ? AppColors.accentRed : AppColors.accentGreen,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floorStatus(String floor, bool emergency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: emergency ? AppColors.accentRed : AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            floor,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Text(
            emergency ? 'EMERGENCY' : 'CLEAR',
            style: TextStyle(
              color: emergency ? AppColors.accentRed : AppColors.accentGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
