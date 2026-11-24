import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/reference_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/reference_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/services/copy_context_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CopyContextService Unit Tests', () {
    late Database db;
    late ProjectRepository projectRepo;
    late MilestoneRepository milestoneRepo;
    late BrainstormRepository brainstormRepo;
    late IssueRepository issueRepo;
    late ReferenceRepository referenceRepo;
    late CopyContextService service;

    late int projectId;
    late int m2Id;
    late int b1ActiveId;
    late int i1ActiveId;

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

      service = CopyContextService(
        projectRepository: projectRepo,
        milestoneRepository: milestoneRepo,
        brainstormRepository: brainstormRepo,
        issueRepository: issueRepo,
        referenceRepository: referenceRepo,
      );

      // 1. Create Project
      projectId = await projectRepo.insertProject(
        ProjectModel(
          name: 'Tracker Master',
          description: 'A comprehensive project management app for solo devs',
          status: ProjectStatus.active,
        ),
      );

      // 2. Create Milestones (1 completed, 1 in progress)
      await milestoneRepo.insertMilestone(
        MilestoneModel(
          projectId: projectId,
          name: 'Phase 1 Core',
          description: 'Core infrastructure setup',
          isCompleted: true,
          sortOrder: 1,
        ),
      );
      m2Id = await milestoneRepo.insertMilestone(
        MilestoneModel(
          projectId: projectId,
          name: 'Phase 2 Features',
          description: 'Main feature implementation',
          isCompleted: false,
          sortOrder: 2,
        ),
      );

      // 3. Create Brainstorms (1 active on m2, 1 completed on m2, 1 active standalone)
      b1ActiveId = await brainstormRepo.insertBrainstorm(
        BrainstormModel(
          projectId: projectId,
          milestoneId: m2Id,
          title: 'Export to Markdown',
          description: 'Allow users to export prompt as raw markdown file',
          isCompleted: false,
        ),
      );
      await brainstormRepo.insertBrainstorm(
        BrainstormModel(
          projectId: projectId,
          milestoneId: m2Id,
          title: 'Old Feature Idea',
          description: 'Already finished idea',
          isCompleted: true,
        ),
      );
      await brainstormRepo.insertBrainstorm(
        BrainstormModel(
          projectId: projectId,
          title: 'Cloud Backup Idea',
          description: 'Optional remote sync via Google Drive',
          isCompleted: false,
        ),
      );

      // 4. Create Issues (1 active on m2, 1 completed on m2, 1 active standalone)
      i1ActiveId = await issueRepo.insertIssue(
        IssueModel(
          projectId: projectId,
          milestoneId: m2Id,
          title: 'Clipboard Lock Bug',
          description: 'Clipboard service fails on background thread',
          isCompleted: false,
        ),
      );
      await issueRepo.insertIssue(
        IssueModel(
          projectId: projectId,
          milestoneId: m2Id,
          title: 'Fixed Crash Bug',
          description: 'Old issue that was solved',
          isCompleted: true,
        ),
      );
      await issueRepo.insertIssue(
        IssueModel(
          projectId: projectId,
          title: 'Uncategorized Memory Bug',
          description: 'High memory usage on image loading',
          isCompleted: false,
        ),
      );

      // 5. Create References (1 standalone, 1 linked to active idea)
      await referenceRepo.insertReference(
        ReferenceModel(
          projectId: projectId,
          title: 'Flutter Documentation',
          url: 'https://docs.flutter.dev',
          notes: 'Main API reference',
        ),
      );
      await referenceRepo.insertReference(
        ReferenceModel(
          projectId: projectId,
          brainstormId: b1ActiveId,
          title: 'Markdown Spec',
          url: 'https://commonmark.org',
          notes: 'CommonMark syntax guidelines',
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('generateProjectContext includes all required sections and strictly excludes completed items', () async {
      final context = await service.generateProjectContext(projectId);

      // Project info
      expect(context, contains('# Proyek: Tracker Master'));
      expect(context, contains('A comprehensive project management app for solo devs'));
      expect(context, contains('Status Proyek: Active'));

      // Milestones
      expect(context, contains('## Tahapan Pengembangan'));
      expect(context, contains('- [x] Phase 1 Core'));
      expect(context, contains('  Deskripsi: Core infrastructure setup'));
      expect(context, contains('- [ ] Phase 2 Features'));
      expect(context, contains('  Deskripsi: Main feature implementation'));

      // Active Brainstorms
      expect(context, contains('## Ide & Gagasan Aktif'));
      expect(context, contains('### Tahapan: Phase 2 Features'));
      expect(context, contains('- Export to Markdown'));
      expect(context, contains('  Deskripsi: Allow users to export prompt as raw markdown file'));
      expect(context, contains('  Referensi: [Markdown Spec](https://commonmark.org)'));
      expect(context, contains('### Ide Tambahan (Tanpa Tahapan)'));
      expect(context, contains('- Cloud Backup Idea'));

      // Completed brainstorm must NOT be in context!
      expect(context, isNot(contains('Old Feature Idea')));

      // Active Issues
      expect(context, contains('## Masalah & Kendala Aktif'));
      expect(context, contains('- Clipboard Lock Bug'));
      expect(context, contains('  Deskripsi: Clipboard service fails on background thread'));
      expect(context, contains('### Kendala Tambahan (Tanpa Tahapan)'));
      expect(context, contains('- Uncategorized Memory Bug'));

      // Completed issue must NOT be in context!
      expect(context, isNot(contains('Fixed Crash Bug')));

      // Standalone reference
      expect(context, contains('## Referensi Proyek'));
      expect(context, contains('- [Flutter Documentation](https://docs.flutter.dev) — Main API reference'));
    });

    test('generateMilestoneContext includes milestone details, active items, and excludes completed items', () async {
      final context = await service.generateMilestoneContext(m2Id);

      expect(context, contains('# Proyek: Tracker Master'));
      expect(context, contains('## Tahapan: Phase 2 Features [Sedang Berjalan]'));
      expect(context, contains('Deskripsi: Main feature implementation'));

      // Active brainstorms for m2
      expect(context, contains('### Ide & Gagasan Aktif'));
      expect(context, contains('- Export to Markdown'));
      expect(context, contains('  Referensi: [Markdown Spec](https://commonmark.org)'));
      expect(context, isNot(contains('Old Feature Idea')));
      expect(context, isNot(contains('Cloud Backup Idea'))); // Belonged to no milestone

      // Active issues for m2
      expect(context, contains('### Masalah & Kendala Aktif'));
      expect(context, contains('- Clipboard Lock Bug'));
      expect(context, isNot(contains('Fixed Crash Bug')));
      expect(context, isNot(contains('Uncategorized Memory Bug'))); // Belonged to no milestone
    });

    test('generateBrainstormContext includes project info, milestone link, details, and linked reference', () async {
      final context = await service.generateBrainstormContext(b1ActiveId);

      expect(context, contains('# Proyek: Tracker Master'));
      expect(context, contains('Tahapan Terkait: Phase 2 Features'));
      expect(context, contains('## Ide & Gagasan: Export to Markdown'));
      expect(context, contains('Allow users to export prompt as raw markdown file'));
      expect(context, contains('Status: Aktif / Belum Selesai'));
      expect(context, contains('### Referensi Terkait'));
      expect(context, contains('- [Markdown Spec](https://commonmark.org) — CommonMark syntax guidelines'));
    });

    test('generateIssueContext includes project info, milestone link, details, and status', () async {
      final context = await service.generateIssueContext(i1ActiveId);

      expect(context, contains('# Proyek: Tracker Master'));
      expect(context, contains('Tahapan Terkait: Phase 2 Features'));
      expect(context, contains('## Masalah & Kendala: Clipboard Lock Bug'));
      expect(context, contains('Clipboard service fails on background thread'));
      expect(context, contains('Status: Aktif / Belum Terselesaikan'));
    });

    test('Handles missing / empty entities gracefully without placeholder text', () async {
      // Create empty project
      final emptyProjId = await projectRepo.insertProject(
        ProjectModel(name: 'Empty Project', description: ''),
      );

      final context = await service.generateProjectContext(emptyProjId);
      expect(context, contains('# Proyek: Empty Project'));
      expect(context, isNot(contains('## Tahapan Pengembangan')));
      expect(context, isNot(contains('## Ide & Gagasan Aktif')));
      expect(context, isNot(contains('## Masalah & Kendala Aktif')));
      expect(context, isNot(contains('## Referensi Proyek')));
    });
  });
}
