import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/project_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../milestones/milestone_list_screen.dart';
import 'project_form_screen.dart';

/// Screen displaying the details and actions for a single project.
class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final ProjectRepository? repository;
  final MilestoneRepository? milestoneRepository;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.repository,
    this.milestoneRepository,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final ProjectRepository _repository;
  late final MilestoneRepository _milestoneRepository;

  ProjectModel? _project;
  MilestoneProgress _milestoneProgress =
      const MilestoneProgress(total: 0, completed: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProjectRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    final project = await _repository.getProjectById(widget.projectId);
    final progress =
        await _milestoneRepository.getProjectProgress(widget.projectId);

    if (mounted) {
      setState(() {
        _project = project;
        _milestoneProgress = progress;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.primaryAccent;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.archived:
        return AppColors.secondaryText;
    }
  }

  void _confirmDelete() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Hapus Proyek',
      message:
          'Apakah Anda yakin ingin menghapus proyek "${_project?.name}"? Seluruh tahapan, ide, masalah, dan referensi terkait akan ikut terhapus.',
      confirmLabel: 'Hapus Proyek',
      onConfirm: () async {
        if (_project?.id != null) {
          await _repository.deleteProject(_project!.id!);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Proyek berhasil dihapus',
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

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Proyek')),
        body: const Center(
          child: Text(
            'Proyek tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final project = _project!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Proyek',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(
                    project: project,
                    repository: _repository,
                  ),
                ),
              );
              if (updated == true) {
                _loadProject();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus Proyek',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip & Progress
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(project.status).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    project.status.label,
                    style: TextStyle(
                      color: _getStatusColor(project.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Progres: ${_milestoneProgress.percentageInt}%',
                  style: const TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Live Progress Bar from Milestones
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _milestoneProgress.ratio,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAccent,
                ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            if (project.description.isNotEmpty) ...[
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
                  project.description,
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
                  'Dibuat: ${dateFormat.format(project.createdAt)}',
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

            // Modules Navigation
            Text(
              'Modul Proyek',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // 1. Milestones - Interactive Navigation
            _buildFeatureTile(
              icon: Icons.flag_outlined,
              title: 'Tahapan / Milestones',
              subtitle: _milestoneProgress.total == 0
                  ? '0 Tahapan'
                  : '${_milestoneProgress.total} Tahapan (${_milestoneProgress.completed} selesai)',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MilestoneListScreen(
                      projectId: project.id!,
                      projectName: project.name,
                      repository: _milestoneRepository,
                    ),
                  ),
                );
                _loadProject();
              },
            ),

            // 2. Ide & Gagasan (Phase 4)
            _buildFeatureTile(
              icon: Icons.lightbulb_outline,
              title: 'Ide & Gagasan',
              subtitle: '0 Ide',
              onTap: () => _showComingSoon('Ide & Gagasan'),
            ),

            // 3. Masalah & Kendala (Phase 4)
            _buildFeatureTile(
              icon: Icons.bug_report_outlined,
              title: 'Masalah & Kendala',
              subtitle: '0 Masalah',
              onTap: () => _showComingSoon('Masalah & Kendala'),
            ),

            // 4. Referensi Tautan (Phase 5)
            _buildFeatureTile(
              icon: Icons.link,
              title: 'Referensi Tautan',
              subtitle: '0 Referensi',
              onTap: () => _showComingSoon('Referensi Tautan'),
            ),

            // 5. Riwayat Aktivitas (Phase 6)
            _buildFeatureTile(
              icon: Icons.history,
              title: 'Riwayat Aktivitas',
              subtitle: 'Lihat riwayat perubahan',
              onTap: () => _showComingSoon('Riwayat Aktivitas'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName akan tersedia pada fase berikutnya.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        onTap: onTap,
      ),
    );
  }
}
