import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';

/// Helper service for validating, sanitizing, opening external URLs, and copying links.
class UrlLauncherService {
  final Future<bool> Function(Uri url, LaunchMode mode)? customLauncher;

  const UrlLauncherService({
    this.customLauncher,
  });

  /// Sanitizes input URL string by trimming and adding https:// if missing.
  static String sanitizeUrl(String rawUrl) {
    String trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    // If starts with http:// or https://, keep as is
    if (trimmed.startsWith(RegExp(r'^https?:\/\/', caseSensitive: false))) {
      return trimmed;
    }

    // Default to https://
    return 'https://$trimmed';
  }

  /// Validates whether the given string is a plausible web URL.
  static bool isValidUrl(String rawUrl) {
    final sanitized = sanitizeUrl(rawUrl);
    final uri = Uri.tryParse(sanitized);
    if (uri == null) return false;

    // Must have http or https scheme and a valid host containing at least one dot
    final hasValidScheme = uri.isScheme('http') || uri.isScheme('https');
    final hasValidHost = uri.hasAuthority && uri.host.contains('.') && !uri.host.endsWith('.');

    return hasValidScheme && hasValidHost;
  }

  /// Opens an external URL in the device's default browser.
  /// If opening fails and [context] is provided, a SnackBar is shown.
  Future<bool> openUrl(
    String rawUrl, {
    BuildContext? context,
  }) async {
    final sanitized = sanitizeUrl(rawUrl);
    final uri = Uri.tryParse(sanitized);

    if (uri == null || !isValidUrl(rawUrl)) {
      if (context != null && context.mounted) {
        _showErrorSnackBar(
          context,
          'Format tautan tidak valid. Masukkan alamat web yang benar (contoh: https://...)',
        );
      }
      return false;
    }

    try {
      bool launched = false;
      final launcher = customLauncher;
      if (launcher != null) {
        launched = await launcher(uri, LaunchMode.externalApplication);
      } else {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      if (!launched && context != null && context.mounted) {
        _showErrorSnackBar(
          context,
          'Tidak dapat membuka tautan. Pastikan alamat web valid dan peramban (browser) tersedia.',
        );
      }
      return launched;
    } catch (_) {
      if (context != null && context.mounted) {
        _showErrorSnackBar(
          context,
          'Tidak dapat membuka tautan. Pastikan alamat web valid dan peramban (browser) tersedia.',
        );
      }
      return false;
    }
  }

  /// Copies text (such as a URL) to the system clipboard and notifies the user.
  static Future<void> copyToClipboard(
    String text, {
    required BuildContext context,
    String message = 'Tautan berhasil disalin ke papan klip',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.primaryText),
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
