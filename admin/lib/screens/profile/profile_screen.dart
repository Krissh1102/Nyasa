import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _session?.name ?? 'Admin';
    final email = _session?.email ?? '';
    final role = _session?.role ?? '';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 14),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(email, style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      role,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuTile(icon: Icons.lock_outline_rounded, label: 'Change password', onTap: () {}),
          _MenuTile(icon: Icons.notifications_none_rounded, label: 'Notification settings', onTap: () {}),
          _MenuTile(icon: Icons.help_outline_rounded, label: 'Help & support', onTap: () {}),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Icon(icon, size: 18, color: danger ? AppColors.danger : AppColors.inkFaint),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color)),
                const Spacer(),
                if (!danger) const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.inkFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}