import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/reference_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/activity_log_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/reference_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/activity_log_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/services/copy_context_service.dart';
import 'package:flutter_fishboster_personal_project_tracker/services/url_launcher_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProjectRepository projectRepo;
  late MilestoneRepository milestoneRepo;
  late BrainstormRepository brainstormRepo;
  late IssueRepository issueRepo;
  late ReferenceRepository referenceRepo;
  late ActivityLogRepository activityLogRepo;
  late CopyContextService copyContextService;

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

    projectRepo = ProjectRepository(db: db);
    milestoneRepo = MilestoneRepository(db: db);
    brainstormRepo = BrainstormRepository(db: db);
    issueRepo = IssueRepository(db: db);
    referenceRepo = ReferenceRepository(db: db);
    activityLogRepo = ActivityLogRepository(db: db);

    copyContextService = CopyContextService(
      projectRepository: projectRepo,
      milestoneRepository: milestoneRepo,
      brainstormRepository: brainstormRepo,
      issueRepository: issueRepo,
      referenceRepository: referenceRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 8: End-to-End Regression & Data Integrity Tests', () {
    test('Multi-project isolation: operations on Project A do not mutate Project B', () async {
      final pA = await projectRepo.insertProject(
        ProjectModel(name: 'Project Alpha', description: 'Alpha Desc'),
      );
      final pB = await projectRepo.insertProject(
        ProjectModel(name: 'Project Beta', description: 'Beta Desc'),
      );

      final mA = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pA, name: 'Milestone A1', sortOrder: 0),
      );
      final mB = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pB, name: 'Milestone B1', sortOrder: 0),
      );

      await brainstormRepo.insertBrainstorm(
        BrainstormModel(projectId: pA, milestoneId: mA, title: 'Idea Alpha 1'),
      );
      await brainstormRepo.insertBrainstorm(
        BrainstormModel(projectId: pB, milestoneId: mB, title: 'Idea Beta 1'),
      );

      await issueRepo.insertIssue(
        IssueModel(projectId: pA, milestoneId: mA, title: 'Bug Alpha 1'),
      );
      await issueRepo.insertIssue(
        IssueModel(projectId: pB, milestoneId: mB, title: 'Bug Beta 1'),
      );

      await referenceRepo.insertReference(
        ReferenceModel(projectId: pA, title: 'Ref Alpha', url: 'https://alpha.example.com'),
      );
      await referenceRepo.insertReference(
        ReferenceModel(projectId: pB, title: 'Ref Beta', url: 'https://beta.example.com'),
      );

      await activityLogRepo.insertLog(
        ActivityLogModel(
          projectId: pA,
          entityType: 'project',
          action: 'create',
          description: 'Created Project Alpha',
        ),
      );
      await activityLogRepo.insertLog(
        ActivityLogModel(
          projectId: pB,
          entityType: 'project',
          action: 'create',
          description: 'Created Project Beta',
        ),
      );

      // Verify Project A counts (includes auto-logs for project, milestone, brainstorm, issue, reference + 1 manual log = 6)
      expect(await milestoneRepo.getMilestonesByProjectId(pA), hasLength(1));
      expect(await brainstormRepo.getBrainstormsByProjectId(pA), hasLength(1));
      expect(await issueRepo.getIssuesByProjectId(pA), hasLength(1));
      expect(await referenceRepo.getReferencesByProjectId(pA), hasLength(1));
      expect(await activityLogRepo.getLogsByProjectId(pA), hasLength(6));

      // Verify Project B counts
      expect(await milestoneRepo.getMilestonesByProjectId(pB), hasLength(1));
      expect(await brainstormRepo.getBrainstormsByProjectId(pB), hasLength(1));
      expect(await issueRepo.getIssuesByProjectId(pB), hasLength(1));
      expect(await referenceRepo.getReferencesByProjectId(pB), hasLength(1));
      expect(await activityLogRepo.getLogsByProjectId(pB), hasLength(6));

      // Deleting Project A must cascade only Project A child records
      await projectRepo.deleteProject(pA);

      expect(await projectRepo.getProjectById(pA), isNull);
      expect(await milestoneRepo.getMilestonesByProjectId(pA), isEmpty);
      expect(await brainstormRepo.getBrainstormsByProjectId(pA), isEmpty);
      expect(await issueRepo.getIssuesByProjectId(pA), isEmpty);
      expect(await referenceRepo.getReferencesByProjectId(pA), isEmpty);
      expect(await activityLogRepo.getLogsByProjectId(pA), isEmpty);

      // Project B must remain completely intact
      expect(await projectRepo.getProjectById(pB), isNotNull);
      expect(await milestoneRepo.getMilestonesByProjectId(pB), hasLength(1));
      expect(await brainstormRepo.getBrainstormsByProjectId(pB), hasLength(1));
      expect(await issueRepo.getIssuesByProjectId(pB), hasLength(1));
      expect(await referenceRepo.getReferencesByProjectId(pB), hasLength(1));
      expect(await activityLogRepo.getLogsByProjectId(pB), hasLength(6));
    });

    test('Milestone reorder transaction maintains sequential sort orders without corruption', () async {
      final pId = await projectRepo.insertProject(ProjectModel(name: 'Ordering App'));

      final m1Id = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pId, name: 'Step 1', sortOrder: 0),
      );
      final m2Id = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pId, name: 'Step 2', sortOrder: 1),
      );
      final m3Id = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pId, name: 'Step 3', sortOrder: 2),
      );
      final m4Id = await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: pId, name: 'Step 4', sortOrder: 3),
      );

      final m1 = (await milestoneRepo.getMilestoneById(m1Id))!;
      final m2 = (await milestoneRepo.getMilestoneById(m2Id))!;
      final m3 = (await milestoneRepo.getMilestoneById(m3Id))!;
      final m4 = (await milestoneRepo.getMilestoneById(m4Id))!;

      // Reorder: Move Step 4 to the top -> [Step 4, Step 1, Step 2, Step 3]
      await milestoneRepo.reorderMilestones(pId, [m4, m1, m2, m3]);

      final reordered = await milestoneRepo.getMilestonesByProjectId(pId);
      expect(reordered[0].id, equals(m4Id));
      expect(reordered[0].sortOrder, equals(0));
      expect(reordered[1].id, equals(m1Id));
      expect(reordered[1].sortOrder, equals(1));
      expect(reordered[2].id, equals(m2Id));
      expect(reordered[2].sortOrder, equals(2));
      expect(reordered[3].id, equals(m3Id));
      expect(reordered[3].sortOrder, equals(3));
    });

    test('Special characters, emojis, and multiline text are safely handled by SQLite', () async {
      const specialName = 'App with "Quotes", \'Apostrophes\', & Emoji 🚀🔥';
      const multilineDesc = '''
Line 1: # Header Title
Line 2: - [ ] Task with special symbols: < > & " ' %
Line 3: Emoji test 💡🐞🎯
''';

      final pId = await projectRepo.insertProject(
        ProjectModel(name: specialName, description: multilineDesc),
      );

      final retrieved = await projectRepo.getProjectById(pId);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals(specialName));
      expect(retrieved.description, equals(multilineDesc));

      // Test in Copy Context
      final promptContext = await copyContextService.generateProjectContext(pId);
      expect(promptContext, contains(specialName));
      expect(promptContext, contains('Line 3: Emoji test 💡🐞🎯'));
    });

    test('Copy Context on empty project produces clean markdown with zero placeholder artifacts', () async {
      final pId = await projectRepo.insertProject(
        ProjectModel(
          name: 'Bare Minimum Project',
          description: '',
          status: ProjectStatus.active,
        ),
      );

      final promptContext = await copyContextService.generateProjectContext(pId);
      expect(promptContext, contains('# Proyek: Bare Minimum Project'));
      expect(promptContext, contains('Status Proyek: Aktif'));
      // Must not contain empty sections
      expect(promptContext, isNot(contains('## Tahapan Pengembangan')));
      expect(promptContext, isNot(contains('## Ide & Gagasan Aktif')));
      expect(promptContext, isNot(contains('## Masalah & Kendala Aktif')));
      expect(promptContext, isNot(contains('## Referensi Proyek')));
    });

    test('Activity logs can be filtered by entityType and cleared per project', () async {
      final pId = await projectRepo.insertProject(ProjectModel(name: 'Log Test Project'));

      await activityLogRepo.insertLog(
        ActivityLogModel(projectId: pId, entityType: 'project', action: 'create', description: 'Log P'),
      );
      await activityLogRepo.insertLog(
        ActivityLogModel(projectId: pId, entityType: 'milestone', action: 'create', description: 'Log M'),
      );
      await activityLogRepo.insertLog(
        ActivityLogModel(projectId: pId, entityType: 'brainstorm', action: 'create', description: 'Log B'),
      );
      await activityLogRepo.insertLog(
        ActivityLogModel(projectId: pId, entityType: 'issue', action: 'create', description: 'Log I'),
      );

      final allLogs = await activityLogRepo.getLogsByProjectId(pId);
      expect(allLogs, hasLength(5)); // 1 auto-log from insertProject + 4 manual logs

      final milestoneLogs = await activityLogRepo.getLogsByProjectId(pId, entityType: 'milestone');
      expect(milestoneLogs, hasLength(1));
      expect(milestoneLogs.first.description, equals('Log M'));

      await activityLogRepo.clearLogsByProject(pId);
      expect(await activityLogRepo.getLogsByProjectId(pId), isEmpty);
    });
  });

  group('Phase 8: UrlLauncherService URL Validation Tests', () {
    test('isValidUrl accepts properly formatted web protocols and domain structures', () {
      expect(UrlLauncherService.isValidUrl('https://flutter.dev'), isTrue);
      expect(UrlLauncherService.isValidUrl('http://127.0.0.1:8080'), isTrue);
      expect(UrlLauncherService.isValidUrl('https://github.com/fishboster-apps/project?tab=readme#section'), isTrue);
      expect(UrlLauncherService.isValidUrl('http://192.168.1.1:3000/api'), isTrue);
      expect(UrlLauncherService.isValidUrl('docs.flutter.dev'), isTrue);
      expect(UrlLauncherService.isValidUrl('sub.domain.co.id/path/to/resource'), isTrue);
    });

    test('isValidUrl rejects invalid, blank, or unsupported URI schemes', () {
      expect(UrlLauncherService.isValidUrl(''), isFalse);
      expect(UrlLauncherService.isValidUrl('   '), isFalse);
      expect(UrlLauncherService.isValidUrl('ftp://ftp.example.com'), isFalse);
      expect(UrlLauncherService.isValidUrl('file:///path/to/file'), isFalse);
      expect(UrlLauncherService.isValidUrl('not_a_valid_url'), isFalse);
      expect(UrlLauncherService.isValidUrl('javascript:alert(1)'), isFalse);
    });
  });
}
