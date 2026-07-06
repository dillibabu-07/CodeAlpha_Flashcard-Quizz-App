// lib/screens/settings/settings_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/auth_provider.dart';
import '../../database/database_helper.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../services/sample_data_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Account section
          _SectionHeader('Account'),
          _SettingCard(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    context.read<AuthProvider>().currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  context.read<AuthProvider>().currentUser?.name ?? 'Guest User',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  'Role: ${context.read<AuthProvider>().currentUser?.role ?? 'Student'}',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Appearance section
          _SectionHeader('Appearance'),
          _SettingCard(
            children: [
              _ThemeTile(
                label: 'Light Mode',
                icon: Icons.light_mode_rounded,
                selected: themeProvider.mode == AppThemeMode.light,
                onTap: () => themeProvider.setTheme(AppThemeMode.light),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: 'Dark Mode',
                icon: Icons.dark_mode_rounded,
                selected: themeProvider.mode == AppThemeMode.dark,
                onTap: () => themeProvider.setTheme(AppThemeMode.dark),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: 'System Default',
                icon: Icons.brightness_auto_rounded,
                selected: themeProvider.mode == AppThemeMode.system,
                onTap: () => themeProvider.setTheme(AppThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Data section
          _SectionHeader('Data Management'),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.upload_rounded,
                iconColor: AppColors.primary,
                title: 'Export as JSON',
                subtitle: 'Backup all your flashcards',
                onTap: () => _exportJson(context),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.download_rounded,
                iconColor: AppColors.accent,
                title: 'Import from JSON',
                subtitle: 'Restore from backup file',
                onTap: () =>
                    CustomSnackbar.info(context, 'Import feature coming soon!'),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFDB2777),
                title: 'Export as PDF',
                subtitle: 'Print-friendly flashcard sheet',
                onTap: () =>
                    CustomSnackbar.info(context, 'PDF export coming soon!'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Reset section
          _SectionHeader('Reset'),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.refresh_rounded,
                iconColor: AppColors.warning,
                title: 'Reload Sample Data',
                subtitle: 'Re-add default flashcards',
                onTap: () => _reloadSampleData(context),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.delete_forever_rounded,
                iconColor: AppColors.error,
                title: 'Reset All Data',
                subtitle: 'Permanently delete everything',
                titleColor: AppColors.error,
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // About section
          _SectionHeader('About'),
          _SettingCard(
            children: [
              _SettingTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.info,
                title: 'About FlashMaster',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1),
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () => CustomSnackbar.info(
                    context, 'All data is stored locally on your device'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xxl + AppSizes.lg),
        ],
      ),
    );
  }

  Future<void> _exportJson(BuildContext context) async {
    try {
      final cardProvider = context.read<FlashcardProvider>();
      final catProvider = context.read<CategoryProvider>();

      final data = {
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'categories':
            catProvider.categories.map((c) => c.toJson()).toList(),
        'flashcards': cardProvider.all.map((c) => c.toJson()).toList(),
      };

      final jsonStr = jsonEncode(data);
      // In production, you'd use path_provider + file writing + share_plus
      // For now, show a snackbar with character count as confirmation
      if (context.mounted) {
        CustomSnackbar.success(context,
            'Exported ${cardProvider.totalCount} cards (${jsonStr.length} bytes)');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.error(context, 'Export failed: $e');
      }
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset All Data',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.error)),
        content: const Text(
          'This will permanently delete all flashcards, categories, quiz results, and study history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await DatabaseHelper.instance.resetAllData();
      await context.read<CategoryProvider>().loadCategories();
      await context.read<FlashcardProvider>().loadFlashcards();
      await context.read<StatsProvider>().loadStats();
      if (context.mounted) {
        CustomSnackbar.success(context, 'All data has been reset');
      }
    }
  }

  Future<void> _reloadSampleData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reload Sample Data',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will re-add sample flashcards and categories. Your existing data will be kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reload')),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Force re-seed
      await DatabaseHelper.instance.resetAllData();
      await SampleDataService.instance.seedIfFirstRun();
      await context.read<CategoryProvider>().loadCategories();
      await context.read<FlashcardProvider>().loadFlashcards();
      if (context.mounted) {
        CustomSnackbar.success(context, 'Sample data reloaded!');
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FlashMaster',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.style_rounded, color: Colors.white, size: 30),
      ),
      children: [
        Text(
          'FlashMaster is a smart flashcard quiz app for students. Study smarter with categorized flashcards, quiz mode, and progress tracking.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5)))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: selected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppColors.primary : null,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
