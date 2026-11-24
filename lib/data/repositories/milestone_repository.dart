import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/milestone_model.dart';
import 'activity_log_repository.dart';

/// Aggregation data for project milestones progress.
class MilestoneProgress {
  final int total;
  final int completed;

  const MilestoneProgress({
    required this.total,
    required this.completed,
  });

  double get percentage => total == 0 ? 0.0 : (completed / total) * 100;
  double get ratio => total == 0 ? 0.0 : completed / total;
  int get percentageInt => percentage.round();
}

/// Repository handling all database operations for Milestones.
class MilestoneRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;
  final ActivityLogRepository? _logRepo;

  MilestoneRepository({
    DatabaseHelper? dbHelper,
    Database? db,
    ActivityLogRepository? logRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db,
        _logRepo = logRepository ??
            (db != null ? ActivityLogRepository(db: db) : ActivityLogRepository(dbHelper: dbHelper));

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new milestone. If sortOrder is 0 or unassigned, auto-increments
  /// to the next sort_order for the given [milestone.projectId].
  Future<int> insertMilestone(MilestoneModel milestone) async {
    final db = await _db;

    int sortOrder = milestone.sortOrder;
    if (sortOrder <= 0) {
      final maxResult = await db.rawQuery(
        'SELECT MAX(sort_order) as max_sort FROM ${DatabaseMigrations.tableMilestones} WHERE project_id = ?',
        [milestone.projectId],
      );
      final maxSort = (maxResult.first['max_sort'] as int?);
      sortOrder = (maxSort ?? -1) + 1;
    }

    final toInsert = milestone.copyWith(sortOrder: sortOrder);
    final id = await db.insert(
      DatabaseMigrations.tableMilestones,
      toInsert.toMap(),
    );

    try {
      await _logRepo?.log(
        projectId: toInsert.projectId,
        entityType: 'milestone',
        action: 'create',
        description: 'Menambahkan tahapan "${toInsert.name}"',
        entityId: id,
      );
    } catch (_) {}

    return id;
  }

  /// Retrieves all milestones for a project ordered by [sort_order] ascending.
  Future<List<MilestoneModel>> getMilestonesByProjectId(int projectId) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableMilestones,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return results.map((map) => MilestoneModel.fromMap(map)).toList();
  }

  /// Finds a single milestone by its primary key [id].
  Future<MilestoneModel?> getMilestoneById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableMilestones,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return MilestoneModel.fromMap(results.first);
  }

  /// Updates an existing milestone and returns the number of rows affected.
  Future<int> updateMilestone(MilestoneModel milestone) async {
    final db = await _db;
    if (milestone.id == null) {
      throw ArgumentError('Cannot update milestone without an id.');
    }
    final rows = await db.update(
      DatabaseMigrations.tableMilestones,
      milestone.toMap(),
      where: 'id = ?',
      whereArgs: [milestone.id],
    );

    try {
      await _logRepo?.log(
        projectId: milestone.projectId,
        entityType: 'milestone',
        action: 'update',
        description: 'Memperbarui tahapan "${milestone.name}"',
        entityId: milestone.id,
      );
    } catch (_) {}

    return rows;
  }

  /// Deletes a milestone by [id].
  /// Child brainstorms and issues will have milestone_id SET NULL via FK rules.
  Future<int> deleteMilestone(int id) async {
    final milestone = await getMilestoneById(id);
    final db = await _db;
    final rows = await db.delete(
      DatabaseMigrations.tableMilestones,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (milestone != null) {
      try {
        await _logRepo?.log(
          projectId: milestone.projectId,
          entityType: 'milestone',
          action: 'delete',
          description: 'Menghapus tahapan "${milestone.name}"',
        );
      } catch (_) {}
    }

    return rows;
  }

  /// Toggles the completion checkbox status of a milestone.
  Future<int> toggleMilestoneCompletion(int id, bool isCompleted) async {
    final milestone = await getMilestoneById(id);
    final db = await _db;
    final rows = await db.update(
      DatabaseMigrations.tableMilestones,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (milestone != null) {
      try {
        await _logRepo?.log(
          projectId: milestone.projectId,
          entityType: 'milestone',
          action: 'complete',
          description: isCompleted
              ? 'Menyelesaikan tahapan "${milestone.name}"'
              : 'Menandai tahapan "${milestone.name}" belum selesai',
          entityId: id,
        );
      } catch (_) {}
    }

    return rows;
  }

  /// Reorders milestones for a project in a single transaction.
  Future<void> reorderMilestones(
    int projectId,
    List<MilestoneModel> reorderedList,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      for (int i = 0; i < reorderedList.length; i++) {
        final milestone = reorderedList[i];
        await txn.update(
          DatabaseMigrations.tableMilestones,
          {
            'sort_order': i,
            'updated_at': now,
          },
          where: 'id = ? AND project_id = ?',
          whereArgs: [milestone.id, projectId],
        );
      }
    });

    try {
      await _logRepo?.log(
        projectId: projectId,
        entityType: 'milestone',
        action: 'reorder',
        description: 'Mengubah urutan tahapan proyek',
      );
    } catch (_) {}
  }

  /// Calculates total milestones, completed milestones, and completion percentage for a project.
  Future<MilestoneProgress> getProjectProgress(int projectId) async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as total, COALESCE(SUM(is_completed), 0) as completed FROM ${DatabaseMigrations.tableMilestones} WHERE project_id = ?',
      [projectId],
    );
    final total = (results.first['total'] as int?) ?? 0;
    final completed = (results.first['completed'] as int?) ?? 0;
    return MilestoneProgress(total: total, completed: completed);
  }

  /// Returns a map of projectId -> MilestoneProgress for all projects in a single batch query.
  Future<Map<int, MilestoneProgress>> getAllProjectsProgress() async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT project_id, COUNT(*) as total, COALESCE(SUM(is_completed), 0) as completed FROM ${DatabaseMigrations.tableMilestones} GROUP BY project_id',
    );
    final map = <int, MilestoneProgress>{};
    for (final row in results) {
      final projectId = row['project_id'] as int;
      final total = (row['total'] as int?) ?? 0;
      final completed = (row['completed'] as int?) ?? 0;
      map[projectId] = MilestoneProgress(total: total, completed: completed);
    }
    return map;
  }
}
