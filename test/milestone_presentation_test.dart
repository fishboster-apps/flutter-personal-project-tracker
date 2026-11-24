import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/milestones/milestone_form_dialog.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/milestones/milestone_list_screen.dart';

class FakeMilestoneRepository extends Fake implements MilestoneRepository {
  final List<MilestoneModel> _items = [];
  int _nextId = 1;

  @override
  Future<int> insertMilestone(MilestoneModel milestone) async {
    final id = _nextId++;
    final sortOrder = milestone.sortOrder > 0
        ? milestone.sortOrder
        : _items.where((m) => m.projectId == milestone.projectId).length;
    _items.add(milestone.copyWith(id: id, sortOrder: sortOrder));
    return id;
  }

  @override
  Future<List<MilestoneModel>> getMilestonesByProjectId(int projectId) async {
    final list = _items.where((m) => m.projectId == projectId).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  @override
  Future<MilestoneModel?> getMilestoneById(int id) async {
    try {
      return _items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateMilestone(MilestoneModel milestone) async {
    final index = _items.indexWhere((m) => m.id == milestone.id);
    if (index != -1) {
      _items[index] = milestone;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteMilestone(int id) async {
    final count = _items.where((m) => m.id == id).length;
    _items.removeWhere((m) => m.id == id);
    return count;
  }

  @override
  Future<int> toggleMilestoneCompletion(int id, bool isCompleted) async {
    final index = _items.indexWhere((m) => m.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isCompleted: isCompleted);
      return 1;
    }
    return 0;
  }

  @override
  Future<void> reorderMilestones(int projectId, List<MilestoneModel> reorderedList) async {
    for (int i = 0; i < reorderedList.length; i++) {
      final index = _items.indexWhere((m) => m.id == reorderedList[i].id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(sortOrder: i);
      }
    }
  }

  @override
  Future<MilestoneProgress> getProjectProgress(int projectId) async {
    final projectMilestones = _items.where((m) => m.projectId == projectId).toList();
    final completed = projectMilestones.where((m) => m.isCompleted).length;
    return MilestoneProgress(total: projectMilestones.length, completed: completed);
  }
}

void main() {
  group('Milestone Presentation Layer Tests', () {
    late FakeMilestoneRepository repository;

    setUp(() {
      repository = FakeMilestoneRepository();
    });

    testWidgets('MilestoneListScreen shows empty state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MilestoneListScreen(
            projectId: 1,
            projectName: 'Test Project',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada tahapan'), findsOneWidget);
      expect(find.text('Tambah Tahapan Pertama'), findsOneWidget);
    });

    testWidgets('MilestoneListScreen displays milestone items and progress header', (tester) async {
      await repository.insertMilestone(
        MilestoneModel(
          projectId: 1,
          name: 'Setup Architecture',
          description: 'Initial folder setup',
          isCompleted: true,
        ),
      );
      await repository.insertMilestone(
        MilestoneModel(
          projectId: 1,
          name: 'Build UI',
          description: 'Screens and components',
          isCompleted: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MilestoneListScreen(
            projectId: 1,
            projectName: 'Test Project',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Setup Architecture'), findsOneWidget);
      expect(find.text('Build UI'), findsOneWidget);
      expect(find.text('1 dari 2 selesai'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('MilestoneFormDialog validates required name field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MilestoneFormDialog.show(
                    context,
                    projectId: 1,
                    repository: repository,
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

      expect(find.text('Tambah Tahapan'), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama tahapan tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('MilestoneFormDialog saves new milestone correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  MilestoneFormDialog.show(
                    context,
                    projectId: 1,
                    repository: repository,
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

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Tahapan *'),
        'Database Migration',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final list = await repository.getMilestonesByProjectId(1);
      expect(list.length, equals(1));
      expect(list.first.name, equals('Database Migration'));
    });
  });
}
