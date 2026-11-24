import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/migrations.dart';
import '../models/project_model.dart';

/// Repository handling all database operations for Projects.
class ProjectRepository {
  final DatabaseHelper _dbHelper;
  final Database? _overrideDb;

  ProjectRepository({DatabaseHelper? dbHelper, Database? db})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _overrideDb = db;

  Future<Database> get _db async => _overrideDb ?? await _dbHelper.database;

  /// Inserts a new project and returns the generated primary key [id].
  Future<int> insertProject(ProjectModel project) async {
    final db = await _db;
    return await db.insert(
      DatabaseMigrations.tableProjects,
      project.toMap(),
    );
  }

  /// Retrieves all projects ordered by updated date descending.
  Future<List<ProjectModel>> getAllProjects() async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableProjects,
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => ProjectModel.fromMap(map)).toList();
  }

  /// Finds a project by its primary key [id], or returns `null` if not found.
  Future<ProjectModel?> getProjectById(int id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableProjects,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProjectModel.fromMap(results.first);
  }

  /// Updates an existing project and returns the number of rows affected.
  Future<int> updateProject(ProjectModel project) async {
    final db = await _db;
    if (project.id == null) {
      throw ArgumentError('Cannot update project without an id.');
    }
    return await db.update(
      DatabaseMigrations.tableProjects,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// Deletes a project by [id]. Cascading will remove child records.
  Future<int> deleteProject(int id) async {
    final db = await _db;
    return await db.delete(
      DatabaseMigrations.tableProjects,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Searches projects where name contains [query] (case-insensitive).
  Future<List<ProjectModel>> searchProjects(String query) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableProjects,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => ProjectModel.fromMap(map)).toList();
  }

  /// Retrieves all projects with a specific [status].
  Future<List<ProjectModel>> getProjectsByStatus(ProjectStatus status) async {
    final db = await _db;
    final results = await db.query(
      DatabaseMigrations.tableProjects,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => ProjectModel.fromMap(map)).toList();
  }
}
