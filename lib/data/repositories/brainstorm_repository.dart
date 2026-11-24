import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/brainstorm_model.dart';

/// Summary count representing total and completed items.
class ItemSummaryCount {
  final int total;
  final int completed;

  const ItemSummaryCount({required this.total, required this.completed});

  int get uncompleted => total - completed;
}

/// Repository handling all database operations for Brainstorm (Ideas).
class BrainstormRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;

  BrainstormRepository({DatabaseHelper? dbHelper, Database? db})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db;

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new brainstorm idea.
  Future<int> insertBrainstorm(BrainstormModel brainstorm) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableBrainstorms,
      brainstorm.toMap(),
    );
  }

  /// Retrieves brainstorms for a project with optional filtering.
  /// If [milestoneId] is provided, filters by that milestone.
  /// If [unassignedOnly] is true, filters for items where milestone_id IS NULL.
  Future<List<BrainstormModel>> getBrainstormsByProjectId(
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
      DatabaseMigrations.tableBrainstorms,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'is_completed ASC, updated_at DESC',
    );
    return results.map((map) => BrainstormModel.fromMap(map)).toList();
  }

  /// Finds a single brainstorm idea by its primary key [id].
  Future<BrainstormModel?> getBrainstormById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableBrainstorms,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return BrainstormModel.fromMap(results.first);
  }

  /// Updates an existing brainstorm idea.
  Future<int> updateBrainstorm(BrainstormModel brainstorm) async {
    final db = await _db;
    if (brainstorm.id == null) {
      throw ArgumentError('Cannot update brainstorm without an id.');
    }
    return await db.update(
      DatabaseMigrations.tableBrainstorms,
      brainstorm.toMap(),
      where: 'id = ?',
      whereArgs: [brainstorm.id],
    );
  }

  /// Deletes a brainstorm idea by [id].
  Future<int> deleteBrainstorm(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableBrainstorms,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles the completion checkbox status of a brainstorm idea.
  Future<int> toggleBrainstormCompletion(int id, bool isCompleted) async {
    final db = await _db;
    return await db.update(
      DatabaseMigrations.tableBrainstorms,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calculates total and completed brainstorm ideas for a project.
  Future<ItemSummaryCount> getCountByProject(int projectId) async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as total, COALESCE(SUM(is_completed), 0) as completed FROM ${DatabaseMigrations.tableBrainstorms} WHERE project_id = ?',
      [projectId],
    );
    final total = (results.first['total'] as int?) ?? 0;
    final completed = (results.first['completed'] as int?) ?? 0;
    return ItemSummaryCount(total: total, completed: completed);
  }
}
