import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MilestoneRepository Tests', () {
    late Database db;
    late ProjectRepository projectRepository;
    late MilestoneRepository milestoneRepository;
    late int testProjectId;

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

      projectRepository = ProjectRepository(db: db);
      milestoneRepository = MilestoneRepository(db: db);

      testProjectId = await projectRepository.insertProject(
        ProjectModel(name: 'Tracker App', description: 'Testing milestones'),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('insertMilestone auto-assigns sortOrder and retrieves by id', () async {
      final m1 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Phase 1 Foundation'),
      );
      final m2 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Phase 2 Features'),
      );

      final fetched1 = await milestoneRepository.getMilestoneById(m1);
      final fetched2 = await milestoneRepository.getMilestoneById(m2);

      expect(fetched1, isNotNull);
      expect(fetched1!.name, equals('Phase 1 Foundation'));
      expect(fetched1.sortOrder, equals(0));

      expect(fetched2, isNotNull);
      expect(fetched2!.name, equals('Phase 2 Features'));
      expect(fetched2.sortOrder, equals(1));
    });

    test('getMilestonesByProjectId returns milestones ordered by sort_order ASC', () async {
      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Milestone 0'),
      );
      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Milestone 1'),
      );
      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Milestone 2'),
      );

      final list = await milestoneRepository.getMilestonesByProjectId(testProjectId);
      expect(list.length, equals(3));
      expect(list[0].name, equals('Milestone 0'));
      expect(list[1].name, equals('Milestone 1'));
      expect(list[2].name, equals('Milestone 2'));
    });

    test('updateMilestone updates milestone name and description', () async {
      final id = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Draft'),
      );

      final existing = await milestoneRepository.getMilestoneById(id);
      expect(existing, isNotNull);

      final updated = existing!.copyWith(
        name: 'Finalized',
        description: 'New Description',
      );
      final rows = await milestoneRepository.updateMilestone(updated);
      expect(rows, equals(1));

      final reloaded = await milestoneRepository.getMilestoneById(id);
      expect(reloaded!.name, equals('Finalized'));
      expect(reloaded.description, equals('New Description'));
    });

    test('toggleMilestoneCompletion updates completion status', () async {
      final id = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Task'),
      );

      var milestone = await milestoneRepository.getMilestoneById(id);
      expect(milestone!.isCompleted, isFalse);

      await milestoneRepository.toggleMilestoneCompletion(id, true);
      milestone = await milestoneRepository.getMilestoneById(id);
      expect(milestone!.isCompleted, isTrue);

      await milestoneRepository.toggleMilestoneCompletion(id, false);
      milestone = await milestoneRepository.getMilestoneById(id);
      expect(milestone!.isCompleted, isFalse);
    });

    test('reorderMilestones updates sort_order within a transaction', () async {
      final id1 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'A'),
      );
      final id2 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'B'),
      );
      final id3 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'C'),
      );

      final m1 = (await milestoneRepository.getMilestoneById(id1))!;
      final m2 = (await milestoneRepository.getMilestoneById(id2))!;
      final m3 = (await milestoneRepository.getMilestoneById(id3))!;

      // Reorder to C, A, B
      await milestoneRepository.reorderMilestones(testProjectId, [m3, m1, m2]);

      final reordered = await milestoneRepository.getMilestonesByProjectId(testProjectId);
      expect(reordered[0].name, equals('C'));
      expect(reordered[0].sortOrder, equals(0));
      expect(reordered[1].name, equals('A'));
      expect(reordered[1].sortOrder, equals(1));
      expect(reordered[2].name, equals('B'));
      expect(reordered[2].sortOrder, equals(2));
    });

    test('getProjectProgress calculates accurate counts and percentage', () async {
      // 0 milestones -> 0%
      var progress = await milestoneRepository.getProjectProgress(testProjectId);
      expect(progress.total, equals(0));
      expect(progress.completed, equals(0));
      expect(progress.percentage, equals(0.0));

      final id1 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'M1'),
      );
      final id2 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'M2'),
      );

      // 2 milestones, 0 completed -> 0%
      progress = await milestoneRepository.getProjectProgress(testProjectId);
      expect(progress.total, equals(2));
      expect(progress.completed, equals(0));
      expect(progress.percentage, equals(0.0));

      // 1 completed -> 50%
      await milestoneRepository.toggleMilestoneCompletion(id1, true);
      progress = await milestoneRepository.getProjectProgress(testProjectId);
      expect(progress.total, equals(2));
      expect(progress.completed, equals(1));
      expect(progress.percentage, equals(50.0));
      expect(progress.percentageInt, equals(50));

      // 2 completed -> 100%
      await milestoneRepository.toggleMilestoneCompletion(id2, true);
      progress = await milestoneRepository.getProjectProgress(testProjectId);
      expect(progress.total, equals(2));
      expect(progress.completed, equals(2));
      expect(progress.percentage, equals(100.0));
    });

    test('getAllProjectsProgress returns map of projectId to progress', () async {
      final p2 = await projectRepository.insertProject(
        ProjectModel(name: 'Project Two'),
      );

      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'T1', isCompleted: true),
      );
      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'T2', isCompleted: false),
      );
      await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: p2, name: 'P2M1', isCompleted: true),
      );

      final map = await milestoneRepository.getAllProjectsProgress();
      expect(map[testProjectId]?.total, equals(2));
      expect(map[testProjectId]?.completed, equals(1));
      expect(map[p2]?.total, equals(1));
      expect(map[p2]?.completed, equals(1));
    });

    test('deleteMilestone removes the milestone', () async {
      final id = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'ToDelete'),
      );

      final rows = await milestoneRepository.deleteMilestone(id);
      expect(rows, equals(1));

      final found = await milestoneRepository.getMilestoneById(id);
      expect(found, isNull);
    });
  });
}
