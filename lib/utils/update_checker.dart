import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

import 'package:gold/widgets/snackbar_utils.dart';

class UpdateChecker {
  static const String GITHUB_API =
      'https://api.github.com/repos/bloodh73/gold/releases/latest';

  static Future<void> checkForUpdate(BuildContext context) async {
    // نمایش دیالوگ با نوار پیشرفت
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Checking for updates...'),
            ],
          ),
        );
      },
    );

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await Dio().get(GITHUB_API);
      final latestVersion = response.data['tag_name'].toString().replaceAll(
        'v',
        '',
      );
      final downloadUrl = response.data['assets']?[0]?['browser_download_url'];
      final changelog = response.data['body'] ?? '';
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // بستن دیالوگ نوار پیشرفت
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (_isNewVersionAvailable(currentVersion, latestVersion)) {
        // نمایش دیالوگ به‌روزرسانی موجود
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
                    width: 1,
                  ),
                ),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue[900] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.system_update_rounded,
                        color: isDark ? Colors.blue[300] : Colors.blue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Update Available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVersionInfo(
                        currentVersion: currentVersion,
                        latestVersion: latestVersion,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      if (changelog.isNotEmpty) ...[
                        Text(
                          'What\'s New:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            changelog,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (downloadUrl != null) {
                        try {
                          Navigator.of(context).pop();

                          if (context.mounted) {
                            SnackBarUtils.showSuccess(
                              context,
                              message: 'Download started in your browser',
                              icon: Icons.download_done,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            SnackBarUtils.showError(
                              context,
                              message: 'Failed to open download link',
                              actionLabel: 'RETRY',
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_rounded, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Download Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              );
            },
          );
        }
      } else {
        // نمایش snackbar برای اعلام به‌روز بودن برنامه
        if (context.mounted) {
          SnackBarUtils.showSuccess(
            context,
            message: 'You are using the latest version ($currentVersion)',
            duration: const Duration(seconds: 4),
            icon: Icons.check_circle_outline,
          );
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // بستن دیالوگ نوار پیشرفت در صورت خطا
        SnackBarUtils.showError(
          context,
          message: 'Failed to check for updates',
          actionLabel: 'RETRY',
          onActionPressed: () => checkForUpdate(context),
        );
      }
    }
  }

  static Widget _buildVersionInfo({
    required String currentVersion,
    required String latestVersion,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVersionRow(
            'Current Version',
            currentVersion,
            isDark,
            Icons.phone_android_rounded,
          ),
          const SizedBox(height: 12),
          _buildVersionRow(
            'Latest Version',
            latestVersion,
            isDark,
            Icons.new_releases_rounded,
          ),
        ],
      ),
    );
  }

  static Widget _buildVersionRow(
    String label,
    String version,
    bool isDark,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: isDark ? Colors.blue[300] : Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        const Spacer(),
        Text(
          version,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  static bool _isNewVersionAvailable(
    String currentVersion,
    String latestVersion,
  ) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }
}
