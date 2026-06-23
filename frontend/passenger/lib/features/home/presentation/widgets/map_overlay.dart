
import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class MapOverlay extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const MapOverlay({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showBackButton && onBackPressed != null)
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: AppTheme.darkGray.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              ),
            ),
          ),
      ],
    );
  }
}

