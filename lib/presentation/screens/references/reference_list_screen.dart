import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/reference_model.dart';
import '../../../data/repositories/brainstorm_repository.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../services/url_launcher_service.dart';
import 'reference_detail_screen.dart';
import 'reference_form_dialog.dart';

enum ReferenceFilterType {
  all,
  standalone,
  brainstorm,
  issue,
}

/// Screen displaying the list of references and external links for a project.
class ReferenceListScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final ReferenceRepository? repository;
  final BrainstormRepository? brainstormRepository;
  final IssueRepository? issueRepository;
  final UrlLauncherService? launcherService;

  const ReferenceListScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.repository,
    this.brainstormRepository,
    this.issueRepository,
    this.launcherService,
  });

  @override
  State<ReferenceListScreen> createState() => _ReferenceListScreenState();
}

class _ReferenceListScreenState extends State<ReferenceListScreen> {
  late final ReferenceRepository _repository;
  late final BrainstormRepository _brainstormRepository;
  late final IssueRepository _issueRepository;
  late final UrlLauncherService _launcherService;

  List<ReferenceModel> _allItems = [];
  Map<int, String> _brainstormTitles = {};
  Map<int, String> _issueTitles = {};

  ReferenceFilterType _filterType = ReferenceFilterType.all;
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

    try {
      final references =
          await _repository.getReferencesByProjectId(widget.projectId);
      final brainstorms =
          await _brainstormRepository.getBrainstormsByProjectId(widget.projectId);
      final issues =
          await _issueRepository.getIssuesByProjectId(widget.projectId);

      final bMap = <int, String>{};
      for (final b in brainstorms) {
        if (b.id != null) bMap[b.id!] = b.title;
      }

      final iMap = <int, String>{};
      for (final i in issues) {
        if (i.id != null) iMap[i.id!] = i.title;
      }

      if (mounted) {
        setState(() {
          _allItems = references;
          _brainstormTitles = bMap;
          _issueTitles = iMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ReferenceModel> get _filteredItems {
    switch (_filterType) {
      case ReferenceFilterType.all:
        return _allItems;
      case ReferenceFilterType.standalone:
        return _allItems.where((r) => r.isStandalone).toList();
      case ReferenceFilterType.brainstorm:
        return _allItems.where((r) => r.isBrainstormRelated).toList();
      case ReferenceFilterType.issue:
        return _allItems.where((r) => r.isIssueRelated).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referensi & Tautan',
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
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Semua Tautan', ReferenceFilterType.all),
                const SizedBox(width: 8),
                _buildFilterChip('Tautan Umum', ReferenceFilterType.standalone),
                const SizedBox(width: 8),
                _buildFilterChip('Ide Terkait', ReferenceFilterType.brainstorm),
                const SizedBox(width: 8),
                _buildFilterChip('Kendala Terkait', ReferenceFilterType.issue),
              ],
            ),
          ),

          // List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return _buildReferenceCard(item);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await ReferenceFormDialog.show(
            context,
            projectId: widget.projectId,
            repository: _repository,
            brainstormRepository: _brainstormRepository,
            issueRepository: _issueRepository,
          );
          if (added == true) {
            _loadData();
          }
        },
        tooltip: 'Tambah Tautan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, ReferenceFilterType type) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterType = type);
        }
      },
      selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryAccent : AppColors.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildReferenceCard(ReferenceModel item) {
    final hasBrainstorm = item.brainstormId != null;
    final hasIssue = item.issueId != null;

    String relationLabel = 'Tautan Umum';
    Color relationColor = AppColors.secondaryText;
    IconData relationIcon = Icons.folder_outlined;

    if (hasBrainstorm) {
      final title = _brainstormTitles[item.brainstormId] ?? 'Ide';
      relationLabel = 'Ide: $title';
      relationColor = AppColors.primaryAccent;
      relationIcon = Icons.lightbulb_outline;
    } else if (hasIssue) {
      final title = _issueTitles[item.issueId] ?? 'Kendala';
      relationLabel = 'Kendala: $title';
      relationColor = AppColors.warning;
      relationIcon = Icons.bug_report_outlined;
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ReferenceDetailScreen(
                referenceId: item.id!,
                repository: _repository,
                brainstormRepository: _brainstormRepository,
                issueRepository: _issueRepository,
                launcherService: _launcherService,
              ),
            ),
          );
          if (deleted == true || mounted) {
            _loadData();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Action icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: AppColors.secondaryText),
                    tooltip: 'Salin Tautan',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () => UrlLauncherService.copyToClipboard(item.url, context: context),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18, color: AppColors.primaryAccent),
                    tooltip: 'Buka di Browser',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () => _launcherService.openUrl(item.url, context: context),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // URL
              Text(
                item.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryAccent,
                  decoration: TextDecoration.underline,
                ),
              ),

              // Notes preview
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
              const SizedBox(height: 8),

              // Target Relation Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: relationColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(relationIcon, size: 13, color: relationColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        relationLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: relationColor,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_outlined,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada referensi tautan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan dokumentasi, repositori, dan referensi penting di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final added = await ReferenceFormDialog.show(
                  context,
                  projectId: widget.projectId,
                  repository: _repository,
                  brainstormRepository: _brainstormRepository,
                  issueRepository: _issueRepository,
                );
                if (added == true) {
                  _loadData();
                }
              },
              child: const Text('Tambah Tautan Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}
