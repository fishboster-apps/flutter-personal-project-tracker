import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/project_repository.dart';
import 'project_detail_screen.dart';
import 'project_form_screen.dart';

/// Main screen displaying the list of all projects with search & filtering.
class ProjectListScreen extends StatefulWidget {
  final ProjectRepository? repository;

  const ProjectListScreen({super.key, this.repository});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late final ProjectRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  ProjectStatus? _selectedStatusFilter; // null means 'All'

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProjectRepository();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);

    try {
      final query = _searchController.text.trim();
      List<ProjectModel> list;

      if (query.isNotEmpty) {
        list = await _repository.searchProjects(query);
        if (_selectedStatusFilter != null) {
          list = list.where((p) => p.status == _selectedStatusFilter).toList();
        }
      } else if (_selectedStatusFilter != null) {
        list = await _repository.getProjectsByStatus(_selectedStatusFilter!);
      } else {
        list = await _repository.getAllProjects();
      }

      if (mounted) {
        setState(() {
          _projects = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat proyek: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Project Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari proyek...',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.secondaryText),
                        onPressed: () {
                          _searchController.clear();
                          _loadProjects();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryAccent),
                ),
              ),
              onChanged: (_) => _loadProjects(),
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(label: 'All', status: null),
                const SizedBox(width: 8),
                ...ProjectStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(label: status.label, status: status),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Project List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: _projects.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectFormScreen(),
            ),
          );
          if (created == true) {
            _loadProjects();
          }
        },
        tooltip: 'Tambah Proyek',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required ProjectStatus? status}) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
        _loadProjects();
      },
      selectedColor: AppColors.primaryAccent.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryAccent : AppColors.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primaryAccent : AppColors.border,
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final statusColor = _getStatusColor(project.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (project.id != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectId: project.id!),
              ),
            );
            _loadProjects();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      project.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '0 Tahapan',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '0% Selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching =
        _searchController.text.isNotEmpty || _selectedStatusFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_outlined
                  : Icons.folder_open_outlined,
              size: 64,
              color: AppColors.secondaryText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Tidak ada proyek yang sesuai'
                  : 'Belum ada proyek',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba ganti kata kunci pencarian atau reset filter status.'
                  : 'Mulai kelola progres pengembangan proyek Anda dengan menambahkan proyek pertama.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProjectFormScreen(),
                    ),
                  );
                  if (created == true) {
                    _loadProjects();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Buat Proyek Pertama'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.background,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
