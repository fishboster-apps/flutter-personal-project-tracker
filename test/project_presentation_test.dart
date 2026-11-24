import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/milestone_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/project_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/milestone_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/project_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/projects/project_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/projects/project_form_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/projects/project_list_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/widgets/confirm_delete_dialog.dart';

class FakeProjectRepository extends Fake implements ProjectRepository {
  final List<ProjectModel> _items = [];
  int _nextId = 1;

  @override
  Future<int> insertProject(ProjectModel project) async {
    final id = _nextId++;
    _items.add(project.copyWith(id: id));
    return id;
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    return List.from(_items);
  }

  @override
  Future<ProjectModel?> getProjectById(int id) async {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateProject(ProjectModel project) async {
    final index = _items.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _items[index] = project;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteProject(int id) async {
    final count = _items.where((p) => p.id == id).length;
    _items.removeWhere((p) => p.id == id);
    return count;
  }

  @override
  Future<List<ProjectModel>> searchProjects(String query) async {
    return _items
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<ProjectModel>> getProjectsByStatus(ProjectStatus status) async {
    return _items.where((p) => p.status == status).toList();
  }
}

class FakeMilestoneRepository extends Fake implements MilestoneRepository {
  @override
  Future<Map<int, MilestoneProgress>> getAllProjectsProgress() async => {};

  @override
  Future<MilestoneProgress> getProjectProgress(int projectId) async =>
      const MilestoneProgress(total: 0, completed: 0);

  @override
  Future<List<MilestoneModel>> getMilestonesByProjectId(int projectId) async => [];
}

void main() {
  group('Presentation Layer Tests', () {
    late FakeProjectRepository repository;
    late FakeMilestoneRepository milestoneRepository;

    setUp(() {
      repository = FakeProjectRepository();
      milestoneRepository = FakeMilestoneRepository();
    });

    testWidgets('ProjectListScreen shows empty state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProjectListScreen(
            repository: repository,
            milestoneRepository: milestoneRepository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada proyek'), findsOneWidget);
      expect(find.text('Buat Proyek Pertama'), findsOneWidget);
    });

    testWidgets('ProjectListScreen shows project card after insertion', (tester) async {
      await repository.insertProject(
        ProjectModel(
          name: 'Personal Tracker',
          description: 'A great tracker app',
          status: ProjectStatus.active,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProjectListScreen(
            repository: repository,
            milestoneRepository: milestoneRepository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Personal Tracker'), findsOneWidget);
      expect(find.text('A great tracker app'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
    });

    testWidgets('ProjectFormScreen validates empty name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProjectFormScreen(repository: repository),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Simpan Proyek'));
      await tester.pumpAndSettle();

      expect(find.text('Nama proyek tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('ConfirmDeleteDialog calls onConfirm when confirmed', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ConfirmDeleteDialog.show(
                    context,
                    title: 'Hapus Item',
                    message: 'Yakin hapus?',
                    onConfirm: () => confirmed = true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Item'), findsOneWidget);
      expect(find.text('Yakin hapus?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('ProjectDetailScreen displays project info and handles delete', (tester) async {
      final id = await repository.insertProject(
        ProjectModel(
          name: 'App To Delete',
          description: 'Will be deleted soon',
          status: ProjectStatus.active,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProjectDetailScreen(
            projectId: id,
            repository: repository,
            milestoneRepository: milestoneRepository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('App To Delete'), findsOneWidget);
      expect(find.text('Will be deleted soon'), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Proyek'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus Proyek'));
      await tester.pumpAndSettle();

      final deleted = await repository.getProjectById(id);
      expect(deleted, isNull);
    });
  });
}
