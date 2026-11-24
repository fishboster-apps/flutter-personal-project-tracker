import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/milestone_repository.dart';

/// Modal dialog for creating or editing an Issue / Problem.
class IssueFormDialog extends StatefulWidget {
  final int projectId;
  final int? initialMilestoneId;
  final IssueModel? issue;
  final IssueRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const IssueFormDialog({
    super.key,
    required this.projectId,
    this.initialMilestoneId,
    this.issue,
    this.repository,
    this.milestoneRepository,
  });

  /// Displays the modal dialog to create or edit an issue.
  static Future<bool?> show(
    BuildContext context, {
    required int projectId,
    int? initialMilestoneId,
    IssueModel? issue,
    IssueRepository? repository,
    MilestoneRepository? milestoneRepository,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => IssueFormDialog(
        projectId: projectId,
        initialMilestoneId: initialMilestoneId,
        issue: issue,
        repository: repository,
        milestoneRepository: milestoneRepository,
      ),
    );
  }

  @override
  State<IssueFormDialog> createState() => _IssueFormDialogState();
}

class _IssueFormDialogState extends State<IssueFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final IssueRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  List<MilestoneModel> _milestones = [];
  int? _selectedMilestoneId;
  bool _isLoading = false;

  bool get isEdit => widget.issue != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? IssueRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _titleController = TextEditingController(text: widget.issue?.title ?? '');
    _descController =
        TextEditingController(text: widget.issue?.description ?? '');
    _selectedMilestoneId =
        widget.issue?.milestoneId ?? widget.initialMilestoneId;
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    final list =
        await _milestoneRepository.getMilestonesByProjectId(widget.projectId);
    if (mounted) {
      setState(() => _milestones = list);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      if (isEdit) {
        final updated = widget.issue!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          milestoneId: _selectedMilestoneId,
          clearMilestoneId: _selectedMilestoneId == null,
          updatedAt: now,
        );
        await _repository.updateIssue(updated);
      } else {
        final newIssue = IssueModel(
          projectId: widget.projectId,
          milestoneId: _selectedMilestoneId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insertIssue(newIssue);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Masalah berhasil diperbarui' : 'Masalah berhasil dicatat',
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
        isEdit ? 'Edit Masalah & Kendala' : 'Catat Masalah & Kendala',
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
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Masalah / Bug *',
                  hintText: 'Contoh: Memory leak pada form upload',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul masalah tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kendala',
                  hintText: 'Keterangan error, reproduksi bug, atau catatan teknis',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _selectedMilestoneId,
                decoration: const InputDecoration(
                  labelText: 'Hubungkan ke Tahapan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tanpa Tahapan (Kendala Umum)'),
                  ),
                  ..._milestones.map((m) {
                    return DropdownMenuItem<int?>(
                      value: m.id,
                      child: Text(
                        '#${m.sortOrder + 1} ${m.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedMilestoneId = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
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
