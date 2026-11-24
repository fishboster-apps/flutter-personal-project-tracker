import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/activity_log_model.dart';
import '../../../data/repositories/activity_log_repository.dart';
import '../../widgets/confirm_delete_dialog.dart';

/// Screen displaying the timeline of activity logs for a project.
class ActivityLogScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final ActivityLogRepository? repository;

  const ActivityLogScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.repository,
  });

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late final ActivityLogRepository _repository;
  List<ActivityLogModel> _logs = [];
  String? _selectedFilter; // null = Semua
  bool _isLoading = true;

  final List<({String? entityType, String label})> _filterOptions = const [
    (entityType: null, label: 'Semua Riwayat'),
    (entityType: 'milestone', label: 'Tahapan'),
    (entityType: 'brainstorm', label: 'Ide'),
    (entityType: 'issue', label: 'Kendala'),
    (entityType: 'reference', label: 'Referensi'),
    (entityType: 'project', label: 'Proyek'),
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ActivityLogRepository();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _repository.getLogsByProjectId(
        widget.projectId,
        entityType: _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _logs = [];
          _isLoading = false;
        });
      }
    }
  }

  void _confirmClearLogs() {
    ConfirmDeleteDialog.show(
      context,
      title: 'Bersihkan Riwayat',
      message:
          'Apakah Anda yakin ingin menghapus seluruh riwayat aktivitas proyek "${widget.projectName}"?',
      confirmLabel: 'Hapus Riwayat',
      onConfirm: () async {
        await _repository.clearLogsByProject(widget.projectId);
        _loadLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Riwayat aktivitas berhasil dibersihkan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Aktivitas'),
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
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
              tooltip: 'Bersihkan Riwayat',
              onPressed: _confirmClearLogs,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filterOptions.map((option) {
                final isSelected = _selectedFilter == option.entityType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? option.entityType : null;
                      });
                      _loadLogs();
                    },
                    selectedColor: AppColors.primaryAccent.withValues(alpha: 0.25),
                    checkmarkColor: AppColors.primaryAccent,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryAccent
                          : AppColors.secondaryText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAccent,
                    ),
                  )
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryAccent,
                        backgroundColor: AppColors.surfaceElevated,
                        onRefresh: _loadLogs,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return _buildTimelineItem(log);
                          },
                        ),
                      ),
          ),
        ],
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat aktivitas',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == null
                  ? 'Aktivitas perubahan proyek akan tercatat di sini secara otomatis.'
                  : 'Tidak ada riwayat aktivitas untuk filter yang dipilih.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ActivityLogModel log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon indicator
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: log.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: log.color.withValues(alpha: 0.4)),
              ),
              child: Icon(log.icon, color: log.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          log.entityLabel,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        log.formatRelativeTime(),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.description,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
