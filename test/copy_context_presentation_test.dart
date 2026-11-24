import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fishboster_personal_project_tracker/core/theme.dart';
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
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/brainstorms/brainstorm_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/issues/issue_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/milestones/milestone_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/presentation/screens/projects/project_detail_screen.dart';
import 'package:flutter_fishboster_personal_project_tracker/services/copy_context_service.dart';

class FakeCopyContextService extends Fake implements CopyContextService {
  String? lastCopiedText;
  int projectCallCount = 0;
  int milestoneCallCount = 0;
  int brainstormCallCount = 0;
  int issueCallCount = 0;

  @override
  Future<String> generateProjectContext(int projectId) async {
    projectCallCount++;
    return '# Proyek: Super Tracker Context';
  }

  @override
  Future<String> generateMilestoneContext(int milestoneId) async {
    milestoneCallCount++;
    return '## Tahapan: Core Feature Context';
  }

  @override
  Future<String> generateBrainstormContext(int brainstormId) async {
    brainstormCallCount++;
    return '## Ide: AI Chat Context';
  }

  @override
  Future<String> generateIssueContext(int issueId) async {
    issueCallCount++;
    return '## Masalah: Memory Leak Context';
  }

  @override
  Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String successMessage = 'Konteks berhasil disalin ke clipboard',
  }) async {
    lastCopiedText = text;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
  }
}

class FakeProjectRepository extends Fake implements ProjectRepository {
  final List<ProjectModel> _projects = [];

  @override
  Future<int> insertProject(ProjectModel p) async {
    _projects.add(p.copyWith(id: 1));
    return 1;
  }

  @override
  Future<ProjectModel?> getProjectById(int id) async {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

class FakeMilestoneRepository extends Fake implements MilestoneRepository {
  final List<MilestoneModel> _milestones = [];

  @override
  Future<MilestoneProgress> getProjectProgress(int projectId) async =>
      const MilestoneProgress(total: 0, completed: 0);

  @override
  Future<MilestoneModel?> getMilestoneById(int id) async {
    try {
      return _milestones.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertMilestone(MilestoneModel m) async {
    _milestones.add(m.copyWith(id: 1));
    return 1;
  }
}

class FakeBrainstormRepository extends Fake implements BrainstormRepository {
  final List<BrainstormModel> _ideas = [];

  @override
  Future<ItemSummaryCount> getCountByProject(int projectId) async =>
      const ItemSummaryCount(total: 0, completed: 0);

  @override
  Future<BrainstormModel?> getBrainstormById(int id) async {
    try {
      return _ideas.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BrainstormModel>> getBrainstormsByProjectId(
    int projectId, {
    int? milestoneId,
    bool unassignedOnly = false,
  }) async => [];

  @override
  Future<int> insertBrainstorm(BrainstormModel b) async {
    _ideas.add(b.copyWith(id: 1));
    return 1;
  }
}

class FakeIssueRepository extends Fake implements IssueRepository {
  final List<IssueModel> _issues = [];

  @override
  Future<ItemSummaryCount> getCountByProject(int projectId) async =>
      const ItemSummaryCount(total: 0, completed: 0);

  @override
  Future<IssueModel?> getIssueById(int id) async {
    try {
      return _issues.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<IssueModel>> getIssuesByProjectId(
    int projectId, {
    int? milestoneId,
    bool unassignedOnly = false,
  }) async => [];

  @override
  Future<int> insertIssue(IssueModel i) async {
    _issues.add(i.copyWith(id: 1));
    return 1;
  }
}

class FakeReferenceRepository extends Fake implements ReferenceRepository {
  @override
  Future<int> getReferenceCountByProject(int projectId) async => 0;

  @override
  Future<List<ReferenceModel>> getReferencesByBrainstormId(int brainstormId) async => [];

  @override
  Future<List<ReferenceModel>> getReferencesByIssueId(int issueId) async => [];
}

class FakeActivityLogRepository extends Fake implements ActivityLogRepository {
  @override
  Future<int> getLogCountByProject(int projectId) async => 0;

  @override
  Future<List<ActivityLogModel>> getLogsByProjectId(int projectId, {String? entityType, int limit = 100}) async => [];
}

void main() {
  group('Copy Context Presentation Tests', () {
    late FakeCopyContextService copyService;
    late FakeProjectRepository projectRepo;
    late FakeMilestoneRepository milestoneRepo;
    late FakeBrainstormRepository brainstormRepo;
    late FakeIssueRepository issueRepo;
    late FakeReferenceRepository referenceRepo;
    late FakeActivityLogRepository logRepo;

    setUp(() async {
      copyService = FakeCopyContextService();
      projectRepo = FakeProjectRepository();
      milestoneRepo = FakeMilestoneRepository();
      brainstormRepo = FakeBrainstormRepository();
      issueRepo = FakeIssueRepository();
      referenceRepo = FakeReferenceRepository();
      logRepo = FakeActivityLogRepository();

      await projectRepo.insertProject(
        ProjectModel(name: 'Project 1', description: 'Test project description'),
      );
      await milestoneRepo.insertMilestone(
        MilestoneModel(projectId: 1, name: 'Milestone 1', description: 'Test milestone'),
      );
      await brainstormRepo.insertBrainstorm(
        BrainstormModel(projectId: 1, title: 'Idea 1', description: 'Test idea'),
      );
      await issueRepo.insertIssue(
        IssueModel(projectId: 1, title: 'Issue 1', description: 'Test issue'),
      );
    });

    testWidgets('ProjectDetailScreen copies project context and displays SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ProjectDetailScreen(
            projectId: 1,
            repository: projectRepo,
            milestoneRepository: milestoneRepo,
            brainstormRepository: brainstormRepo,
            issueRepository: issueRepo,
            referenceRepository: referenceRepo,
            activityLogRepository: logRepo,
            copyContextService: copyService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Find copy button in AppBar
      final copyButton = find.byTooltip('Salin Konteks Proyek');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      expect(copyService.projectCallCount, equals(1));
      expect(copyService.lastCopiedText, equals('# Proyek: Super Tracker Context'));
      expect(find.text('Konteks proyek berhasil disalin ke clipboard'), findsOneWidget);
    });

    testWidgets('MilestoneDetailScreen copies milestone context and displays SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: MilestoneDetailScreen(
            milestoneId: 1,
            repository: milestoneRepo,
            brainstormRepository: brainstormRepo,
            issueRepository: issueRepo,
            copyContextService: copyService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final copyButton = find.byTooltip('Salin Konteks Tahapan');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      expect(copyService.milestoneCallCount, equals(1));
      expect(copyService.lastCopiedText, equals('## Tahapan: Core Feature Context'));
      expect(find.text('Konteks tahapan berhasil disalin ke clipboard'), findsOneWidget);
    });

    testWidgets('BrainstormDetailScreen copies idea context and displays SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: BrainstormDetailScreen(
            brainstormId: 1,
            repository: brainstormRepo,
            milestoneRepository: milestoneRepo,
            referenceRepository: referenceRepo,
            copyContextService: copyService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final copyButton = find.byTooltip('Salin Konteks Ide');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      expect(copyService.brainstormCallCount, equals(1));
      expect(copyService.lastCopiedText, equals('## Ide: AI Chat Context'));
      expect(find.text('Konteks ide berhasil disalin ke clipboard'), findsOneWidget);
    });

    testWidgets('IssueDetailScreen copies issue context and displays SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IssueDetailScreen(
            issueId: 1,
            repository: issueRepo,
            milestoneRepository: milestoneRepo,
            referenceRepository: referenceRepo,
            copyContextService: copyService,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final copyButton = find.byTooltip('Salin Konteks Masalah');
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      expect(copyService.issueCallCount, equals(1));
      expect(copyService.lastCopiedText, equals('## Masalah: Memory Leak Context'));
      expect(find.text('Konteks masalah berhasil disalin ke clipboard'), findsOneWidget);
    });
  });
}
