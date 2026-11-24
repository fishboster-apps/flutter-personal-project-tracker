import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/database/migrations.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/reference_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/reference_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReferenceModel Unit Tests', () {
    test('Throws AssertionError when both brainstormId and issueId are provided', () {
      expect(
        () => ReferenceModel(
          projectId: 1,
          brainstormId: 2,
          issueId: 3,
          title: 'Invalid Reference',
          url: 'https://flutter.dev',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Identifies standalone, brainstorm-related, and issue-related types correctly', () {
      final standalone = ReferenceModel(
        projectId: 1,
        title: 'Docs',
        url: 'https://docs.flutter.dev',
      );
      expect(standalone.isStandalone, isTrue);
      expect(standalone.isBrainstormRelated, isFalse);
      expect(standalone.isIssueRelated, isFalse);

      final brainstormRef = ReferenceModel(
        projectId: 1,
        brainstormId: 5,
        title: 'Idea Link',
        url: 'https://pub.dev',
      );
      expect(brainstormRef.isStandalone, isFalse);
      expect(brainstormRef.isBrainstormRelated, isTrue);
      expect(brainstormRef.isIssueRelated, isFalse);

      final issueRef = ReferenceModel(
        projectId: 1,
        issueId: 7,
        title: 'Issue Fix',
        url: 'https://stackoverflow.com',
      );
      expect(issueRef.isStandalone, isFalse);
      expect(issueRef.isBrainstormRelated, isFalse);
      expect(issueRef.isIssueRelated, isTrue);
    });

    test('toMap and fromMap preserve all values correctly', () {
      final now = DateTime.now();
      final model = ReferenceModel(
        id: 10,
        projectId: 1,
        brainstormId: 2,
        title: 'Architecture Guide',
        url: 'https://medium.com/clean-architecture',
        notes: 'Read section 3 carefully',
        createdAt: now,
        updatedAt: now,
      );

      final map = model.toMap();
      final fromMap = ReferenceModel.fromMap(map);

      expect(fromMap.id, equals(10));
      expect(fromMap.projectId, equals(1));
      expect(fromMap.brainstormId, equals(2));
      expect(fromMap.issueId, isNull);
      expect(fromMap.title, equals('Architecture Guide'));
      expect(fromMap.url, equals('https://medium.com/clean-architecture'));
      expect(fromMap.notes, equals('Read section 3 carefully'));
      expect(fromMap.createdAt.toIso8601String(), equals(now.toIso8601String()));
      expect(fromMap.updatedAt.toIso8601String(), equals(now.toIso8601String()));
    });
  });

  group('ReferenceRepository SQLite CRUD & Constraint Tests', () {
    late Database db;
    late ProjectRepository projectRepository;
    late BrainstormRepository brainstormRepository;
    late IssueRepository issueRepository;
    late ReferenceRepository referenceRepository;
    late int testProjectId;
    late int testBrainstormId;
    late int testIssueId;

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
      brainstormRepository = BrainstormRepository(db: db);
      issueRepository = IssueRepository(db: db);
      referenceRepository = ReferenceRepository(db: db);

      testProjectId = await projectRepository.insertProject(
        ProjectModel(name: 'Tracker App', description: 'Testing references'),
      );

      testBrainstormId = await brainstormRepository.insertBrainstorm(
        BrainstormModel(projectId: testProjectId, title: 'AI Feature Idea'),
      );

      testIssueId = await issueRepository.insertIssue(
        IssueModel(projectId: testProjectId, title: 'SQLite Lock Issue'),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Insert standalone, brainstorm-linked, and issue-linked references', () async {
      // 1. Standalone
      final ref1Id = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          title: 'Official Flutter Docs',
          url: 'https://docs.flutter.dev',
          notes: 'Main reference documentation',
        ),
      );

      // 2. Brainstorm-linked
      final ref2Id = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          brainstormId: testBrainstormId,
          title: 'Gemini API Reference',
          url: 'https://ai.google.dev',
        ),
      );

      // 3. Issue-linked
      final ref3Id = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          issueId: testIssueId,
          title: 'SQLite Threading Explanation',
          url: 'https://sqlite.org/threadsafe.html',
        ),
      );

      expect(ref1Id, isPositive);
      expect(ref2Id, isPositive);
      expect(ref3Id, isPositive);

      // Retrieve by ID
      final ref1 = await referenceRepository.getReferenceById(ref1Id);
      expect(ref1, isNotNull);
      expect(ref1!.title, equals('Official Flutter Docs'));
      expect(ref1.isStandalone, isTrue);

      // Retrieve all
      final allRefs = await referenceRepository.getReferencesByProjectId(testProjectId);
      expect(allRefs.length, equals(3));

      // Filter standalone only
      final standaloneRefs = await referenceRepository.getReferencesByProjectId(
        testProjectId,
        standaloneOnly: true,
      );
      expect(standaloneRefs.length, equals(1));
      expect(standaloneRefs.first.id, equals(ref1Id));

      // Filter by brainstorm
      final brainstormRefs = await referenceRepository.getReferencesByProjectId(
        testProjectId,
        brainstormId: testBrainstormId,
      );
      expect(brainstormRefs.length, equals(1));
      expect(brainstormRefs.first.id, equals(ref2Id));

      // Filter by issue
      final issueRefs = await referenceRepository.getReferencesByProjectId(
        testProjectId,
        issueId: testIssueId,
      );
      expect(issueRefs.length, equals(1));
      expect(issueRefs.first.id, equals(ref3Id));

      // Helper methods
      final byBrainstormHelper = await referenceRepository.getReferencesByBrainstormId(testBrainstormId);
      expect(byBrainstormHelper.length, equals(1));
      expect(byBrainstormHelper.first.id, equals(ref2Id));

      final byIssueHelper = await referenceRepository.getReferencesByIssueId(testIssueId);
      expect(byIssueHelper.length, equals(1));
      expect(byIssueHelper.first.id, equals(ref3Id));

      // Count
      final count = await referenceRepository.getReferenceCountByProject(testProjectId);
      expect(count, equals(3));
    });

    test('Update reference properties', () async {
      final refId = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          title: 'Initial Title',
          url: 'https://initial.url',
          notes: 'Old notes',
        ),
      );

      final original = await referenceRepository.getReferenceById(refId);
      expect(original, isNotNull);

      await referenceRepository.updateReference(
        original!.copyWith(
          title: 'Updated Title',
          url: 'https://updated.url',
          notes: 'New notes',
          brainstormId: testBrainstormId,
        ),
      );

      final updated = await referenceRepository.getReferenceById(refId);
      expect(updated!.title, equals('Updated Title'));
      expect(updated.url, equals('https://updated.url'));
      expect(updated.notes, equals('New notes'));
      expect(updated.brainstormId, equals(testBrainstormId));
    });

    test('Delete reference', () async {
      final refId = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          title: 'To Be Deleted',
          url: 'https://delete.me',
        ),
      );

      final deletedRows = await referenceRepository.deleteReference(refId);
      expect(deletedRows, equals(1));

      final fetched = await referenceRepository.getReferenceById(refId);
      expect(fetched, isNull);
    });

    test('Foreign key ON DELETE SET NULL: deleting brainstorm preserves reference with brainstorm_id = null', () async {
      final refId = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          brainstormId: testBrainstormId,
          title: 'Brainstorm Reference',
          url: 'https://example.com/brainstorm',
        ),
      );

      // Verify connected
      final beforeDelete = await referenceRepository.getReferenceById(refId);
      expect(beforeDelete!.brainstormId, equals(testBrainstormId));

      // Delete the brainstorm idea
      await brainstormRepository.deleteBrainstorm(testBrainstormId);

      // Reference should still exist and become standalone
      final afterDelete = await referenceRepository.getReferenceById(refId);
      expect(afterDelete, isNotNull);
      expect(afterDelete!.brainstormId, isNull);
      expect(afterDelete.isStandalone, isTrue);
    });

    test('Foreign key ON DELETE SET NULL: deleting issue preserves reference with issue_id = null', () async {
      final refId = await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          issueId: testIssueId,
          title: 'Issue Reference',
          url: 'https://example.com/issue',
        ),
      );

      // Verify connected
      final beforeDelete = await referenceRepository.getReferenceById(refId);
      expect(beforeDelete!.issueId, equals(testIssueId));

      // Delete the issue
      await issueRepository.deleteIssue(testIssueId);

      // Reference should still exist and become standalone
      final afterDelete = await referenceRepository.getReferenceById(refId);
      expect(afterDelete, isNotNull);
      expect(afterDelete!.issueId, isNull);
      expect(afterDelete.isStandalone, isTrue);
    });

    test('Foreign key CASCADE: deleting project removes all related references', () async {
      await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          title: 'Cascade Reference 1',
          url: 'https://cascade1.com',
        ),
      );
      await referenceRepository.insertReference(
        ReferenceModel(
          projectId: testProjectId,
          brainstormId: testBrainstormId,
          title: 'Cascade Reference 2',
          url: 'https://cascade2.com',
        ),
      );

      // Delete the whole project
      await projectRepository.deleteProject(testProjectId);

      final remainingRefs = await referenceRepository.getReferencesByProjectId(testProjectId);
      expect(remainingRefs, isEmpty);
    });
  });
}
