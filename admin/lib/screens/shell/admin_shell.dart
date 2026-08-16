import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../analytics/analytics_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../orders/orders_screen.dart';
import '../settings/settings_screen.dart';


class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _destinations = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  static const _screens = [
    DashboardScreen(),
    AnalyticsScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _SideRail(index: _index, items: _destinations, onSelect: (i) => setState(() => _index = i)),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: _screens[_index]),
              ],
            ),
          );
        }

        return Scaffold(
          body: _screens[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: _destinations.map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label)).toList(),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SideRail extends StatelessWidget {
  final int index;
  final List<_NavItem> items;
  final ValueChanged<int> onSelect;

  const _SideRail({required this.index, required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.diamond_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Aura Jewels', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (int i = 0; i < items.length; i++)
            _RailTile(item: items[i], selected: i == index, onTap: () => onSelect(i)),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _RailTile({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: selected ? Colors.white : AppColors.inkSoft),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
