import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'milestone_form_dialog.dart';

/// Screen displaying the details of a single milestone.
class MilestoneDetailScreen extends StatefulWidget {
  final int milestoneId;
  final MilestoneRepository? repository;

  const MilestoneDetailScreen({
    super.key,
    required this.milestoneId,
    this.repository,
  });

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> {
  late final MilestoneRepository _repository;
  MilestoneModel? _milestone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MilestoneRepository();
    _loadMilestone();
  }

  Future<void> _loadMilestone() async {
    setState(() => _isLoading = true);
    final milestone = await _repository.getMilestoneById(widget.milestoneId);
    if (mounted) {
      setState(() {
        _milestone = milestone;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(bool value) async {
    if (_milestone?.id == null) return;
    await _repository.toggleMilestoneCompletion(_milestone!.id!, value);
    _loadMilestone();
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
                _loadMilestone();
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

            // Placeholder Related Ideas and Issues
            Text(
              'Ide & Masalah Terkait (Tersedia Phase 4)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryAccent,
                ),
                title: Text(
                  'Ide Terhubung',
                  style: TextStyle(color: AppColors.primaryText),
                ),
                subtitle: Text(
                  '0 Ide terhubung dengan tahapan ini',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.bug_report_outlined,
                  color: AppColors.primaryAccent,
                ),
                title: Text(
                  'Masalah Terhubung',
                  style: TextStyle(color: AppColors.primaryText),
                ),
                subtitle: Text(
                  '0 Masalah terhubung dengan tahapan ini',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
