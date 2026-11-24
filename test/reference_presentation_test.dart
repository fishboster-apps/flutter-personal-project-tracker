import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/reference_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/reference_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/references/reference_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/references/reference_form_dialog.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/references/reference_list_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/services/url_launcher_service.dart';

class FakeReferenceRepo extends Fake implements ReferenceRepository {
  final List<ReferenceModel> items = [];
  int _nextId = 1;

  @override
  Future<int> insertReference(ReferenceModel reference) async {
    final id = _nextId++;
    items.add(reference.copyWith(id: id));
    return id;
  }

  @override
  Future<List<ReferenceModel>> getReferencesByProjectId(
    int projectId, {
    int? brainstormId,
    int? issueId,
    bool standaloneOnly = false,
  }) async {
    return items.where((r) {
      if (r.projectId != projectId) return false;
      if (standaloneOnly) return r.isStandalone;
      if (brainstormId != null) return r.brainstormId == brainstormId;
      if (issueId != null) return r.issueId == issueId;
      return true;
    }).toList();
  }

  @override
  Future<ReferenceModel?> getReferenceById(int id) async {
    try {
      return items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateReference(ReferenceModel reference) async {
    final index = items.indexWhere((r) => r.id == reference.id);
    if (index != -1) {
      items[index] = reference;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteReference(int id) async {
    final count = items.where((r) => r.id == id).length;
    items.removeWhere((r) => r.id == id);
    return count;
  }

  @override
  Future<int> getReferenceCountByProject(int projectId) async {
    return items.where((r) => r.projectId == projectId).length;
  }
}

class FakeBrainstormRepo extends Fake implements BrainstormRepository {
  final List<BrainstormModel> items = [];

  @override
  Future<List<BrainstormModel>> getBrainstormsByProjectId(int projectId, {int? milestoneId, bool unassignedOnly = false}) async {
    return items.where((b) => b.projectId == projectId).toList();
  }

  @override
  Future<BrainstormModel?> getBrainstormById(int id) async {
    try {
      return items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

class FakeIssueRepo extends Fake implements IssueRepository {
  final List<IssueModel> items = [];

  @override
  Future<List<IssueModel>> getIssuesByProjectId(int projectId, {int? milestoneId, bool unassignedOnly = false}) async {
    return items.where((i) => i.projectId == projectId).toList();
  }

  @override
  Future<IssueModel?> getIssueById(int id) async {
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('Reference Presentation Layer Tests', () {
    late FakeReferenceRepo referenceRepo;
    late FakeBrainstormRepo brainstormRepo;
    late FakeIssueRepo issueRepo;
    late UrlLauncherService launcherService;

    setUp(() {
      referenceRepo = FakeReferenceRepo();
      brainstormRepo = FakeBrainstormRepo();
      issueRepo = FakeIssueRepo();
      launcherService = UrlLauncherService(
        customLauncher: (uri, mode) async => true,
      );

      brainstormRepo.items.add(
        BrainstormModel(id: 101, projectId: 1, title: 'AI Assistant Prompt'),
      );
      issueRepo.items.add(
        IssueModel(id: 202, projectId: 1, title: 'Database Deadlock'),
      );
    });

    testWidgets('ReferenceListScreen displays empty state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ReferenceListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: referenceRepo,
            brainstormRepository: brainstormRepo,
            issueRepository: issueRepo,
            launcherService: launcherService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada referensi tautan'), findsOneWidget);
      expect(find.text('Tambah Tautan Pertama'), findsOneWidget);
    });

    testWidgets('ReferenceListScreen displays items and filter chips work', (tester) async {
      await referenceRepo.insertReference(
        ReferenceModel(
          projectId: 1,
          title: 'Official Flutter Docs',
          url: 'https://docs.flutter.dev',
        ),
      );
      await referenceRepo.insertReference(
        ReferenceModel(
          projectId: 1,
          brainstormId: 101,
          title: 'Gemini AI Guidelines',
          url: 'https://ai.google.dev',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ReferenceListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: referenceRepo,
            brainstormRepository: brainstormRepo,
            issueRepository: issueRepo,
            launcherService: launcherService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Official Flutter Docs'), findsOneWidget);
      expect(find.text('Gemini AI Guidelines'), findsOneWidget);

      // Tap filter "Tautan Umum"
      await tester.tap(find.widgetWithText(ChoiceChip, 'Tautan Umum'));
      await tester.pumpAndSettle();

      expect(find.text('Official Flutter Docs'), findsOneWidget);
      expect(find.text('Gemini AI Guidelines'), findsNothing);

      // Tap filter "Ide Terkait"
      await tester.tap(find.widgetWithText(ChoiceChip, 'Ide Terkait'));
      await tester.pumpAndSettle();

      expect(find.text('Official Flutter Docs'), findsNothing);
      expect(find.text('Gemini AI Guidelines'), findsOneWidget);
    });

    testWidgets('ReferenceFormDialog validates fields and saves valid link', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ReferenceFormDialog.show(
                    context,
                    projectId: 1,
                    repository: referenceRepo,
                    brainstormRepository: brainstormRepo,
                    issueRepository: issueRepo,
                  );
                },
                child: const Text('Open Form'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Tautan Referensi'), findsOneWidget);

      // 1. Submit empty
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul referensi tidak boleh kosong'), findsOneWidget);
      expect(find.text('Tautan URL web tidak boleh kosong'), findsOneWidget);

      // 2. Invalid URL
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Referensi *'),
        'Material Icons',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat Tautan / URL Web *'),
        'not a valid url',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Format tautan tidak valid. Masukkan alamat web yang benar (contoh: https://...)'),
        findsOneWidget,
      );

      // 3. Valid URL without prefix (auto-prefixes https://)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat Tautan / URL Web *'),
        'fonts.google.com/icons',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(referenceRepo.items.length, equals(1));
      expect(referenceRepo.items.first.title, equals('Material Icons'));
      expect(referenceRepo.items.first.url, equals('https://fonts.google.com/icons'));
    });

    testWidgets('ReferenceDetailScreen shows details and handles deletion', (tester) async {
      final id = await referenceRepo.insertReference(
        ReferenceModel(
          projectId: 1,
          brainstormId: 101,
          title: 'Design System Figma',
          url: 'https://figma.com/file/12345',
          notes: 'Color palette and icons',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ReferenceDetailScreen(
            referenceId: id,
            repository: referenceRepo,
            brainstormRepository: brainstormRepo,
            issueRepository: issueRepo,
            launcherService: launcherService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Design System Figma'), findsOneWidget);
      expect(find.text('Terkait Ide: AI Assistant Prompt'), findsOneWidget);
      expect(find.text('https://figma.com/file/12345'), findsOneWidget);
      expect(find.text('Color palette and icons'), findsOneWidget);
      expect(find.text('Buka di Browser'), findsOneWidget);
      expect(find.text('Salin Tautan'), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Referensi'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus Referensi'));
      await tester.pumpAndSettle();

      expect(referenceRepo.items, isEmpty);
    });
  });
}
