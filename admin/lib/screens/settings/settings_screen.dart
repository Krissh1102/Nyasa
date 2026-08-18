import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthSession? _session;
  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = await AuthService.instance.getSession();
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = _session?.name ?? 'Admin';
    final email = _session?.email ?? '';
    final role = _session?.role ?? '';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Account'),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change password',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notification settings',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & support',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: _loggingOut ? 'Logging out...' : 'Log out',
            danger: true,
            onTap: _loggingOut ? () {} : _logout,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.inkFaint,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final int? trailingCount;
  final String? trailingLabel;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.trailingCount,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: danger
                        ? AppColors.danger.withValues(alpha: 0.08)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: danger ? AppColors.danger : AppColors.inkSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (trailingCount != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      trailingLabel != null
                          ? '$trailingCount $trailingLabel'
                          : '$trailingCount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkFaint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!danger)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.inkFaint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
