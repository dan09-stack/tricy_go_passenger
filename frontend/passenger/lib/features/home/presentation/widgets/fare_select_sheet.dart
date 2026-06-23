
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/fare_tier_item.dart';
import 'package:tricygo_passenger/features/home/services/ride_service.dart';

class FareSelectSheet extends ConsumerStatefulWidget {
  final VoidCallback onRequestRide;

  const FareSelectSheet({
    super.key,
    required this.onRequestRide,
  });

  @override
  ConsumerState<FareSelectSheet> createState() => _FareSelectSheetState();
}

class _FareSelectSheetState extends ConsumerState<FareSelectSheet> {
  String _selectedTierId = "eco_share";
  final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    final tiers = _rideService.getFareTiers();

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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryYellow,
            ),
          ),
          const SizedBox(height: 16),
          ...tiers.map((tier) => FareTierItem(
            tier: tier,
            isSelected: tier.id == _selectedTierId,
            onTap: () {
              setState(() {
                _selectedTierId = tier.id;
              });
            },
          )),
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
              onPressed: widget.onRequestRide,
              child: const Text(
                'Request TricyGo Ride',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}

