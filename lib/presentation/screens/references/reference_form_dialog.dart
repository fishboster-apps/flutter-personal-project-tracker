import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/reference_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../services/url_launcher_service.dart';

/// Dialog for creating or editing a Reference item with exclusive relation linking.
class ReferenceFormDialog extends StatefulWidget {
  final int projectId;
  final ReferenceModel? reference;
  final int? initialBrainstormId;
  final int? initialIssueId;
  final ReferenceRepository? repository;
  final BrainstormRepository? brainstormRepository;
  final IssueRepository? issueRepository;

  const ReferenceFormDialog({
    super.key,
    required this.projectId,
    this.reference,
    this.initialBrainstormId,
    this.initialIssueId,
    this.repository,
    this.brainstormRepository,
    this.issueRepository,
  });

  /// Shows the dialog and returns true if saved.
  static Future<bool?> show(
    BuildContext context, {
    required int projectId,
    ReferenceModel? reference,
    int? initialBrainstormId,
    int? initialIssueId,
    ReferenceRepository? repository,
    BrainstormRepository? brainstormRepository,
    IssueRepository? issueRepository,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReferenceFormDialog(
        projectId: projectId,
        reference: reference,
        initialBrainstormId: initialBrainstormId,
        initialIssueId: initialIssueId,
        repository: repository,
        brainstormRepository: brainstormRepository,
        issueRepository: issueRepository,
      ),
    );
  }

  @override
  State<ReferenceFormDialog> createState() => _ReferenceFormDialogState();
}

class _ReferenceFormDialogState extends State<ReferenceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;

  late final ReferenceRepository _repository;
  late final BrainstormRepository _brainstormRepository;
  late final IssueRepository _issueRepository;

  List<BrainstormModel> _brainstorms = [];
  List<IssueModel> _issues = [];

  // Dropdown value encodes relation: "none", "b_<id>", or "i_<id>"
  String _selectedRelationKey = 'none';
  bool _isLoading = false;

  bool get isEdit => widget.reference != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReferenceRepository();
    _brainstormRepository = widget.brainstormRepository ?? BrainstormRepository();
    _issueRepository = widget.issueRepository ?? IssueRepository();

    _titleController = TextEditingController(text: widget.reference?.title ?? '');
    _urlController = TextEditingController(text: widget.reference?.url ?? '');
    _notesController = TextEditingController(text: widget.reference?.notes ?? '');

    // Set initial relation
    if (widget.reference?.brainstormId != null) {
      _selectedRelationKey = 'b_${widget.reference!.brainstormId}';
    } else if (widget.reference?.issueId != null) {
      _selectedRelationKey = 'i_${widget.reference!.issueId}';
    } else if (widget.initialBrainstormId != null) {
      _selectedRelationKey = 'b_${widget.initialBrainstormId}';
    } else if (widget.initialIssueId != null) {
      _selectedRelationKey = 'i_${widget.initialIssueId}';
    }

    _loadRelatedEntities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRelatedEntities() async {
    try {
      final brainstorms =
          await _brainstormRepository.getBrainstormsByProjectId(widget.projectId);
      final issues =
          await _issueRepository.getIssuesByProjectId(widget.projectId);

      if (mounted) {
        setState(() {
          _brainstorms = brainstorms;
          _issues = issues;
        });
      }
    } catch (_) {
      // Continue even if related items fail to load
    }
  }

  int? get _selectedBrainstormId {
    if (_selectedRelationKey.startsWith('b_')) {
      return int.tryParse(_selectedRelationKey.substring(2));
    }
    return null;
  }

  int? get _selectedIssueId {
    if (_selectedRelationKey.startsWith('i_')) {
      return int.tryParse(_selectedRelationKey.substring(2));
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final sanitizedUrl = UrlLauncherService.sanitizeUrl(_urlController.text);
      final notesText = _notesController.text.trim();

      if (isEdit) {
        final updated = widget.reference!.copyWith(
          title: _titleController.text.trim(),
          url: sanitizedUrl,
          notes: notesText.isEmpty ? null : notesText,
          clearNotes: notesText.isEmpty,
          brainstormId: _selectedBrainstormId,
          clearBrainstormId: _selectedBrainstormId == null,
          issueId: _selectedIssueId,
          clearIssueId: _selectedIssueId == null,
          updatedAt: now,
        );
        await _repository.updateReference(updated);
      } else {
        final newReference = ReferenceModel(
          projectId: widget.projectId,
          brainstormId: _selectedBrainstormId,
          issueId: _selectedIssueId,
          title: _titleController.text.trim(),
          url: sanitizedUrl,
          notes: notesText.isEmpty ? null : notesText,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insertReference(newReference);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Tautan referensi berhasil diperbarui'
                : 'Tautan referensi berhasil ditambahkan',
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
    // Verify valid selection among options
    final validOptions = <String>{'none'};
    for (final b in _brainstorms) {
      if (b.id != null) validOptions.add('b_${b.id}');
    }
    for (final i in _issues) {
      if (i.id != null) validOptions.add('i_${i.id}');
    }
    final effectiveValue =
        validOptions.contains(_selectedRelationKey) ? _selectedRelationKey : 'none';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        isEdit ? 'Edit Tautan Referensi' : 'Tambah Tautan Referensi',
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
              // Judul Referensi
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Judul Referensi *',
                  hintText: 'Contoh: Dokumentasi Flutter SQLite',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul referensi tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Alamat Tautan (URL)
              TextFormField(
                controller: _urlController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Alamat Tautan / URL Web *',
                  hintText: 'https://github.com/... atau docs.flutter.dev',
                  helperText: 'Awali dengan https:// atau alamat web yang valid',
                  helperMaxLines: 2,
                ),
                keyboardType: TextInputType.url,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Tautan URL web tidak boleh kosong';
                  }
                  if (!UrlLauncherService.isValidUrl(val)) {
                    return 'Format tautan tidak valid. Masukkan alamat web yang benar (contoh: https://...)';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Dropdown Relasi Eksklusif
              DropdownButtonFormField<String>(
                initialValue: effectiveValue,
                decoration: const InputDecoration(
                  labelText: 'Hubungkan Tautan ke',
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: 'none',
                    child: Text(
                      'Tautan Umum Proyek (Bebas / Standalone)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.primaryText),
                    ),
                  ),
                  if (_brainstorms.isNotEmpty) ...[
                    ..._brainstorms.map((b) {
                      return DropdownMenuItem(
                        value: 'b_${b.id}',
                        child: Text(
                          'Ide: ${b.title}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryAccent),
                        ),
                      );
                    }),
                  ],
                  if (_issues.isNotEmpty) ...[
                    ..._issues.map((i) {
                      return DropdownMenuItem(
                        value: 'i_${i.id}',
                        child: Text(
                          'Kendala: ${i.title}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.warning),
                        ),
                      );
                    }),
                  ],
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRelationKey = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Catatan Tambahan (Opsional)
              TextFormField(
                controller: _notesController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  hintText: 'Catatan penting mengenai isi tautan...',
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
