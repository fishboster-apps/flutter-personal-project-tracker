import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/activity_log_model.dart';

/// Repository for handling CRUD and queries for Activity Logs.
class ActivityLogRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;

  ActivityLogRepository({DatabaseHelper? dbHelper, Database? db})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db;

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new activity log entry.
  Future<int> insertLog(ActivityLogModel log) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableActivityLogs,
      log.toMap(),
    );
  }

  /// Helper method to record an activity quickly.
  Future<int> log({
    required int projectId,
    required String entityType,
    required String action,
    required String description,
    int? entityId,
    DateTime? createdAt,
  }) async {
    return await insertLog(
      ActivityLogModel(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        action: action,
        description: description,
        createdAt: createdAt,
      ),
    );
  }

  /// Retrieves activity logs for a project ordered by newest first.
  /// If [entityType] is provided, filters for that specific entity type.
  Future<List<ActivityLogModel>> getLogsByProjectId(
    int projectId, {
    String? entityType,
    int limit = 100,
  }) async {
    final db = await _db;
    String whereClause = 'project_id = ?';
    final whereArgs = <dynamic>[projectId];

    if (entityType != null && entityType.isNotEmpty) {
      whereClause += ' AND entity_type = ?';
      whereArgs.add(entityType);
    }

    final result = await db.query(
      DatabaseMigrations.tableActivityLogs,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return result.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  /// Returns total count of activity logs for a given [projectId].
  Future<int> getLogCountByProject(int projectId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseMigrations.tableActivityLogs} WHERE project_id = ?',
      [projectId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clears all logs for a project.
  Future<int> clearLogsByProject(int projectId) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableActivityLogs,
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }
}
