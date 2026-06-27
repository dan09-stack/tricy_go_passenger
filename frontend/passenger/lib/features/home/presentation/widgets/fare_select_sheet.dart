import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class FareSelectSheet extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRequestRide;

  const FareSelectSheet({
    super.key,
    required this.isLoading,
    required this.onRequestRide,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Tricycle Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow),
          ),
          const SizedBox(height: 16),
          _buildFareTierItem('TricyGo EcoShare', '₱45.00', '2 mins away', Icons.people_outline, true),
          _buildFareTierItem('TricyGo Express', '₱70.00', 'Immediate pickup', Icons.flash_on, false),
          _buildFareTierItem('TricyGo ComfortXL', '₱110.00', 'Heavy load / Luggage', Icons.bento_outlined, false),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading ? null : onRequestRide,
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Request TricyGo Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFareTierItem(String name, String price, String eta, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF383838) : AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.primaryYellow : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryYellow, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(eta, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
        ],
      ),
    );
  }
}