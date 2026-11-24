import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/issue_model.dart';
import 'brainstorm_repository.dart';

/// Repository handling all database operations for Issues (Problems & Bugs).
class IssueRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;

  IssueRepository({DatabaseHelper? dbHelper, Database? db})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db;

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new issue.
  Future<int> insertIssue(IssueModel issue) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableIssues,
      issue.toMap(),
    );
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
    return await db.update(
      DatabaseMigrations.tableIssues,
      issue.toMap(),
      where: 'id = ?',
      whereArgs: [issue.id],
    );
  }

  /// Deletes an issue by [id].
  Future<int> deleteIssue(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableIssues,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles the completion checkbox status of an issue.
  Future<int> toggleIssueCompletion(int id, bool isCompleted) async {
    final db = await _db;
    return await db.update(
      DatabaseMigrations.tableIssues,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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
