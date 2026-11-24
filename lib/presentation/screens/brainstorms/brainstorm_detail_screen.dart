import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/brainstorm_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/models/reference_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../services/url_launcher_service.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../references/reference_detail_screen.dart';
import '../references/reference_form_dialog.dart';
import 'brainstorm_form_dialog.dart';

/// Screen displaying the details and actions of a single Brainstorm idea.
class BrainstormDetailScreen extends StatefulWidget {
  final int brainstormId;
  final BrainstormRepository? repository;
  final MilestoneRepository? milestoneRepository;
  final ReferenceRepository? referenceRepository;
  final UrlLauncherService? launcherService;

  const BrainstormDetailScreen({
    super.key,
    required this.brainstormId,
    this.repository,
    this.milestoneRepository,
    this.referenceRepository,
    this.launcherService,
  });

  @override
  State<BrainstormDetailScreen> createState() => _BrainstormDetailScreenState();
}

class _BrainstormDetailScreenState extends State<BrainstormDetailScreen> {
  late final BrainstormRepository _repository;
  late final MilestoneRepository _milestoneRepository;
  late final ReferenceRepository _referenceRepository;
  late final UrlLauncherService _launcherService;

  BrainstormModel? _brainstorm;
  MilestoneModel? _connectedMilestone;
  List<ReferenceModel> _references = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BrainstormRepository();
    _milestoneRepository = widget.milestoneRepository ?? MilestoneRepository();
    _referenceRepository = widget.referenceRepository ?? ReferenceRepository();
    _launcherService = widget.launcherService ?? const UrlLauncherService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final brainstorm = await _repository.getBrainstormById(widget.brainstormId);

    MilestoneModel? milestone;
    if (brainstorm?.milestoneId != null) {
      milestone = await _milestoneRepository.getMilestoneById(brainstorm!.milestoneId!);
    }

    List<ReferenceModel> references = [];
    try {
      references = await _referenceRepository.getReferencesByBrainstormId(widget.brainstormId);
    } catch (_) {
      // Keep empty if failed
    }

    if (mounted) {
      setState(() {
        _brainstorm = brainstorm;
        _connectedMilestone = milestone;
        _references = references;
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
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Ide & Gagasan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final idea = _brainstorm;
    if (idea == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Ide & Gagasan')),
        body: const Center(
          child: Text(
            'Ide tidak ditemukan',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Ide & Gagasan'),
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title & Status
            Text(
              idea.title,
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
                      projectId: idea.projectId,
                      initialBrainstormId: idea.id,
                      repository: _referenceRepository,
                      brainstormRepository: _repository,
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
                  'Belum ada referensi tautan untuk ide ini.',
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
                brainstormRepository: _repository,
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
