import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // LOGO
          Text(
            'SAFEHAVEN',
            style: TextStyle(
              color: Color(0xFF00FFCC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          // NAV ITEMS
          const SizedBox(width: 40),
          _navItem('INCIDENTS', active: true),
          _navItem('AI ANALYTICS'),
          _navItem('STAFF ROSTER'),
          _navItem('OPERATIONS'),

          const Spacer(),

          // CRITICAL ALERT BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '🔴 CRITICAL ALERT ACTIVE',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 24),

          // SYSTEM STATUS
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'SYSTEM STATUS',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text(
                'OPTIMAL',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),
          const Icon(Icons.notifications_outlined, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.settings_outlined, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.account_circle_outlined, color: Colors.white),
        ],
      ),
    );
  }

  Widget _navItem(String title, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: active ? const Color(0xFF00FFCC) : Colors.grey,
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 40,
              color: const Color(0xFF00FFCC),
            ),
        ],
      ),
    );
  }
}
