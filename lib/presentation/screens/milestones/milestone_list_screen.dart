import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/milestone_repository.dart';
import 'milestone_detail_screen.dart';
import 'milestone_form_dialog.dart';

/// Screen displaying the reorderable list of milestones for a specific project.
class MilestoneListScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final MilestoneRepository? repository;

  const MilestoneListScreen({
    super.key,
    required this.projectId,
    this.projectName = 'Tahapan Proyek',
    this.repository,
  });

  @override
  State<MilestoneListScreen> createState() => _MilestoneListScreenState();
}

class _MilestoneListScreenState extends State<MilestoneListScreen> {
  late final MilestoneRepository _repository;
  List<MilestoneModel> _milestones = [];
  MilestoneProgress _progress = const MilestoneProgress(total: 0, completed: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MilestoneRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final milestones =
        await _repository.getMilestonesByProjectId(widget.projectId);
    final progress = await _repository.getProjectProgress(widget.projectId);

    if (mounted) {
      setState(() {
        _milestones = milestones;
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(MilestoneModel milestone, bool isCompleted) async {
    if (milestone.id == null) return;
    await _repository.toggleMilestoneCompletion(milestone.id!, isCompleted);
    _loadData();
  }

  Future<void> _onReorderItem(int oldIndex, int newIndex) async {
    setState(() {
      final item = _milestones.removeAt(oldIndex);
      _milestones.insert(newIndex, item);
    });
    await _repository.reorderMilestones(widget.projectId, _milestones);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tahapan / Milestones',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Header Bar
                if (_milestones.isNotEmpty) _buildProgressHeader(),

                // Reorderable list or Empty State
                Expanded(
                  child: _milestones.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _milestones.length,
                          onReorderItem: _onReorderItem,
                          itemBuilder: (context, index) {
                            final milestone = _milestones[index];
                            return _buildMilestoneTile(milestone, index);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await MilestoneFormDialog.show(
            context,
            projectId: widget.projectId,
            repository: _repository,
          );
          if (added == true) {
            _loadData();
          }
        },
        tooltip: 'Tambah Tahapan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_progress.completed} dari ${_progress.total} selesai',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${_progress.percentageInt}%',
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress.ratio,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryAccent,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(MilestoneModel milestone, int index) {
    return Card(
      key: ValueKey(milestone.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (milestone.id != null) {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => MilestoneDetailScreen(
                  milestoneId: milestone.id!,
                  repository: _repository,
                ),
              ),
            );
            if (updated == true) {
              _loadData();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: milestone.isCompleted,
                activeColor: AppColors.primaryAccent,
                checkColor: AppColors.background,
                onChanged: (val) {
                  if (val != null) {
                    _toggleComplete(milestone, val);
                  }
                },
              ),
              const SizedBox(width: 8),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: milestone.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                        decoration: milestone.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (milestone.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        milestone.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Drag Handle
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.secondaryText,
                  ),
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
              Icons.flag_outlined,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tahapan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bagi proyek ke tahapan terukur agar progres terpantau rapi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final added = await MilestoneFormDialog.show(
                  context,
                  projectId: widget.projectId,
                  repository: _repository,
                );
                if (added == true) {
                  _loadData();
                }
              },
              child: const Text('Tambah Tahapan Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}
