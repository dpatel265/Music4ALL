import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/toast_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _highQualityAudio = true;
  bool _darkMode = true;
  bool _autoPlay = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Playback'),
          _buildSwitchTile(
            'High Quality Audio',
            'Stream audio in highest available bitrate',
            _highQualityAudio,
            (val) => setState(() => _highQualityAudio = val),
          ),
          _buildSwitchTile(
            'Autoplay',
            'Continue playing similar music',
            _autoPlay,
            (val) => setState(() => _autoPlay = val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme',
            _darkMode,
            (val) => setState(() => _darkMode = val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Storage'),
          ListTile(
            title: const Text(
              'Clear Cache',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Free up space by clearing cached images',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.delete_outline, color: Colors.grey),
            onTap: () async {
              try {
                await DefaultCacheManager().emptyCache();
                if (context.mounted) {
                  ToastService.showSuccess(
                    context,
                    'Cache cleared successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ToastService.showError(context, 'Failed to clear cache: $e');
                }
              }
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Version', style: TextStyle(color: Colors.white)),
            subtitle: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
