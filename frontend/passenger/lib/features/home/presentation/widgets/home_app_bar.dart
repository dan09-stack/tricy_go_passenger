import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userInitial;
  final VoidCallback onLogout;
  final VoidCallback onNotification;

  const HomeAppBar({
    super.key,
    required this.userInitial,
    required this.onLogout,
    required this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text('TricyGo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      backgroundColor: AppTheme.darkGray,
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active, color: AppTheme.primaryYellow),
          onPressed: onNotification,
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
            if (value == 'logout') {
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