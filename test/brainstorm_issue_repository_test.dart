import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BrainstormRepository & IssueRepository SQLite Tests', () {
    late Database db;
    late ProjectRepository projectRepository;
    late MilestoneRepository milestoneRepository;
    late BrainstormRepository brainstormRepository;
    late IssueRepository issueRepository;
    late int testProjectId;
    late int testMilestoneId;

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
      brainstormRepository = BrainstormRepository(db: db);
      issueRepository = IssueRepository(db: db);

      testProjectId = await projectRepository.insertProject(
        ProjectModel(name: 'Tracker App', description: 'Testing items'),
      );

      testMilestoneId = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Phase 1 Setup'),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Brainstorm CRUD: insert, retrieve, update, toggle, delete', () async {
      // 1. Insert with milestone
      final id1 = await brainstormRepository.insertBrainstorm(
        BrainstormModel(
          projectId: testProjectId,
          milestoneId: testMilestoneId,
          title: 'Implement Dark Theme',
          description: 'Use pure black #121212',
        ),
      );

      // 2. Insert unassigned
      final id2 = await brainstormRepository.insertBrainstorm(
        BrainstormModel(
          projectId: testProjectId,
          title: 'Export to JSON',
          description: 'Backup data easily',
        ),
      );

      expect(id1, isPositive);
      expect(id2, isPositive);

      // 3. Retrieve by ID
      final item1 = await brainstormRepository.getBrainstormById(id1);
      expect(item1, isNotNull);
      expect(item1!.title, equals('Implement Dark Theme'));
      expect(item1.milestoneId, equals(testMilestoneId));
      expect(item1.isCompleted, isFalse);

      // 4. Retrieve all vs milestone vs unassigned
      final allItems = await brainstormRepository.getBrainstormsByProjectId(testProjectId);
      expect(allItems.length, equals(2));

      final milestoneItems = await brainstormRepository.getBrainstormsByProjectId(
        testProjectId,
        milestoneId: testMilestoneId,
      );
      expect(milestoneItems.length, equals(1));
      expect(milestoneItems.first.id, equals(id1));

      final unassignedItems = await brainstormRepository.getBrainstormsByProjectId(
        testProjectId,
        unassignedOnly: true,
      );
      expect(unassignedItems.length, equals(1));
      expect(unassignedItems.first.id, equals(id2));

      // 5. Toggle completion
      await brainstormRepository.toggleBrainstormCompletion(id1, true);
      final toggled = await brainstormRepository.getBrainstormById(id1);
      expect(toggled!.isCompleted, isTrue);

      // 6. Check counts
      final counts = await brainstormRepository.getCountByProject(testProjectId);
      expect(counts.total, equals(2));
      expect(counts.completed, equals(1));

      // 7. Update item
      await brainstormRepository.updateBrainstorm(
        toggled.copyWith(title: 'Updated Dark Theme', description: 'Refined description'),
      );
      final updated = await brainstormRepository.getBrainstormById(id1);
      expect(updated!.title, equals('Updated Dark Theme'));
      expect(updated.description, equals('Refined description'));

      // 8. Delete item
      final deletedCount = await brainstormRepository.deleteBrainstorm(id1);
      expect(deletedCount, equals(1));
      final afterDelete = await brainstormRepository.getBrainstormById(id1);
      expect(afterDelete, isNull);
    });

    test('Issue CRUD: insert, retrieve, update, toggle, delete', () async {
      // 1. Insert with milestone
      final id1 = await issueRepository.insertIssue(
        IssueModel(
          projectId: testProjectId,
          milestoneId: testMilestoneId,
          title: 'Database lock error',
          description: 'Occurs during rapid writes',
        ),
      );

      // 2. Insert unassigned
      final id2 = await issueRepository.insertIssue(
        IssueModel(
          projectId: testProjectId,
          title: 'Color overflow on small screens',
        ),
      );

      expect(id1, isPositive);
      expect(id2, isPositive);

      // 3. Retrieve by ID
      final item1 = await issueRepository.getIssueById(id1);
      expect(item1, isNotNull);
      expect(item1!.title, equals('Database lock error'));
      expect(item1.milestoneId, equals(testMilestoneId));
      expect(item1.isCompleted, isFalse);

      // 4. Retrieve all vs milestone vs unassigned
      final allIssues = await issueRepository.getIssuesByProjectId(testProjectId);
      expect(allIssues.length, equals(2));

      final milestoneIssues = await issueRepository.getIssuesByProjectId(
        testProjectId,
        milestoneId: testMilestoneId,
      );
      expect(milestoneIssues.length, equals(1));
      expect(milestoneIssues.first.id, equals(id1));

      final unassignedIssues = await issueRepository.getIssuesByProjectId(
        testProjectId,
        unassignedOnly: true,
      );
      expect(unassignedIssues.length, equals(1));
      expect(unassignedIssues.first.id, equals(id2));

      // 5. Toggle completion
      await issueRepository.toggleIssueCompletion(id1, true);
      final toggled = await issueRepository.getIssueById(id1);
      expect(toggled!.isCompleted, isTrue);

      // 6. Check counts
      final counts = await issueRepository.getCountByProject(testProjectId);
      expect(counts.total, equals(2));
      expect(counts.completed, equals(1));

      // 7. Update item
      await issueRepository.updateIssue(
        toggled.copyWith(title: 'Resolved Database lock', description: 'Fixed using transaction'),
      );
      final updated = await issueRepository.getIssueById(id1);
      expect(updated!.title, equals('Resolved Database lock'));

      // 8. Delete item
      final deletedCount = await issueRepository.deleteIssue(id1);
      expect(deletedCount, equals(1));
      final afterDelete = await issueRepository.getIssueById(id1);
      expect(afterDelete, isNull);
    });

    test('Foreign key ON DELETE SET NULL: deleting milestone sets milestone_id to NULL without losing items', () async {
      final bId = await brainstormRepository.insertBrainstorm(
        BrainstormModel(
          projectId: testProjectId,
          milestoneId: testMilestoneId,
          title: 'Brainstorm linked to milestone',
        ),
      );

      final iId = await issueRepository.insertIssue(
        IssueModel(
          projectId: testProjectId,
          milestoneId: testMilestoneId,
          title: 'Issue linked to milestone',
        ),
      );

      // Verify linked
      expect((await brainstormRepository.getBrainstormById(bId))!.milestoneId, equals(testMilestoneId));
      expect((await issueRepository.getIssueById(iId))!.milestoneId, equals(testMilestoneId));

      // Delete the milestone
      await milestoneRepository.deleteMilestone(testMilestoneId);

      // Verify milestone is gone
      final fetchedMilestone = await milestoneRepository.getMilestoneById(testMilestoneId);
      expect(fetchedMilestone, isNull);

      // Verify brainstorm & issue still exist, and milestoneId is now NULL
      final bAfter = await brainstormRepository.getBrainstormById(bId);
      final iAfter = await issueRepository.getIssueById(iId);

      expect(bAfter, isNotNull);
      expect(bAfter!.milestoneId, isNull);

      expect(iAfter, isNotNull);
      expect(iAfter!.milestoneId, isNull);

      // Verify they now appear in unassigned queries
      final unassignedB = await brainstormRepository.getBrainstormsByProjectId(testProjectId, unassignedOnly: true);
      expect(unassignedB.any((b) => b.id == bId), isTrue);

      final unassignedI = await issueRepository.getIssuesByProjectId(testProjectId, unassignedOnly: true);
      expect(unassignedI.any((i) => i.id == iId), isTrue);
    });

    test('Foreign key CASCADE: deleting project removes all related brainstorms and issues', () async {
      await brainstormRepository.insertBrainstorm(
        BrainstormModel(
          projectId: testProjectId,
          title: 'Cascade item B',
        ),
      );
      await issueRepository.insertIssue(
        IssueModel(
          projectId: testProjectId,
          title: 'Cascade item I',
        ),
      );

      // Delete project
      await projectRepository.deleteProject(testProjectId);

      final remainingB = await brainstormRepository.getBrainstormsByProjectId(testProjectId);
      final remainingI = await issueRepository.getIssuesByProjectId(testProjectId);

      expect(remainingB, isEmpty);
      expect(remainingI, isEmpty);
    });
  });
}
