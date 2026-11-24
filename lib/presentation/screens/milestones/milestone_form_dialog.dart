import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/milestone_repository.dart';

/// Dialog for adding or editing a project milestone.
class MilestoneFormDialog extends StatefulWidget {
  final int projectId;
  final MilestoneModel? milestone;
  final MilestoneRepository? repository;

  const MilestoneFormDialog({
    super.key,
    required this.projectId,
    this.milestone,
    this.repository,
  });

  /// Displays the modal dialog to create or edit a milestone.
  static Future<bool?> show(
    BuildContext context, {
    required int projectId,
    MilestoneModel? milestone,
    MilestoneRepository? repository,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => MilestoneFormDialog(
        projectId: projectId,
        milestone: milestone,
        repository: repository,
      ),
    );
  }

  @override
  State<MilestoneFormDialog> createState() => _MilestoneFormDialogState();
}

class _MilestoneFormDialogState extends State<MilestoneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final MilestoneRepository _repository;
  bool _isLoading = false;

  bool get isEdit => widget.milestone != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MilestoneRepository();
    _nameController =
        TextEditingController(text: widget.milestone?.name ?? '');
    _descController =
        TextEditingController(text: widget.milestone?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      if (isEdit) {
        final updated = widget.milestone!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          updatedAt: now,
        );
        await _repository.updateMilestone(updated);
      } else {
        final newMilestone = MilestoneModel(
          projectId: widget.projectId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insertMilestone(newMilestone);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Tahapan berhasil diperbarui'
                : 'Tahapan berhasil ditambahkan',
            style: const TextStyle(color: AppColors.primaryText),
          ),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        isEdit ? 'Edit Tahapan' : 'Tambah Tahapan',
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tahapan *',
                  hintText: 'Contoh: Authentication & Database',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tahapan tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Keterangan target atau scope tahapan ini',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: AppColors.background,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Perbarui' : 'Simpan'),
        ),
      ],
    );
  }
}
