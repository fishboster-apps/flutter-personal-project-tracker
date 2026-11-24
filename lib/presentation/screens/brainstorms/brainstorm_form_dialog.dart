import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/milestone_repository.dart';

/// Modal dialog for creating or editing a Brainstorm Idea.
class BrainstormFormDialog extends StatefulWidget {
  final int projectId;
  final int? initialMilestoneId;
  final BrainstormModel? brainstorm;
  final BrainstormRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const BrainstormFormDialog({
    super.key,
    required this.projectId,
    this.initialMilestoneId,
    this.brainstorm,
    this.repository,
    this.milestoneRepository,
  });

  /// Displays the modal dialog to create or edit an idea.
  static Future<bool?> show(
    BuildContext context, {
    required int projectId,
    int? initialMilestoneId,
    BrainstormModel? brainstorm,
    BrainstormRepository? repository,
    MilestoneRepository? milestoneRepository,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BrainstormFormDialog(
        projectId: projectId,
        initialMilestoneId: initialMilestoneId,
        brainstorm: brainstorm,
        repository: repository,
        milestoneRepository: milestoneRepository,
      ),
    );
  }

  @override
  State<BrainstormFormDialog> createState() => _BrainstormFormDialogState();
}

class _BrainstormFormDialogState extends State<BrainstormFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final BrainstormRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  List<MilestoneModel> _milestones = [];
  int? _selectedMilestoneId;
  bool _isLoading = false;

  bool get isEdit => widget.brainstorm != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BrainstormRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _titleController = TextEditingController(text: widget.brainstorm?.title ?? '');
    _descController =
        TextEditingController(text: widget.brainstorm?.description ?? '');
    _selectedMilestoneId =
        widget.brainstorm?.milestoneId ?? widget.initialMilestoneId;
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
        final updated = widget.brainstorm!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          milestoneId: _selectedMilestoneId,
          clearMilestoneId: _selectedMilestoneId == null,
          updatedAt: now,
        );
        await _repository.updateBrainstorm(updated);
      } else {
        final newBrainstorm = BrainstormModel(
          projectId: widget.projectId,
          milestoneId: _selectedMilestoneId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insertBrainstorm(newBrainstorm);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Ide berhasil diperbarui' : 'Ide berhasil ditambahkan',
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
        isEdit ? 'Edit Ide & Gagasan' : 'Tambah Ide & Gagasan',
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 15,
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
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Judul Ide *',
                  hintText: 'Contoh: Integrasi Google OAuth',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul ide tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Ide',
                  hintText: 'Catatan detail atau konsep ide ini',
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
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Tanpa Tahapan (Ide Bebas)',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryText),
                    ),
                  ),
                  ..._milestones.map((m) {
                    return DropdownMenuItem<int?>(
                      value: m.id,
                      child: Text(
                        '#${m.sortOrder + 1} ${m.name}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
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
