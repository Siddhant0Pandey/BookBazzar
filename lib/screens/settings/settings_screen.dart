// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Shop profile card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🏪', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.ownerName, style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 17,
                        color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(provider.shopName, style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Language section ──────────────────────────────────────
          _SectionLabel(label: 'Preferences'),
          const SizedBox(height: 8),
          _SettingsCard(children: [
            _SettingRow(
              icon: Icons.language_rounded,
              label: l.language,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LangChip(
                    label: 'EN',
                    active: provider.language == 'en',
                    onTap: () => provider.setLanguage('en'),
                  ),
                  const SizedBox(width: 6),
                  _LangChip(
                    label: 'नेपाली',
                    active: provider.language == 'ne',
                    onTap: () => provider.setLanguage('ne'),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── App info section ─────────────────────────────────────
          _SectionLabel(label: 'About'),
          const SizedBox(height: 8),
          _SettingsCard(children: [
            _SettingRow(
              icon: Icons.info_outline_rounded,
              label: 'BookBaazar',
              trailing: const Text('v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
            ),
            _Divider(),
            _SettingRow(
              icon: Icons.storage_rounded,
              label: 'Storage',
              trailing: const Text('Local (Offline)',
                style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Danger zone ──────────────────────────────────────────
          _SectionLabel(label: 'Account'),
          const SizedBox(height: 8),
          _SettingsCard(children: [
            // Logout
            _SettingRow(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              iconColor: AppColors.warning,
              labelColor: AppColors.warning,
              onTap: () => _confirmLogout(context, provider),
            ),
            _Divider(),
            // Reset all data
            _SettingRow(
              icon: Icons.delete_forever_rounded,
              label: 'Reset All Data',
              iconColor: AppColors.danger,
              labelColor: AppColors.danger,
              onTap: () => _confirmReset(context, l, provider),
            ),
          ]),
          const SizedBox(height: 32),

          // Version footer
          const Center(
            child: Text('BookBaazar · Made for Street Vendors',
              style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'You will be taken back to the setup screen. '
          'Your data will remain saved on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/register', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext ctx, AppLocalizations l,
      AppProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Reset All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL products, sales, '
          'customers and credits. This cannot be undone!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await provider.resetAllData();
              if (ctx.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    ctx, '/', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 0.5));
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon, required this.label,
    this.trailing, this.iconColor, this.labelColor, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: labelColor ?? AppColors.textPrimary)),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 50, color: AppColors.divider);
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _LangChip({
    required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          color: active ? Colors.white : AppColors.textSecondary,
          fontSize: 12.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
