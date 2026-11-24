import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/reference_model.dart';

/// Repository for handling CRUD and queries for Project References.
class ReferenceRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;

  ReferenceRepository({DatabaseHelper? dbHelper, Database? db})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db;

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new reference item.
  Future<int> insertReference(ReferenceModel reference) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableReferences,
      reference.toMap(),
    );
  }

  /// Retrieves references for a project with optional filters.
  /// If [standaloneOnly] is true, returns references where both brainstorm_id and issue_id are NULL.
  /// If [brainstormId] is provided, returns references linked to that brainstorm.
  /// If [issueId] is provided, returns references linked to that issue.
  Future<List<ReferenceModel>> getReferencesByProjectId(
    int projectId, {
    int? brainstormId,
    int? issueId,
    bool standaloneOnly = false,
  }) async {
    final db = await _db;
    String whereClause = 'project_id = ?';
    final whereArgs = <dynamic>[projectId];

    if (standaloneOnly) {
      whereClause += ' AND brainstorm_id IS NULL AND issue_id IS NULL';
    } else if (brainstormId != null) {
      whereClause += ' AND brainstorm_id = ?';
      whereArgs.add(brainstormId);
    } else if (issueId != null) {
      whereClause += ' AND issue_id = ?';
      whereArgs.add(issueId);
    }

    final result = await db.query(
      DatabaseMigrations.tableReferences,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return result.map((map) => ReferenceModel.fromMap(map)).toList();
  }

  /// Retrieves all references connected to a specific brainstorm idea.
  Future<List<ReferenceModel>> getReferencesByBrainstormId(int brainstormId) async {
    final db = await _db;
    final result = await db.query(
      DatabaseMigrations.tableReferences,
      where: 'brainstorm_id = ?',
      whereArgs: [brainstormId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => ReferenceModel.fromMap(map)).toList();
  }

  /// Retrieves all references connected to a specific issue.
  Future<List<ReferenceModel>> getReferencesByIssueId(int issueId) async {
    final db = await _db;
    final result = await db.query(
      DatabaseMigrations.tableReferences,
      where: 'issue_id = ?',
      whereArgs: [issueId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => ReferenceModel.fromMap(map)).toList();
  }

  /// Retrieves a single reference by its [id].
  Future<ReferenceModel?> getReferenceById(int id) async {
    final db = await _db;
    final result = await db.query(
      DatabaseMigrations.tableReferences,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return ReferenceModel.fromMap(result.first);
    }
    return null;
  }

  /// Updates an existing reference.
  Future<int> updateReference(ReferenceModel reference) async {
    if (reference.id == null) return 0;
    final db = await _db;
    final updated = reference.copyWith(updatedAt: DateTime.now());
    return await db.update(
      DatabaseMigrations.tableReferences,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [reference.id],
    );
  }

  /// Deletes a reference by its [id].
  Future<int> deleteReference(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableReferences,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns total count of references for a given [projectId].
  Future<int> getReferenceCountByProject(int projectId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM "${DatabaseMigrations.tableReferences}" WHERE project_id = ?',
      [projectId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
