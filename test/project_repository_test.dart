import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ProjectRepository Tests', () {
    late Database db;
    late ProjectRepository repository;

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
      repository = ProjectRepository(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertProject returns generated id and can be retrieved by getProjectById', () async {
      final project = ProjectModel(
        name: 'Alpha Project',
        description: 'First test project',
        status: ProjectStatus.active,
      );

      final id = await repository.insertProject(project);
      expect(id, isPositive);

      final retrieved = await repository.getProjectById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(id));
      expect(retrieved.name, equals('Alpha Project'));
      expect(retrieved.description, equals('First test project'));
      expect(retrieved.status, equals(ProjectStatus.active));
    });

    test('getAllProjects returns all projects ordered by updated_at DESC', () async {
      final p1 = ProjectModel(
        name: 'Project 1',
        updatedAt: DateTime(2026, 1, 1),
      );
      final p2 = ProjectModel(
        name: 'Project 2',
        updatedAt: DateTime(2026, 1, 2),
      );

      await repository.insertProject(p1);
      await repository.insertProject(p2);

      final all = await repository.getAllProjects();
      expect(all.length, equals(2));
      expect(all.first.name, equals('Project 2'));
      expect(all.last.name, equals('Project 1'));
    });

    test('updateProject updates fields correctly', () async {
      final id = await repository.insertProject(
        ProjectModel(name: 'Old Name', description: 'Old Desc'),
      );

      final existing = await repository.getProjectById(id);
      expect(existing, isNotNull);

      final updated = existing!.copyWith(
        name: 'New Name',
        description: 'Updated Desc',
        status: ProjectStatus.completed,
      );

      final rowsAffected = await repository.updateProject(updated);
      expect(rowsAffected, equals(1));

      final reloaded = await repository.getProjectById(id);
      expect(reloaded!.name, equals('New Name'));
      expect(reloaded.description, equals('Updated Desc'));
      expect(reloaded.status, equals(ProjectStatus.completed));
    });

    test('deleteProject removes the project', () async {
      final id = await repository.insertProject(
        ProjectModel(name: 'To Delete'),
      );

      final rowsAffected = await repository.deleteProject(id);
      expect(rowsAffected, equals(1));

      final retrieved = await repository.getProjectById(id);
      expect(retrieved, isNull);
    });

    test('searchProjects finds matching projects by name', () async {
      await repository.insertProject(ProjectModel(name: 'Flutter Tracker'));
      await repository.insertProject(ProjectModel(name: 'React Dashboard'));
      await repository.insertProject(ProjectModel(name: 'Tracker Backend'));

      final results = await repository.searchProjects('Tracker');
      expect(results.length, equals(2));
      expect(results.any((p) => p.name == 'Flutter Tracker'), isTrue);
      expect(results.any((p) => p.name == 'Tracker Backend'), isTrue);
    });

    test('getProjectsByStatus filters projects by status', () async {
      await repository.insertProject(
        ProjectModel(name: 'P1', status: ProjectStatus.active),
      );
      await repository.insertProject(
        ProjectModel(name: 'P2', status: ProjectStatus.onHold),
      );
      await repository.insertProject(
        ProjectModel(name: 'P3', status: ProjectStatus.active),
      );

      final activeProjects = await repository.getProjectsByStatus(ProjectStatus.active);
      expect(activeProjects.length, equals(2));

      final onHoldProjects = await repository.getProjectsByStatus(ProjectStatus.onHold);
      expect(onHoldProjects.length, equals(1));
      expect(onHoldProjects.first.name, equals('P2'));
    });
  });
}
