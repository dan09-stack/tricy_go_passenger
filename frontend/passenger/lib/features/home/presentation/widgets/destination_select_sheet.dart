import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class DestinationSelectSheet extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final int passengerCount;
  final VoidCallback onPassengerCountChanged;
  final VoidCallback onConfirm;

  const DestinationSelectSheet({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.passengerCount,
    required this.onPassengerCountChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, -4))],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.adjust, color: AppTheme.secondaryGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: pickupController,
                  decoration: const InputDecoration(
                    hintText: 'Pickup Location',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryYellow, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Where to?',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Passengers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              _buildPassengerCounter(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: onConfirm,
              child: const Text(
                'Confirm Route & Pricing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPassengerCounter() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {
              if (passengerCount > 1) onPassengerCountChanged();
            },
          ),
          Text('$passengerCount', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () {
              if (passengerCount < 4) onPassengerCountChanged();
            },
          ),
        ],
      ),
    );
  }
}