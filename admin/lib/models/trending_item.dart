import 'package:flutter/material.dart';

class TrendingItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final int salesCount;
  final double changePercent; // positive or negative

  const TrendingItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.salesCount,
    required this.changePercent,
  });

  bool get isUp => changePercent >= 0;
}
