
import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class MatchingRadarSheet extends StatelessWidget {
  final VoidCallback onCancel;

  const MatchingRadarSheet({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AppTheme.primaryYellow,
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Finding Your Closest Tricycle Driver...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Broadcasting booking request to nearby operators pool via WebSockets',
            style: TextStyle(fontSize: 12, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onCancel,
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

