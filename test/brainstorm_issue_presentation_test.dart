import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/brainstorm_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/issue_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/brainstorm_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/issue_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/brainstorms/brainstorm_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/brainstorms/brainstorm_form_dialog.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/brainstorms/brainstorm_list_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/issues/issue_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/issues/issue_form_dialog.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/issues/issue_list_screen.dart';

class FakeBrainstormRepo extends Fake implements BrainstormRepository {
  final List<BrainstormModel> items = [];
  int _nextId = 1;

  @override
  Future<int> insertBrainstorm(BrainstormModel item) async {
    final id = _nextId++;
    items.add(item.copyWith(id: id));
    return id;
  }

  @override
  Future<List<BrainstormModel>> getBrainstormsByProjectId(
    int projectId, {
    int? milestoneId,
    bool unassignedOnly = false,
  }) async {
    return items.where((b) {
      if (b.projectId != projectId) return false;
      if (unassignedOnly) return b.milestoneId == null;
      if (milestoneId != null) return b.milestoneId == milestoneId;
      return true;
    }).toList();
  }

  @override
  Future<BrainstormModel?> getBrainstormById(int id) async {
    try {
      return items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateBrainstorm(BrainstormModel item) async {
    final index = items.indexWhere((b) => b.id == item.id);
    if (index != -1) {
      items[index] = item;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteBrainstorm(int id) async {
    final count = items.where((b) => b.id == id).length;
    items.removeWhere((b) => b.id == id);
    return count;
  }

  @override
  Future<int> toggleBrainstormCompletion(int id, bool isCompleted) async {
    final index = items.indexWhere((b) => b.id == id);
    if (index != -1) {
      items[index] = items[index].copyWith(isCompleted: isCompleted);
      return 1;
    }
    return 0;
  }

  @override
  Future<ItemSummaryCount> getCountByProject(int projectId) async {
    final projectItems = items.where((b) => b.projectId == projectId).toList();
    final completed = projectItems.where((b) => b.isCompleted).length;
    return ItemSummaryCount(total: projectItems.length, completed: completed);
  }
}

class FakeIssueRepo extends Fake implements IssueRepository {
  final List<IssueModel> items = [];
  int _nextId = 1;

  @override
  Future<int> insertIssue(IssueModel item) async {
    final id = _nextId++;
    items.add(item.copyWith(id: id));
    return id;
  }

  @override
  Future<List<IssueModel>> getIssuesByProjectId(
    int projectId, {
    int? milestoneId,
    bool unassignedOnly = false,
  }) async {
    return items.where((i) {
      if (i.projectId != projectId) return false;
      if (unassignedOnly) return i.milestoneId == null;
      if (milestoneId != null) return i.milestoneId == milestoneId;
      return true;
    }).toList();
  }

  @override
  Future<IssueModel?> getIssueById(int id) async {
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateIssue(IssueModel item) async {
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteIssue(int id) async {
    final count = items.where((i) => i.id == id).length;
    items.removeWhere((i) => i.id == id);
    return count;
  }

  @override
  Future<int> toggleIssueCompletion(int id, bool isCompleted) async {
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      items[index] = items[index].copyWith(isCompleted: isCompleted);
      return 1;
    }
    return 0;
  }

  @override
  Future<ItemSummaryCount> getCountByProject(int projectId) async {
    final projectItems = items.where((i) => i.projectId == projectId).toList();
    final completed = projectItems.where((i) => i.isCompleted).length;
    return ItemSummaryCount(total: projectItems.length, completed: completed);
  }
}

class FakeMilestoneRepo extends Fake implements MilestoneRepository {
  final List<MilestoneModel> milestones = [];

  @override
  Future<List<MilestoneModel>> getMilestonesByProjectId(int projectId) async {
    return milestones.where((m) => m.projectId == projectId).toList();
  }

  @override
  Future<MilestoneModel?> getMilestoneById(int id) async {
    try {
      return milestones.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('Brainstorms & Issues Presentation Layer Tests', () {
    late FakeBrainstormRepo brainstormRepo;
    late FakeIssueRepo issueRepo;
    late FakeMilestoneRepo milestoneRepo;

    setUp(() {
      brainstormRepo = FakeBrainstormRepo();
      issueRepo = FakeIssueRepo();
      milestoneRepo = FakeMilestoneRepo();

      milestoneRepo.milestones.add(
        MilestoneModel(id: 10, projectId: 1, name: 'Sprint 1'),
      );
    });

    // ---------------- BRAINSTORMS ----------------
    testWidgets('BrainstormListScreen shows empty state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BrainstormListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: brainstormRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada ide'), findsOneWidget);
      expect(find.text('Tambah Ide Pertama'), findsOneWidget);
    });

    testWidgets('BrainstormListScreen displays items and toggles completion', (tester) async {
      await brainstormRepo.insertBrainstorm(
        BrainstormModel(
          projectId: 1,
          title: 'Add export to CSV',
          description: 'Allows exporting data',
          isCompleted: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BrainstormListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: brainstormRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Add export to CSV'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Tap checkbox to mark completed
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(brainstormRepo.items.first.isCompleted, isTrue);
    });

    testWidgets('BrainstormFormDialog validates required title and creates idea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BrainstormFormDialog.show(
                    context,
                    projectId: 1,
                    repository: brainstormRepo,
                    milestoneRepository: milestoneRepo,
                  );
                },
                child: const Text('Open Brainstorm Form'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Brainstorm Form'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Ide & Gagasan'), findsOneWidget);

      // Submit without title
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul ide tidak boleh kosong'), findsOneWidget);

      // Fill in title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Ide *'),
        'Implement biometric lock',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(brainstormRepo.items.length, equals(1));
      expect(brainstormRepo.items.first.title, equals('Implement biometric lock'));
    });

    testWidgets('BrainstormDetailScreen shows info and handles delete', (tester) async {
      final id = await brainstormRepo.insertBrainstorm(
        BrainstormModel(
          projectId: 1,
          milestoneId: 10,
          title: 'Idea with milestone',
          description: 'Linked to Sprint 1',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BrainstormDetailScreen(
            brainstormId: id,
            repository: brainstormRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Idea with milestone'), findsOneWidget);
      expect(find.text('Linked to Sprint 1'), findsOneWidget);
      expect(find.text('Tahapan: Sprint 1'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Ide'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus Ide'));
      await tester.pumpAndSettle();

      expect(brainstormRepo.items, isEmpty);
    });

    // ---------------- ISSUES ----------------
    testWidgets('IssueListScreen shows empty state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IssueListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: issueRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada masalah'), findsOneWidget);
      expect(find.text('Catat Masalah Pertama'), findsOneWidget);
    });

    testWidgets('IssueListScreen displays items and toggles completion', (tester) async {
      await issueRepo.insertIssue(
        IssueModel(
          projectId: 1,
          title: 'Memory leak on image upload',
          description: 'High memory usage noticed',
          isCompleted: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IssueListScreen(
            projectId: 1,
            projectName: 'Tracker App',
            repository: issueRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Memory leak on image upload'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Tap checkbox to mark resolved
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(issueRepo.items.first.isCompleted, isTrue);
    });

    testWidgets('IssueFormDialog validates required title and creates issue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  IssueFormDialog.show(
                    context,
                    projectId: 1,
                    repository: issueRepo,
                    milestoneRepository: milestoneRepo,
                  );
                },
                child: const Text('Open Issue Form'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Issue Form'));
      await tester.pumpAndSettle();

      expect(find.text('Catat Masalah & Kendala'), findsOneWidget);

      // Submit without title
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul masalah tidak boleh kosong'), findsOneWidget);

      // Fill in title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Masalah / Bug *'),
        'Crash on Android 14',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(issueRepo.items.length, equals(1));
      expect(issueRepo.items.first.title, equals('Crash on Android 14'));
    });

    testWidgets('IssueDetailScreen shows info and handles delete', (tester) async {
      final id = await issueRepo.insertIssue(
        IssueModel(
          projectId: 1,
          milestoneId: 10,
          title: 'Null pointer exception',
          description: 'Happens on empty list',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IssueDetailScreen(
            issueId: id,
            repository: issueRepo,
            milestoneRepository: milestoneRepo,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Null pointer exception'), findsOneWidget);
      expect(find.text('Happens on empty list'), findsOneWidget);
      expect(find.text('Tahapan: Sprint 1'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Masalah'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus Masalah'));
      await tester.pumpAndSettle();

      expect(issueRepo.items, isEmpty);
    });
  });
}
