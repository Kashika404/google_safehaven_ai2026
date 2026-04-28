import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';

class MultilingualAlerts extends StatelessWidget {
  const MultilingualAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = [
      {
        'flag': '🇬🇧',
        'lang': 'English',
        'text': 'Help is on the way. Please stay calm.',
      },
      {'flag': '🇮🇳', 'lang': 'Hindi', 'text': 'मदद आ रही है। शांत रहें।'},
      {
        'flag': '🇫🇷',
        'lang': 'French',
        'text': 'L\'aide est en route. Restez calme.',
      },
      {'flag': '🇯🇵', 'lang': 'Japanese', 'text': '助けが来ています。落ち着いてください。'},
      {
        'flag': '🇸🇦',
        'lang': 'Arabic',
        'text': 'المساعدة في الطريق. ابق هادئاً.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.translate, color: AppColors.accentBlue, size: 14),
            const SizedBox(width: 6),
            const Text(
              'MULTILINGUAL ALERTS SENT',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '✓ SENT',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...translations.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['flag']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    t['lang']!,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
                Expanded(
                  child: Text(
                    t['text']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
