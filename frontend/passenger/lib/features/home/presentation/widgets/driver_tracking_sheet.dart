
import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class DriverTrackingSheet extends StatelessWidget {
  final String driverName;
  final double driverRating;
  final String driverVehicle;
  final String driverPlate;
  final String eta;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  const DriverTrackingSheet({
    super.key,
    required this.driverName,
    required this.driverRating,
    required this.driverVehicle,
    required this.driverPlate,
    required this.eta,
    required this.onMessage,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryYellow,
                child: Icon(Icons.person, color: AppTheme.darkGray, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.primaryYellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${driverRating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Verified Pro',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.secondaryGreen,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$eta mins',
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Arriving Soon',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle: $driverVehicle',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Text(
                  'Plate: $driverPlate',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF444444),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onMessage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onCall,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

