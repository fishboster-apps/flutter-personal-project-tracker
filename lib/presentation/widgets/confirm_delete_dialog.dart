import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Reusable confirmation dialog for delete operations.
class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Hapus',
    this.cancelLabel = 'Batal',
    required this.onConfirm,
  });

  /// Displays the confirmation dialog and invokes [onConfirm] if confirmed.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Hapus',
    String cancelLabel = 'Batal',
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.primaryText,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
