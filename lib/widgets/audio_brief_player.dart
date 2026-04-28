import 'package:flutter/material.dart';
import 'package:safehaven_dashboard/constants/app_colors.dart';
import 'dart:js' as js;

class AudioBriefPlayer extends StatefulWidget {
  final String briefText;
  const AudioBriefPlayer({super.key, required this.briefText});

  @override
  State<AudioBriefPlayer> createState() => _AudioBriefPlayerState();
}

class _AudioBriefPlayerState extends State<AudioBriefPlayer> {
  bool _isPlaying = false;

  // void _togglePlay() {
  //   // For Phase 1 — simulate playing
  //   // Phase 2: integrate audioplayers package + Firebase Storage MP3
  //   setState(() => _isPlaying = !_isPlaying);

  //   if (_isPlaying) {
  //     Future.delayed(const Duration(seconds: 8), () {
  //       if (mounted) setState(() => _isPlaying = false);
  //     });
  //   }
  // }
  // void _togglePlay() {
  //   if (_isPlaying) {
  //     js.context.callMethod('eval', ['speechSynthesis.cancel()']);
  //     setState(() => _isPlaying = false);
  //   } else {
  //     final text = widget.briefText.isNotEmpty
  //         ? widget.briefText
  //         : 'Emergency reported. Dispatch team immediately. Priority critical.';

  //     js.context.callMethod('eval', [
  //       "var u = new SpeechSynthesisUtterance('$text'); u.rate=0.9; u.pitch=1; speechSynthesis.speak(u);",
  //     ]);
  //     setState(() => _isPlaying = true);

  //     // Auto stop after estimated duration
  //     Future.delayed(const Duration(seconds: 12), () {
  //       if (mounted) setState(() => _isPlaying = false);
  //     });
  //   }
  // }

  void _togglePlay() {
    if (_isPlaying) {
      js.context.callMethod('eval', ['speechSynthesis.cancel()']);
      setState(() => _isPlaying = false);
    } else {
      // ✅ Clean text — remove quotes and special chars that break JS
      final rawText = widget.briefText.isNotEmpty
          ? widget.briefText
          : 'Emergency reported. Dispatch team immediately. Priority critical.';

      final cleanText = rawText
          .replaceAll("'", ' ') // single quotes break JS string
          .replaceAll('"', ' ') // double quotes break JS string
          .replaceAll('\n', ' ') // newlines break JS string
          .replaceAll('\r', ' ') // carriage returns
          .replaceAll('`', ' '); // backticks break JS string

      js.context.callMethod('eval', [
        "var u = new SpeechSynthesisUtterance('$cleanText'); u.rate=0.9; u.pitch=1; speechSynthesis.speak(u);",
      ]);
      setState(() => _isPlaying = true);

      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎙️ 911 DISPATCH BRIEF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isPlaying ? 'Playing...' : 'Tap to play audio brief',
                  style: TextStyle(
                    color: _isPlaying ? AppColors.accentGreen : Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (_isPlaying)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentBlue,
              ),
            ),
        ],
      ),
    );
  }
}
