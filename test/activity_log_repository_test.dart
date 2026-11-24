import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/activity_log_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/reference_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/activity_log_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/reference_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ActivityLogModel Unit Tests', () {
    test('toMap and fromMap preserve all values correctly', () {
      final now = DateTime(2026, 11, 24, 10, 30);
      final model = ActivityLogModel(
        id: 1,
        projectId: 10,
        entityType: 'milestone',
        entityId: 5,
        action: 'complete',
        description: 'Menyelesaikan tahapan "Database Design"',
        createdAt: now,
      );

      final map = model.toMap();
      final fromMap = ActivityLogModel.fromMap(map);

      expect(fromMap.id, equals(1));
      expect(fromMap.projectId, equals(10));
      expect(fromMap.entityType, equals('milestone'));
      expect(fromMap.entityId, equals(5));
      expect(fromMap.action, equals('complete'));
      expect(fromMap.description, equals('Menyelesaikan tahapan "Database Design"'));
      expect(fromMap.createdAt, equals(now));
    });

    test('entityLabel returns correct Indonesian label', () {
      expect(
        ActivityLogModel(projectId: 1, entityType: 'project', action: 'create', description: '').entityLabel,
        equals('Proyek'),
      );
      expect(
        ActivityLogModel(projectId: 1, entityType: 'milestone', action: 'create', description: '').entityLabel,
        equals('Tahapan'),
      );
      expect(
        ActivityLogModel(projectId: 1, entityType: 'brainstorm', action: 'create', description: '').entityLabel,
        equals('Ide'),
      );
      expect(
        ActivityLogModel(projectId: 1, entityType: 'issue', action: 'create', description: '').entityLabel,
        equals('Kendala'),
      );
      expect(
        ActivityLogModel(projectId: 1, entityType: 'reference', action: 'create', description: '').entityLabel,
        equals('Referensi'),
      );
      expect(
        ActivityLogModel(projectId: 1, entityType: 'unknown', action: 'create', description: '').entityLabel,
        equals('Aktivitas'),
      );
    });

    test('icon and color return representative indicators', () {
      final completeLog = ActivityLogModel(
        projectId: 1,
        entityType: 'milestone',
        action: 'complete',
        description: 'Complete task',
      );
      expect(completeLog.icon, equals(Icons.check_circle_outline));
      expect(completeLog.color, equals(AppColors.success));

      final deleteLog = ActivityLogModel(
        projectId: 1,
        entityType: 'brainstorm',
        action: 'delete',
        description: 'Deleted idea',
      );
      expect(deleteLog.icon, equals(Icons.delete_outline));
      expect(deleteLog.color, equals(AppColors.error));

      final issueLog = ActivityLogModel(
        projectId: 1,
        entityType: 'issue',
        action: 'create',
        description: 'Created issue',
      );
      expect(issueLog.icon, equals(Icons.bug_report_outlined));
      expect(issueLog.color, equals(AppColors.warning));

      final reorderLog = ActivityLogModel(
        projectId: 1,
        entityType: 'milestone',
        action: 'reorder',
        description: 'Reordered milestones',
      );
      expect(reorderLog.icon, equals(Icons.reorder));
      expect(reorderLog.color, equals(AppColors.primaryAccent));
    });

    test('formatRelativeTime returns natural Indonesian phrasing', () {
      final base = DateTime(2026, 11, 24, 12, 0, 0);

      // Just now (< 60s)
      final justNowLog = ActivityLogModel(
        projectId: 1,
        entityType: 'project',
        action: 'create',
        description: 'test',
        createdAt: base.subtract(const Duration(seconds: 30)),
      );
      expect(justNowLog.formatRelativeTime(referenceNow: base), equals('Baru saja'));

      // Minutes ago
      final minLog = ActivityLogModel(
        projectId: 1,
        entityType: 'project',
        action: 'create',
        description: 'test',
        createdAt: base.subtract(const Duration(minutes: 15)),
      );
      expect(minLog.formatRelativeTime(referenceNow: base), equals('15 menit lalu'));

      // Hours ago today
      final hoursLog = ActivityLogModel(
        projectId: 1,
        entityType: 'project',
        action: 'create',
        description: 'test',
        createdAt: base.subtract(const Duration(hours: 3)),
      );
      expect(hoursLog.formatRelativeTime(referenceNow: base), equals('3 jam lalu'));

      // Yesterday
      final yesterdayLog = ActivityLogModel(
        projectId: 1,
        entityType: 'project',
        action: 'create',
        description: 'test',
        createdAt: DateTime(2026, 11, 23, 15, 30),
      );
      expect(yesterdayLog.formatRelativeTime(referenceNow: base), equals('Kemarin, 15:30'));
    });
  });

  group('ActivityLogRepository SQLite & Auto-logging Tests', () {
    late Database db;
    late ActivityLogRepository logRepository;
    late ProjectRepository projectRepository;
    late MilestoneRepository milestoneRepository;
    late BrainstormRepository brainstormRepository;
    late IssueRepository issueRepository;
    late ReferenceRepository referenceRepository;
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

      logRepository = ActivityLogRepository(db: db);
      projectRepository = ProjectRepository(db: db, logRepository: logRepository);
      milestoneRepository = MilestoneRepository(db: db, logRepository: logRepository);
      brainstormRepository = BrainstormRepository(db: db, logRepository: logRepository);
      issueRepository = IssueRepository(db: db, logRepository: logRepository);
      referenceRepository = ReferenceRepository(db: db, logRepository: logRepository);

      // Create initial project (which also logs project create)
      testProjectId = await projectRepository.insertProject(
        ProjectModel(name: 'Auto Log Project', description: 'Testing all activities'),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Project creation and update are automatically logged', () async {
      final initialLogs = await logRepository.getLogsByProjectId(testProjectId);
      expect(initialLogs, hasLength(1));
      expect(initialLogs.first.entityType, equals('project'));
      expect(initialLogs.first.action, equals('create'));
      expect(initialLogs.first.description, contains('Membuat proyek "Auto Log Project"'));

      // Update project
      final project = await projectRepository.getProjectById(testProjectId);
      await projectRepository.updateProject(
        project!.copyWith(name: 'Renamed Project', status: ProjectStatus.completed),
      );

      final updatedLogs = await logRepository.getLogsByProjectId(testProjectId);
      expect(updatedLogs, hasLength(2));
      expect(updatedLogs.first.action, equals('update'));
      expect(updatedLogs.first.description, contains('Memperbarui informasi proyek "Renamed Project"'));
    });

    test('Milestone CRUD, completion, and reorder are automatically logged', () async {
      // 1. Create milestone
      final mId = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Setup Architecture', description: 'Core design'),
      );

      var logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'milestone');
      expect(logs, hasLength(1));
      expect(logs.first.action, equals('create'));
      expect(logs.first.description, equals('Menambahkan tahapan "Setup Architecture"'));

      // 2. Toggle completion
      await milestoneRepository.toggleMilestoneCompletion(mId, true);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'milestone');
      expect(logs, hasLength(2));
      expect(logs.first.action, equals('complete'));
      expect(logs.first.description, equals('Menyelesaikan tahapan "Setup Architecture"'));

      // 3. Update milestone
      final milestone = await milestoneRepository.getMilestoneById(mId);
      await milestoneRepository.updateMilestone(milestone!.copyWith(name: 'Setup Core Arch'));
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'milestone');
      expect(logs, hasLength(3));
      expect(logs.first.action, equals('update'));
      expect(logs.first.description, equals('Memperbarui tahapan "Setup Core Arch"'));

      // 4. Reorder milestones
      final mId2 = await milestoneRepository.insertMilestone(
        MilestoneModel(projectId: testProjectId, name: 'Second Milestone', description: ''),
      );
      final m1 = await milestoneRepository.getMilestoneById(mId);
      final m2 = await milestoneRepository.getMilestoneById(mId2);
      await milestoneRepository.reorderMilestones(testProjectId, [m2!, m1!]);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'milestone');
      expect(logs.first.action, equals('reorder'));
      expect(logs.first.description, equals('Mengubah urutan tahapan proyek'));

      // 5. Delete milestone
      await milestoneRepository.deleteMilestone(mId);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'milestone');
      expect(logs.first.action, equals('delete'));
      expect(logs.first.description, equals('Menghapus tahapan "Setup Core Arch"'));
    });

    test('Brainstorm CRUD and completion are automatically logged', () async {
      // 1. Create idea
      final bId = await brainstormRepository.insertBrainstorm(
        BrainstormModel(projectId: testProjectId, title: 'Dark Mode Switcher'),
      );
      var logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'brainstorm');
      expect(logs, hasLength(1));
      expect(logs.first.action, equals('create'));
      expect(logs.first.description, equals('Menambahkan ide "Dark Mode Switcher"'));

      // 2. Toggle completion
      await brainstormRepository.toggleBrainstormCompletion(bId, true);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'brainstorm');
      expect(logs, hasLength(2));
      expect(logs.first.action, equals('complete'));
      expect(logs.first.description, equals('Menyelesaikan ide "Dark Mode Switcher"'));

      // 3. Update idea
      final idea = await brainstormRepository.getBrainstormById(bId);
      await brainstormRepository.updateBrainstorm(idea!.copyWith(title: 'Theme Switcher'));
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'brainstorm');
      expect(logs, hasLength(3));
      expect(logs.first.action, equals('update'));
      expect(logs.first.description, equals('Memperbarui ide "Theme Switcher"'));

      // 4. Delete idea
      await brainstormRepository.deleteBrainstorm(bId);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'brainstorm');
      expect(logs, hasLength(4));
      expect(logs.first.action, equals('delete'));
      expect(logs.first.description, equals('Menghapus ide "Theme Switcher"'));
    });

    test('Issue CRUD and completion are automatically logged', () async {
      // 1. Create issue
      final iId = await issueRepository.insertIssue(
        IssueModel(projectId: testProjectId, title: 'Memory Leak in ListView'),
      );
      var logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'issue');
      expect(logs, hasLength(1));
      expect(logs.first.action, equals('create'));
      expect(logs.first.description, equals('Mencatat kendala "Memory Leak in ListView"'));

      // 2. Toggle completion
      await issueRepository.toggleIssueCompletion(iId, true);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'issue');
      expect(logs, hasLength(2));
      expect(logs.first.action, equals('complete'));
      expect(logs.first.description, equals('Menandai kendala "Memory Leak in ListView" selesai/teratasi'));

      // 3. Update issue
      final issue = await issueRepository.getIssueById(iId);
      await issueRepository.updateIssue(issue!.copyWith(title: 'Memory Leak Fixed'));
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'issue');
      expect(logs, hasLength(3));
      expect(logs.first.action, equals('update'));
      expect(logs.first.description, equals('Memperbarui kendala "Memory Leak Fixed"'));

      // 4. Delete issue
      await issueRepository.deleteIssue(iId);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'issue');
      expect(logs, hasLength(4));
      expect(logs.first.action, equals('delete'));
      expect(logs.first.description, equals('Menghapus kendala "Memory Leak Fixed"'));
    });

    test('Reference CRUD is automatically logged', () async {
      // 1. Create reference
      final rId = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          title: 'Flutter Official Docs',
          url: 'https://docs.flutter.dev',
        ),
      );
      var logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'reference');
      expect(logs, hasLength(1));
      expect(logs.first.action, equals('create'));
      expect(logs.first.description, equals('Menambahkan referensi "Flutter Official Docs"'));

      // 2. Update reference
      final ref = await referenceRepository.getReferenceById(rId);
      await referenceRepository.updateReference(ref!.copyWith(title: 'Flutter API Docs'));
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'reference');
      expect(logs, hasLength(2));
      expect(logs.first.action, equals('update'));
      expect(logs.first.description, equals('Memperbarui referensi "Flutter API Docs"'));

      // 3. Delete reference
      await referenceRepository.deleteReference(rId);
      logs = await logRepository.getLogsByProjectId(testProjectId, entityType: 'reference');
      expect(logs, hasLength(3));
      expect(logs.first.action, equals('delete'));
      expect(logs.first.description, equals('Menghapus referensi "Flutter API Docs"'));
    });

    test('Activity log count and clearing logs operate accurately', () async {
      final initialCount = await logRepository.getLogCountByProject(testProjectId);
      expect(initialCount, equals(1)); // project creation

      await logRepository.log(
        projectId: testProjectId,
        entityType: 'milestone',
        action: 'create',
        description: 'Manual log test',
      );

      final updatedCount = await logRepository.getLogCountByProject(testProjectId);
      expect(updatedCount, equals(2));

      // Clear logs
      final deletedCount = await logRepository.clearLogsByProject(testProjectId);
      expect(deletedCount, equals(2));

      final finalCount = await logRepository.getLogCountByProject(testProjectId);
      expect(finalCount, equals(0));
    });

    test('Deleting project cascades and removes all activity logs', () async {
      await logRepository.log(
        projectId: testProjectId,
        entityType: 'brainstorm',
        action: 'create',
        description: 'Idea for project',
      );

      var logs = await logRepository.getLogsByProjectId(testProjectId);
      expect(logs.length, greaterThanOrEqualTo(2));

      // Delete project
      await projectRepository.deleteProject(testProjectId);

      // Verify logs for that project are CASCADE deleted
      logs = await logRepository.getLogsByProjectId(testProjectId);
      expect(logs, isEmpty);
    });
  });
}
