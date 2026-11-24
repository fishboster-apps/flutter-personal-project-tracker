import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/models/reference_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../services/copy_context_service.dart';
import '../../../services/url_launcher_service.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../references/reference_detail_screen.dart';
import '../references/reference_form_dialog.dart';
import 'issue_form_dialog.dart';

/// Screen displaying the details and actions of a single Issue / technical problem.
class IssueDetailScreen extends StatefulWidget {
  final int issueId;
  final IssueRepository? repository;
  final MilestoneRepository? milestoneRepository;
  final ReferenceRepository? referenceRepository;
  final UrlLauncherService? launcherService;
  final CopyContextService? copyContextService;

  const IssueDetailScreen({
    super.key,
    required this.issueId,
    this.repository,
    this.milestoneRepository,
    this.referenceRepository,
    this.launcherService,
    this.copyContextService,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late final IssueRepository _repository;
  late final MilestoneRepository _milestoneRepository;
  late final ReferenceRepository _referenceRepository;
  late final UrlLauncherService _launcherService;
  late final CopyContextService _copyContextService;

  IssueModel? _issue;
  MilestoneModel? _connectedMilestone;
  List<ReferenceModel> _references = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? IssueRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _referenceRepository = widget.referenceRepository ?? ReferenceRepository();
    _launcherService = widget.launcherService ?? const UrlLauncherService();
    _copyContextService = widget.copyContextService ??
        CopyContextService(
          issueRepository: _repository,
          milestoneRepository: _milestoneRepository,
          referenceRepository: _referenceRepository,
        );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final issue = await _repository.getIssueById(widget.issueId);

    MilestoneModel? milestone;
    if (issue?.milestoneId != null) {
      milestone = await _milestoneRepository.getMilestoneById(issue!.milestoneId!);
    }

    List<ReferenceModel> references = [];
    try {
      references = await _referenceRepository.getReferencesByIssueId(widget.issueId);
    } catch (_) {
      // Keep empty if failed
    }

    if (mounted) {
      setState(() {
        _issue = issue;
        _connectedMilestone = milestone;
        _references = references;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(bool isCompleted) async {
    if (_issue?.id == null) return;
    await _repository.toggleIssueCompletion(_issue!.id!, isCompleted);
    _loadData();
  }

  Future<void> _copyIssueContext() async {
    if (_issue?.id == null) return;
    try {
      final contextText =
          await _copyContextService.generateIssueContext(_issue!.id!);
      if (!mounted) return;
      await _copyContextService.copyToClipboard(
        context,
        contextText,
        successMessage: 'Konteks masalah berhasil disalin ke clipboard',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyalin konteks: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDelete() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Hapus Masalah',
      message: 'Apakah Anda yakin ingin menghapus masalah "${_issue?.title}"?',
      confirmLabel: 'Hapus Masalah',
      onConfirm: () async {
        if (_issue?.id != null) {
          await _repository.deleteIssue(_issue!.id!);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Masalah berhasil dihapus',
                style: TextStyle(color: AppColors.primaryText),
              ),
              backgroundColor: AppColors.surfaceElevated,
            ),
          );

          Navigator.pop(context, true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Masalah & Kendala')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final issue = _issue;
    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Masalah & Kendala')),
        body: const Center(
          child: Text(
            'Kendala tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Masalah & Kendala'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: 'Salin Konteks Masalah',
            onPressed: _copyIssueContext,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Masalah',
            onPressed: () async {
              final updated = await IssueFormDialog.show(
                context,
                projectId: issue.projectId,
                issue: issue,
                repository: _repository,
                milestoneRepository: _milestoneRepository,
              );
              if (updated == true) {
                _loadData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Masalah',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title & Status
            Text(
              issue.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
            ),
            const SizedBox(height: 12),

            // Status and Completion Toggle Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: issue.isCompleted,
                      activeColor: AppColors.primaryAccent,
                      checkColor: AppColors.background,
                      onChanged: (val) {
                        if (val != null) {
                          _toggleComplete(val);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            issue.isCompleted ? 'Kendala Selesai / Teratasi' : 'Kendala Masih Terjadi',
                            style: TextStyle(
                              color: issue.isCompleted
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _connectedMilestone != null
                                ? 'Tahapan: ${_connectedMilestone!.name}'
                                : 'Kendala Bebas (Tanpa Tahapan)',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            if (issue.description.isNotEmpty) ...[
              Text(
                'Deskripsi Kendala',
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
                  issue.description,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Referensi Terkait Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Referensi Terkait (${_references.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final added = await ReferenceFormDialog.show(
                      context,
                      projectId: issue.projectId,
                      initialIssueId: issue.id,
                      repository: _referenceRepository,
                      issueRepository: _repository,
                    );
                    if (added == true) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Tautan'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_references.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Belum ada referensi tautan untuk kendala ini.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
              )
            else
              ..._references.map((ref) => _buildReferenceItem(ref)),

            const SizedBox(height: 16),

            // Metadata: Created & Updated
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dibuat: ${dateFormat.format(issue.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceItem(ReferenceModel ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          ref.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        ),
        subtitle: Text(
          ref.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryAccent),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 16, color: AppColors.secondaryText),
              tooltip: 'Salin',
              onPressed: () => UrlLauncherService.copyToClipboard(ref.url, context: context),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primaryAccent),
              tooltip: 'Buka',
              onPressed: () => _launcherService.openUrl(ref.url, context: context),
            ),
          ],
        ),
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ReferenceDetailScreen(
                referenceId: ref.id!,
                repository: _referenceRepository,
                issueRepository: _repository,
                launcherService: _launcherService,
              ),
            ),
          );
          if (deleted == true || mounted) {
            _loadData();
          }
        },
      ),
    );
  }
}
