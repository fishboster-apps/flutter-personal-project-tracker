import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/reference_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../services/url_launcher_service.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'reference_form_dialog.dart';

/// Screen displaying the details and actions for a single reference link.
class ReferenceDetailScreen extends StatefulWidget {
  final int referenceId;
  final ReferenceRepository? repository;
  final BrainstormRepository? brainstormRepository;
  final IssueRepository? issueRepository;
  final UrlLauncherService? launcherService;

  const ReferenceDetailScreen({
    super.key,
    required this.referenceId,
    this.repository,
    this.brainstormRepository,
    this.issueRepository,
    this.launcherService,
  });

  @override
  State<ReferenceDetailScreen> createState() => _ReferenceDetailScreenState();
}

class _ReferenceDetailScreenState extends State<ReferenceDetailScreen> {
  late final ReferenceRepository _repository;
  late final BrainstormRepository _brainstormRepository;
  late final IssueRepository _issueRepository;
  late final UrlLauncherService _launcherService;

  ReferenceModel? _reference;
  BrainstormModel? _connectedBrainstorm;
  IssueModel? _connectedIssue;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReferenceRepository();
    _brainstormRepository = widget.brainstormRepository ?? BrainstormRepository();
    _issueRepository = widget.issueRepository ?? IssueRepository();
    _launcherService = widget.launcherService ?? const UrlLauncherService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final reference = await _repository.getReferenceById(widget.referenceId);

    BrainstormModel? brainstorm;
    IssueModel? issue;

    if (reference?.brainstormId != null) {
      brainstorm =
          await _brainstormRepository.getBrainstormById(reference!.brainstormId!);
    } else if (reference?.issueId != null) {
      issue = await _issueRepository.getIssueById(reference!.issueId!);
    }

    if (mounted) {
      setState(() {
        _reference = reference;
        _connectedBrainstorm = brainstorm;
        _connectedIssue = issue;
        _isLoading = false;
      });
    }
  }

  void _confirmDelete() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Hapus Referensi',
      message: 'Apakah Anda yakin ingin menghapus referensi "${_reference?.title}"?',
      confirmLabel: 'Hapus Referensi',
      onConfirm: () async {
        if (_reference?.id != null) {
          await _repository.deleteReference(_reference!.id!);
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Referensi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ref = _reference;
    if (ref == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Referensi')),
        body: const Center(
          child: Text(
            'Tautan referensi tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Referensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Referensi',
            onPressed: () async {
              final updated = await ReferenceFormDialog.show(
                context,
                projectId: ref.projectId,
                reference: ref,
                repository: _repository,
                brainstormRepository: _brainstormRepository,
                issueRepository: _issueRepository,
              );
              if (updated == true) {
                _loadData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Referensi',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          Text(
            ref.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          const SizedBox(height: 12),

          // Relation Badge
          _buildRelationBadge(),
          const SizedBox(height: 16),

          // URL Card
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, size: 20, color: AppColors.primaryAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Alamat Tautan Web',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    ref.url,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launcherService.openUrl(ref.url, context: context),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Buka di Browser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            foregroundColor: AppColors.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => UrlLauncherService.copyToClipboard(ref.url, context: context),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Salin Tautan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryText,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          if (ref.notes != null && ref.notes!.isNotEmpty) ...[
            Text(
              'Catatan Tambahan',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                ref.notes!,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Timestamps
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dibuat:',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                      ),
                      Text(
                        dateFormat.format(ref.createdAt),
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Terakhir Diperbarui:',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                      ),
                      Text(
                        dateFormat.format(ref.updatedAt),
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationBadge() {
    if (_connectedBrainstorm != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primaryAccent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Terkait Ide: ${_connectedBrainstorm!.title}',
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (_connectedIssue != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bug_report_outlined, size: 16, color: AppColors.warning),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Terkait Kendala: ${_connectedIssue!.title}',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 16, color: AppColors.secondaryText),
          SizedBox(width: 6),
          Text(
            'Tautan Umum Proyek (Bebas)',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
