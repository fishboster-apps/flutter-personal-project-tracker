import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import 'issue_detail_screen.dart';
import 'issue_form_dialog.dart';

/// Screen displaying the list of all Issues/Problems for a project with filtering.
class IssueListScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final IssueRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const IssueListScreen({
    super.key,
    required this.projectId,
    this.projectName = 'Proyek',
    this.repository,
    this.milestoneRepository,
  });

  @override
  State<IssueListScreen> createState() => _IssueListScreenState();
}

class _IssueListScreenState extends State<IssueListScreen> {
  late final IssueRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  List<IssueModel> _items = [];
  List<MilestoneModel> _milestones = [];
  Map<int, String> _milestoneNameMap = {};

  bool _isLoading = true;
  // null = All, -1 = Unassigned only, > 0 = specific milestoneId
  int? _filterMilestoneId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? IssueRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final milestones =
        await _milestoneRepository.getMilestonesByProjectId(widget.projectId);
    final milestoneMap = {for (var m in milestones) m.id!: m.name};

    List<IssueModel> items;
    if (_filterMilestoneId == -1) {
      items = await _repository.getIssuesByProjectId(
        widget.projectId,
        unassignedOnly: true,
      );
    } else if (_filterMilestoneId != null) {
      items = await _repository.getIssuesByProjectId(
        widget.projectId,
        milestoneId: _filterMilestoneId,
      );
    } else {
      items = await _repository.getIssuesByProjectId(widget.projectId);
    }

    if (mounted) {
      setState(() {
        _milestones = milestones;
        _milestoneNameMap = milestoneMap;
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(IssueModel issue, bool isCompleted) async {
    if (issue.id == null) return;
    await _repository.toggleIssueCompletion(issue.id!, isCompleted);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masalah & Kendala',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips (All, Tanpa Tahapan, per milestone)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Semua Masalah', null),
                const SizedBox(width: 8),
                _buildFilterChip('Tanpa Tahapan', -1),
                const SizedBox(width: 8),
                ..._milestones.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(m.name, m.id),
                  );
                }),
              ],
            ),
          ),

          // List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildIssueCard(item);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await IssueFormDialog.show(
            context,
            projectId: widget.projectId,
            initialMilestoneId:
                _filterMilestoneId != null && _filterMilestoneId! > 0
                    ? _filterMilestoneId
                    : null,
            repository: _repository,
            milestoneRepository: _milestoneRepository,
          );
          if (added == true) {
            _loadData();
          }
        },
        tooltip: 'Catat Masalah',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, int? filterValue) {
    final isSelected = _filterMilestoneId == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterMilestoneId = selected ? filterValue : null);
        _loadData();
      },
      selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryAccent : AppColors.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primaryAccent : AppColors.border,
      ),
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    final milestoneName = issue.milestoneId != null
        ? _milestoneNameMap[issue.milestoneId]
        : null;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (issue.id != null) {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => IssueDetailScreen(
                  issueId: issue.id!,
                  repository: _repository,
                  milestoneRepository: _milestoneRepository,
                ),
              ),
            );
            if (updated == true) {
              _loadData();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: issue.isCompleted,
                activeColor: AppColors.primaryAccent,
                checkColor: AppColors.background,
                onChanged: (val) {
                  if (val != null) {
                    _toggleComplete(issue, val);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: issue.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                        decoration: issue.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (issue.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        issue.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        milestoneName != null
                            ? 'Tahapan: $milestoneName'
                            : 'Kendala Umum',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada masalah',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catat kendala teknis dan bug agar solusi mudah ditelusuri.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final added = await IssueFormDialog.show(
                  context,
                  projectId: widget.projectId,
                  initialMilestoneId:
                      _filterMilestoneId != null && _filterMilestoneId! > 0
                          ? _filterMilestoneId
                          : null,
                  repository: _repository,
                  milestoneRepository: _milestoneRepository,
                );
                if (added == true) {
                  _loadData();
                }
              },
              child: const Text('Catat Masalah Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}
