
import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/models/fare_tier.dart';

class FareTierItem extends StatelessWidget {
  final FareTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  const FareTierItem({
    super.key,
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (tier.icon) {
      case "people_outline":
        iconData = Icons.people_outline;
        break;
      case "flash_on":
        iconData = Icons.flash_on;
        break;
      case "bento_outlined":
        iconData = Icons.bento_outlined;
        break;
      default:
        iconData = Icons.circle_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF383838) : AppTheme.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(iconData, color: AppTheme.primaryYellow, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    tier.eta,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '₱${tier.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

