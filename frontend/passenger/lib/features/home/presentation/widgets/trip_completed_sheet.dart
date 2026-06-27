import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class TripCompletedSheet extends StatelessWidget {
  final VoidCallback onBookAgain;

  const TripCompletedSheet({super.key, required this.onBookAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.secondaryGreen, size: 56),
          const SizedBox(height: 12),
          const Text('Arrived at Destination!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Thank you for riding with TricyGo', style: TextStyle(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Fare Paid (Cash)', style: TextStyle(fontSize: 14)),
              Text('₱45.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkGray,
              ),
              onPressed: onBookAgain,
              child: const Text('Book Another Ride', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}