import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'issue_form_dialog.dart';

/// Screen displaying the details and actions of a single Issue item.
class IssueDetailScreen extends StatefulWidget {
  final int issueId;
  final IssueRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const IssueDetailScreen({
    super.key,
    required this.issueId,
    this.repository,
    this.milestoneRepository,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late final IssueRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  IssueModel? _issue;
  MilestoneModel? _connectedMilestone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? IssueRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final issue = await _repository.getIssueById(widget.issueId);

    MilestoneModel? milestone;
    if (issue?.milestoneId != null) {
      milestone = await _milestoneRepository.getMilestoneById(issue!.milestoneId!);
    }

    if (mounted) {
      setState(() {
        _issue = issue;
        _connectedMilestone = milestone;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(bool isCompleted) async {
    if (_issue?.id == null) return;
    await _repository.toggleIssueCompletion(_issue!.id!, isCompleted);
    _loadData();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Masalah')),
        body: const Center(
          child: Text(
            'Masalah tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final issue = _issue!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(issue.title),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            issue.isCompleted ? 'Masalah Telah Teratasi' : 'Masalah Masih Aktif',
                            style: TextStyle(
                              color: issue.isCompleted
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _connectedMilestone != null
                                ? 'Tahapan: ${_connectedMilestone!.name}'
                                : 'Kendala Umum (Tanpa Tahapan)',
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
}
