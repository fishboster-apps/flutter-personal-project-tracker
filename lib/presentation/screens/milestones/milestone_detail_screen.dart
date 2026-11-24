import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../brainstorms/brainstorm_detail_screen.dart';
import '../brainstorms/brainstorm_form_dialog.dart';
import '../issues/issue_detail_screen.dart';
import '../issues/issue_form_dialog.dart';
import 'milestone_form_dialog.dart';

/// Screen displaying the details of a single milestone and its linked ideas and issues.
class MilestoneDetailScreen extends StatefulWidget {
  final int milestoneId;
  final MilestoneRepository? repository;
  final BrainstormRepository? brainstormRepository;
  final IssueRepository? issueRepository;

  const MilestoneDetailScreen({
    super.key,
    required this.milestoneId,
    this.repository,
    this.brainstormRepository,
    this.issueRepository,
  });

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> {
  late final MilestoneRepository _repository;
  late final BrainstormRepository _brainstormRepository;
  late final IssueRepository _issueRepository;

  MilestoneModel? _milestone;
  List<BrainstormModel> _relatedBrainstorms = [];
  List<IssueModel> _relatedIssues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MilestoneRepository();
    _brainstormRepository = widget.brainstormRepository ?? BrainstormRepository();
    _issueRepository = widget.issueRepository ?? IssueRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final milestone = await _repository.getMilestoneById(widget.milestoneId);

    List<BrainstormModel> brainstorms = [];
    List<IssueModel> issues = [];

    if (milestone != null) {
      brainstorms = await _brainstormRepository.getBrainstormsByProjectId(
        milestone.projectId,
        milestoneId: milestone.id,
      );
      issues = await _issueRepository.getIssuesByProjectId(
        milestone.projectId,
        milestoneId: milestone.id,
      );
    }

    if (mounted) {
      setState(() {
        _milestone = milestone;
        _relatedBrainstorms = brainstorms;
        _relatedIssues = issues;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(bool value) async {
    if (_milestone?.id == null) return;
    await _repository.toggleMilestoneCompletion(_milestone!.id!, value);
    _loadData();
  }

  void _confirmDelete() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Hapus Tahapan',
      message:
          'Apakah Anda yakin ingin menghapus tahapan "${_milestone?.name}"? Ide dan masalah terkait akan tetap tersimpan.',
      confirmLabel: 'Hapus Tahapan',
      onConfirm: () async {
        if (_milestone?.id != null) {
          await _repository.deleteMilestone(_milestone!.id!);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tahapan berhasil dihapus',
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

    if (_milestone == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tahapan')),
        body: const Center(
          child: Text(
            'Tahapan tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final milestone = _milestone!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(milestone.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Tahapan',
            onPressed: () async {
              final updated = await MilestoneFormDialog.show(
                context,
                projectId: milestone.projectId,
                milestone: milestone,
                repository: _repository,
              );
              if (updated == true) {
                _loadData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Tahapan',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Sort Order Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: milestone.isCompleted,
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
                            milestone.isCompleted ? 'Selesai' : 'Belum Selesai',
                            style: TextStyle(
                              color: milestone.isCompleted
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Urutan #${milestone.sortOrder + 1}',
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
            if (milestone.description.isNotEmpty) ...[
              Text(
                'Deskripsi',
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
                  milestone.description,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Created timestamp
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dibuat: ${dateFormat.format(milestone.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            // 1. Related Ideas Section
            Row(
              children: [
                Text(
                  'Ide & Gagasan Terkait (${_relatedBrainstorms.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20, color: AppColors.primaryAccent),
                  tooltip: 'Tambah Ide di Tahapan Ini',
                  onPressed: () async {
                    final added = await BrainstormFormDialog.show(
                      context,
                      projectId: milestone.projectId,
                      initialMilestoneId: milestone.id,
                      repository: _brainstormRepository,
                      milestoneRepository: _repository,
                    );
                    if (added == true) {
                      _loadData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_relatedBrainstorms.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Belum ada ide yang terhubung ke tahapan ini.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
              )
            else
              ..._relatedBrainstorms.map((idea) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: idea.isCompleted,
                      activeColor: AppColors.primaryAccent,
                      checkColor: AppColors.background,
                      onChanged: (val) async {
                        if (val != null && idea.id != null) {
                          await _brainstormRepository.toggleBrainstormCompletion(
                            idea.id!,
                            val,
                          );
                          _loadData();
                        }
                      },
                    ),
                    title: Text(
                      idea.title,
                      style: TextStyle(
                        color: idea.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                        decoration: idea.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.secondaryText),
                    onTap: () async {
                      if (idea.id != null) {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BrainstormDetailScreen(
                              brainstormId: idea.id!,
                              repository: _brainstormRepository,
                              milestoneRepository: _repository,
                            ),
                          ),
                        );
                        if (updated == true) {
                          _loadData();
                        }
                      }
                    },
                  ),
                );
              }),

            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            // 2. Related Issues Section
            Row(
              children: [
                Text(
                  'Masalah & Kendala Terkait (${_relatedIssues.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20, color: AppColors.primaryAccent),
                  tooltip: 'Catat Masalah di Tahapan Ini',
                  onPressed: () async {
                    final added = await IssueFormDialog.show(
                      context,
                      projectId: milestone.projectId,
                      initialMilestoneId: milestone.id,
                      repository: _issueRepository,
                      milestoneRepository: _repository,
                    );
                    if (added == true) {
                      _loadData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_relatedIssues.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Belum ada kendala atau masalah di tahapan ini.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
              )
            else
              ..._relatedIssues.map((issue) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: issue.isCompleted,
                      activeColor: AppColors.primaryAccent,
                      checkColor: AppColors.background,
                      onChanged: (val) async {
                        if (val != null && issue.id != null) {
                          await _issueRepository.toggleIssueCompletion(
                            issue.id!,
                            val,
                          );
                          _loadData();
                        }
                      },
                    ),
                    title: Text(
                      issue.title,
                      style: TextStyle(
                        color: issue.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                        decoration: issue.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.secondaryText),
                    onTap: () async {
                      if (issue.id != null) {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailScreen(
                              issueId: issue.id!,
                              repository: _issueRepository,
                              milestoneRepository: _repository,
                            ),
                          ),
                        );
                        if (updated == true) {
                          _loadData();
                        }
                      }
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
