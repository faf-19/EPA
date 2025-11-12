import 'package:flutter/material.dart';

class BottomNavItemData {
  final IconData icon;
  final String label;

  const BottomNavItemData({
    required this.icon,
    required this.label,
  });
}

const Color bottomNavActiveColor = Color(0xFF1EA04A);
const Color bottomNavInactiveColor = Colors.white70;

const List<BottomNavItemData> bottomNavItems = [
  BottomNavItemData(icon: Icons.home_outlined, label: 'Home'),
  BottomNavItemData(icon: Icons.map_outlined, label: 'Office'),
  BottomNavItemData(icon: Icons.people_outline, label: 'Community'),
  BottomNavItemData(icon: Icons.monitor_heart_outlined, label: 'Status'),
  BottomNavItemData(icon: Icons.person_outline, label: 'Profile'),
];

