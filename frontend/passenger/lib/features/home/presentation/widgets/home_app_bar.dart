
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/presentation/providers/home_providers.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  final VoidCallback onNotifications;

  const HomeAppBar({
    super.key,
    required this.onLogout,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInitial = ref.watch(userInitialProvider);
    
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.electric_bike, color: AppTheme.darkGray, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'TricyGo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.darkGray,
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active, color: AppTheme.primaryYellow),
          onPressed: onNotifications,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          onPressed: onLogout,
          tooltip: 'Logout',
        ),
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          color: AppTheme.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white10),
          ),
          onSelected: (value) {
            if (value == 'profile') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            } else if (value == 'history') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride history feature coming soon!')),
              );
            } else if (value == 'settings') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            } else if (value == 'logout') {
              onLogout();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryYellow,
              child: Text(
                userInitial,
                style: const TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Profile', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Ride History', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text('Settings', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

final userInitialProvider = Provider<String>((ref) {
  // This would normally come from SharedPreferences
  // For now, we'll return a default
  return 'U';
});

