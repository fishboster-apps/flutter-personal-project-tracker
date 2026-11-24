import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/issue_model.dart';
import 'activity_log_repository.dart';
import 'brainstorm_repository.dart';

/// Repository handling all database operations for Issues (Problems & Bugs).
class IssueRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;
  final ActivityLogRepository? _logRepo;

  IssueRepository({
    DatabaseHelper? dbHelper,
    Database? db,
    ActivityLogRepository? logRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db,
        _logRepo = logRepository ??
            (db != null ? ActivityLogRepository(db: db) : ActivityLogRepository(dbHelper: dbHelper));

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new issue.
  Future<int> insertIssue(IssueModel issue) async {
    final db = await _db;
    final id = await db.insert(
      DatabaseMigrations.tableIssues,
      issue.toMap(),
    );

    try {
      await _logRepo?.log(
        projectId: issue.projectId,
        entityType: 'issue',
        action: 'create',
        description: 'Mencatat kendala "${issue.title}"',
        entityId: id,
      );
    } catch (_) {}

    return id;
  }

  /// Retrieves issues for a project with optional filtering.
  /// If [milestoneId] is provided, filters by that milestone.
  /// If [unassignedOnly] is true, filters for items where milestone_id IS NULL.
  Future<List<IssueModel>> getIssuesByProjectId(
    int projectId, {
    int? milestoneId,
    bool unassignedOnly = false,
  }) async {
    final db = await _db;
    String whereClause = 'project_id = ?';
    final whereArgs = <dynamic>[projectId];

    if (unassignedOnly) {
      whereClause += ' AND milestone_id IS NULL';
    } else if (milestoneId != null) {
      whereClause += ' AND milestone_id = ?';
      whereArgs.add(milestoneId);
    }

    final results = await db.query(
      DatabaseMigrations.tableIssues,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'is_completed ASC, updated_at DESC',
    );
    return results.map((map) => IssueModel.fromMap(map)).toList();
  }

  /// Finds a single issue by its primary key [id].
  Future<IssueModel?> getIssueById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableIssues,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return IssueModel.fromMap(results.first);
  }

  /// Updates an existing issue.
  Future<int> updateIssue(IssueModel issue) async {
    final db = await _db;
    if (issue.id == null) {
      throw ArgumentError('Cannot update issue without an id.');
    }
    final rows = await db.update(
      DatabaseMigrations.tableIssues,
      issue.toMap(),
      where: 'id = ?',
      whereArgs: [issue.id],
    );

    try {
      await _logRepo?.log(
        projectId: issue.projectId,
        entityType: 'issue',
        action: 'update',
        description: 'Memperbarui kendala "${issue.title}"',
        entityId: issue.id,
      );
    } catch (_) {}

    return rows;
  }

  /// Deletes an issue by [id].
  Future<int> deleteIssue(int id) async {
    final item = await getIssueById(id);
    final db = await _db;
    final rows = await db.delete(
      DatabaseMigrations.tableIssues,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (item != null) {
      try {
        await _logRepo?.log(
          projectId: item.projectId,
          entityType: 'issue',
          action: 'delete',
          description: 'Menghapus kendala "${item.title}"',
        );
      } catch (_) {}
    }

    return rows;
  }

  /// Toggles the completion checkbox status of an issue.
  Future<int> toggleIssueCompletion(int id, bool isCompleted) async {
    final item = await getIssueById(id);
    final db = await _db;
    final rows = await db.update(
      DatabaseMigrations.tableIssues,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (item != null) {
      try {
        await _logRepo?.log(
          projectId: item.projectId,
          entityType: 'issue',
          action: 'complete',
          description: isCompleted
              ? 'Menandai kendala "${item.title}" selesai/teratasi'
              : 'Membuka kembali kendala "${item.title}"',
          entityId: id,
        );
      } catch (_) {}
    }

    return rows;
  }

  /// Calculates total and completed issues for a project.
  Future<ItemSummaryCount> getCountByProject(int projectId) async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as total, COALESCE(SUM(is_completed), 0) as completed FROM ${DatabaseMigrations.tableIssues} WHERE project_id = ?',
      [projectId],
    );
    final total = (results.first['total'] as int?) ?? 0;
    final completed = (results.first['completed'] as int?) ?? 0;
    return ItemSummaryCount(total: total, completed: completed);
  }
}
