import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Schema and Constraints Tests', () {
    late Database db;

    setUp(() async {
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseMigrations.currentVersion,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onCreate: DatabaseMigrations.onCreate,
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('All 6 tables are created', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();

      expect(
        tableNames,
        containsAll([
          DatabaseMigrations.tableProjects,
          DatabaseMigrations.tableMilestones,
          DatabaseMigrations.tableBrainstorms,
          DatabaseMigrations.tableIssues,
          DatabaseMigrations.tableReferences,
          DatabaseMigrations.tableActivityLogs,
        ]),
      );
    });

    test('Foreign key enforcement prevents orphan child records', () async {
      final now = DateTime.now().toIso8601String();

      // Attempting to insert a milestone with non-existent project_id must fail
      expect(
        () async => await db.insert(
          DatabaseMigrations.tableMilestones,
          {
            'project_id': 9999,
            'name': 'Orphan Milestone',
            'created_at': now,
            'updated_at': now,
          },
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Cascade delete removes child records when project is deleted', () async {
      final now = DateTime.now().toIso8601String();

      // Insert project
      final projectId = await db.insert(
        DatabaseMigrations.tableProjects,
        {
          'name': 'Test Project',
          'description': 'Testing cascade',
          'status': 'active',
          'created_at': now,
          'updated_at': now,
        },
      );

      // Insert milestone
      final milestoneId = await db.insert(
        DatabaseMigrations.tableMilestones,
        {
          'project_id': projectId,
          'name': 'Milestone 1',
          'created_at': now,
          'updated_at': now,
        },
      );

      // Insert brainstorm
      await db.insert(
        DatabaseMigrations.tableBrainstorms,
        {
          'project_id': projectId,
          'milestone_id': milestoneId,
          'title': 'Brainstorm 1',
          'created_at': now,
          'updated_at': now,
        },
      );

      // Delete project
      await db.delete(
        DatabaseMigrations.tableProjects,
        where: 'id = ?',
        whereArgs: [projectId],
      );

      // Verify cascade
      final milestones = await db.query(
        DatabaseMigrations.tableMilestones,
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      final brainstorms = await db.query(
        DatabaseMigrations.tableBrainstorms,
        where: 'project_id = ?',
        whereArgs: [projectId],
      );

      expect(milestones, isEmpty);
      expect(brainstorms, isEmpty);
    });

    test('Deleting milestone sets milestone_id to NULL on brainstorms and issues', () async {
      final now = DateTime.now().toIso8601String();

      final projectId = await db.insert(
        DatabaseMigrations.tableProjects,
        {
          'name': 'Test Project',
          'created_at': now,
          'updated_at': now,
        },
      );

      final milestoneId = await db.insert(
        DatabaseMigrations.tableMilestones,
        {
          'project_id': projectId,
          'name': 'Milestone to delete',
          'created_at': now,
          'updated_at': now,
        },
      );

      final brainstormId = await db.insert(
        DatabaseMigrations.tableBrainstorms,
        {
          'project_id': projectId,
          'milestone_id': milestoneId,
          'title': 'Idea linked to milestone',
          'created_at': now,
          'updated_at': now,
        },
      );

      // Delete milestone
      await db.delete(
        DatabaseMigrations.tableMilestones,
        where: 'id = ?',
        whereArgs: [milestoneId],
      );

      // Brainstorm should still exist with milestone_id = null
      final result = await db.query(
        DatabaseMigrations.tableBrainstorms,
        where: 'id = ?',
        whereArgs: [brainstormId],
      );

      expect(result, isNotEmpty);
      expect(result.first['milestone_id'], isNull);
    });

    test('References constraint: cannot have both brainstorm_id and issue_id', () async {
      final now = DateTime.now().toIso8601String();

      final projectId = await db.insert(
        DatabaseMigrations.tableProjects,
        {
          'name': 'Test Project',
          'created_at': now,
          'updated_at': now,
        },
      );

      final brainstormId = await db.insert(
        DatabaseMigrations.tableBrainstorms,
        {
          'project_id': projectId,
          'title': 'Idea 1',
          'created_at': now,
          'updated_at': now,
        },
      );

      final issueId = await db.insert(
        DatabaseMigrations.tableIssues,
        {
          'project_id': projectId,
          'title': 'Issue 1',
          'created_at': now,
          'updated_at': now,
        },
      );

      // Inserting reference with BOTH brainstorm_id and issue_id must fail CHECK constraint
      expect(
        () async => await db.insert(
          DatabaseMigrations.tableReferences,
          {
            'project_id': projectId,
            'brainstorm_id': brainstormId,
            'issue_id': issueId,
            'title': 'Invalid Reference',
            'url': 'https://example.com',
            'created_at': now,
            'updated_at': now,
          },
        ),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
