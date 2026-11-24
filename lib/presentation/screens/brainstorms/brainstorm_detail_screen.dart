import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'brainstorm_form_dialog.dart';

/// Screen displaying the details and actions of a single Brainstorm idea.
class BrainstormDetailScreen extends StatefulWidget {
  final int brainstormId;
  final BrainstormRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const BrainstormDetailScreen({
    super.key,
    required this.brainstormId,
    this.repository,
    this.milestoneRepository,
  });

  @override
  State<BrainstormDetailScreen> createState() => _BrainstormDetailScreenState();
}

class _BrainstormDetailScreenState extends State<BrainstormDetailScreen> {
  late final BrainstormRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  BrainstormModel? _brainstorm;
  MilestoneModel? _connectedMilestone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BrainstormRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final brainstorm = await _repository.getBrainstormById(widget.brainstormId);

    MilestoneModel? milestone;
    if (brainstorm?.milestoneId != null) {
      milestone = await _milestoneRepository.getMilestoneById(brainstorm!.milestoneId!);
    }

    if (mounted) {
      setState(() {
        _brainstorm = brainstorm;
        _connectedMilestone = milestone;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(bool isCompleted) async {
    if (_brainstorm?.id == null) return;
    await _repository.toggleBrainstormCompletion(_brainstorm!.id!, isCompleted);
    _loadData();
  }

  void _confirmDelete() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Hapus Ide',
      message: 'Apakah Anda yakin ingin menghapus ide "${_brainstorm?.title}"?',
      confirmLabel: 'Hapus Ide',
      onConfirm: () async {
        if (_brainstorm?.id != null) {
          await _repository.deleteBrainstorm(_brainstorm!.id!);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ide berhasil dihapus',
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

    if (_brainstorm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Ide')),
        body: const Center(
          child: Text(
            'Ide tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final idea = _brainstorm!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(idea.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Ide',
            onPressed: () async {
              final updated = await BrainstormFormDialog.show(
                context,
                projectId: idea.projectId,
                brainstorm: idea,
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
            tooltip: 'Hapus Ide',
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
                      value: idea.isCompleted,
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
                            idea.isCompleted ? 'Ide Telah Selesai' : 'Ide Belum Terealisasi',
                            style: TextStyle(
                              color: idea.isCompleted
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _connectedMilestone != null
                                ? 'Tahapan: ${_connectedMilestone!.name}'
                                : 'Ide Bebas (Tanpa Tahapan)',
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
            if (idea.description.isNotEmpty) ...[
              Text(
                'Deskripsi & Konsep',
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
                  idea.description,
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
                  'Dibuat: ${dateFormat.format(idea.createdAt)}',
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
