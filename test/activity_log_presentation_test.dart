import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/models/activity_log_model.dart';
import 'package:flutter_fishboster_personal_project_tracker/data/repositories/activity_log_repository.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/activity_logs/activity_log_screen.dart';

class FakeActivityLogRepository extends Fake implements ActivityLogRepository {
  final List<ActivityLogModel> _logs = [];
  int _nextId = 1;

  @override
  Future<int> insertLog(ActivityLogModel log) async {
    final id = _nextId++;
    _logs.add(log.copyWith(id: id));
    return id;
  }

  @override
  Future<int> log({
    required int projectId,
    required String entityType,
    required String action,
    required String description,
    int? entityId,
    DateTime? createdAt,
  }) async {
    return await insertLog(
      ActivityLogModel(
        projectId: projectId,
        entityType: entityType,
        entityId: entityId,
        action: action,
        description: description,
        createdAt: createdAt,
      ),
    );
  }

  @override
  Future<List<ActivityLogModel>> getLogsByProjectId(
    int projectId, {
    String? entityType,
    int limit = 100,
  }) async {
    var filtered = _logs.where((l) => l.projectId == projectId);
    if (entityType != null && entityType.isNotEmpty) {
      filtered = filtered.where((l) => l.entityType == entityType);
    }
    final list = filtered.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }

  @override
  Future<int> getLogCountByProject(int projectId) async {
    return _logs.where((l) => l.projectId == projectId).length;
  }

  @override
  Future<int> clearLogsByProject(int projectId) async {
    final initialLength = _logs.length;
    _logs.removeWhere((l) => l.projectId == projectId);
    return initialLength - _logs.length;
  }
}

void main() {
  group('ActivityLogScreen Widget Tests', () {
    late FakeActivityLogRepository repository;

    setUp(() {
      repository = FakeActivityLogRepository();
    });

    testWidgets('Displays empty state when no activity logs exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ActivityLogScreen(
            projectId: 1,
            projectName: 'My Super App',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Aktivitas'), findsOneWidget);
      expect(find.text('My Super App'), findsOneWidget);
      expect(find.text('Belum ada riwayat aktivitas'), findsOneWidget);
      expect(
        find.text('Aktivitas perubahan proyek akan tercatat di sini secara otomatis.'),
        findsOneWidget,
      );
    });

    testWidgets('Displays timeline cards when activity logs exist', (tester) async {
      final now = DateTime.now();
      await repository.insertLog(
        ActivityLogModel(
          projectId: 1,
          entityType: 'milestone',
          action: 'complete',
          description: 'Menyelesaikan tahapan "Database Design"',
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
      );
      await repository.insertLog(
        ActivityLogModel(
          projectId: 1,
          entityType: 'brainstorm',
          action: 'create',
          description: 'Menambahkan ide "Voice Input"',
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ActivityLogScreen(
            projectId: 1,
            projectName: 'My Super App',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Menyelesaikan tahapan "Database Design"'), findsOneWidget);
      expect(find.text('Menambahkan ide "Voice Input"'), findsOneWidget);
      expect(find.text('Tahapan'), findsWidgets); // Filter chip and item badge
      expect(find.text('Ide'), findsWidgets); // Filter chip and item badge
      expect(find.text('5 menit lalu'), findsOneWidget);
      expect(find.text('2 menit lalu'), findsOneWidget);
    });

    testWidgets('Filters activity logs when filter chip is tapped', (tester) async {
      await repository.insertLog(
        ActivityLogModel(
          projectId: 1,
          entityType: 'milestone',
          action: 'complete',
          description: 'Menyelesaikan tahapan "Phase Alpha"',
        ),
      );
      await repository.insertLog(
        ActivityLogModel(
          projectId: 1,
          entityType: 'issue',
          action: 'create',
          description: 'Mencatat kendala "Crash on Startup"',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ActivityLogScreen(
            projectId: 1,
            projectName: 'My Super App',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Both visible initially
      expect(find.text('Menyelesaikan tahapan "Phase Alpha"'), findsOneWidget);
      expect(find.text('Mencatat kendala "Crash on Startup"'), findsOneWidget);

      // Tap filter chip "Tahapan"
      await tester.tap(find.widgetWithText(FilterChip, 'Tahapan'));
      await tester.pumpAndSettle();

      // Only milestone log is visible
      expect(find.text('Menyelesaikan tahapan "Phase Alpha"'), findsOneWidget);
      expect(find.text('Mencatat kendala "Crash on Startup"'), findsNothing);

      // Tap filter chip "Semua Riwayat" to reset
      await tester.tap(find.widgetWithText(FilterChip, 'Semua Riwayat'));
      await tester.pumpAndSettle();

      expect(find.text('Menyelesaikan tahapan "Phase Alpha"'), findsOneWidget);
      expect(find.text('Mencatat kendala "Crash on Startup"'), findsOneWidget);
    });

    testWidgets('Clears activity logs when confirm dialog is accepted', (tester) async {
      await repository.insertLog(
        ActivityLogModel(
          projectId: 1,
          entityType: 'project',
          action: 'create',
          description: 'Membuat proyek "My Super App"',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ActivityLogScreen(
            projectId: 1,
            projectName: 'My Super App',
            repository: repository,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Membuat proyek "My Super App"'), findsOneWidget);

      // Tap delete sweep icon in AppBar
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Bersihkan Riwayat'), findsWidgets);
      expect(find.text('Hapus Riwayat'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus Riwayat'));
      await tester.pumpAndSettle();

      // Empty state should be visible
      expect(find.text('Belum ada riwayat aktivitas'), findsOneWidget);
      expect(find.text('Riwayat aktivitas berhasil dibersihkan'), findsOneWidget);
    });
  });
}
