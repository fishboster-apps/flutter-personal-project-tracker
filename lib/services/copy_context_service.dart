import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/models/brainstorm_model.dart';
import '../data/models/issue_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/reference_model.dart';
import '../data/repositories/brainstorm_repository.dart';
import '../data/repositories/issue_repository.dart';
import '../data/repositories/milestone_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/reference_repository.dart';

typedef ClipboardSetter = Future<void> Function(String text);

/// Service responsible for generating structured prompt contexts from projects,
/// milestones, ideas, and issues for AI coding tools (LLM) and copying them to clipboard.
class CopyContextService {
  final ProjectRepository _projectRepo;
  final MilestoneRepository _milestoneRepo;
  final BrainstormRepository _brainstormRepo;
  final IssueRepository _issueRepo;
  final ReferenceRepository _referenceRepo;
  final ClipboardSetter? customClipboardSetter;

  CopyContextService({
    ProjectRepository? projectRepository,
    MilestoneRepository? milestoneRepository,
    BrainstormRepository? brainstormRepository,
    IssueRepository? issueRepository,
    ReferenceRepository? referenceRepository,
    this.customClipboardSetter,
  })  : _projectRepo = projectRepository ?? ProjectRepository(),
        _milestoneRepo = milestoneRepository ?? MilestoneRepository(),
        _brainstormRepo = brainstormRepository ?? BrainstormRepository(),
        _issueRepo = issueRepository ?? IssueRepository(),
        _referenceRepo = referenceRepository ?? ReferenceRepository();

  /// Copies [text] to the device clipboard and displays a friendly SnackBar feedback.
  Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String successMessage = 'Konteks berhasil disalin ke clipboard',
  }) async {
    final setter = customClipboardSetter;
    if (setter != null) {
      await setter(text);
    } else {
      await Clipboard.setData(ClipboardData(text: text));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Generates full structured prompt context for an entire project.
  /// Only includes uncompleted ideas and issues.
  Future<String> generateProjectContext(int projectId) async {
    final project = await _projectRepo.getProjectById(projectId);
    if (project == null) {
      throw Exception('Proyek tidak ditemukan');
    }

    final milestones = await _milestoneRepo.getMilestonesByProjectId(projectId);
    final allBrainstorms =
        await _brainstormRepo.getBrainstormsByProjectId(projectId);
    final allIssues = await _issueRepo.getIssuesByProjectId(projectId);
    final allReferences =
        await _referenceRepo.getReferencesByProjectId(projectId);

    // Filter only active (uncompleted) items
    final activeBrainstorms =
        allBrainstorms.where((b) => !b.isCompleted).toList();
    final activeIssues = allIssues.where((i) => !i.isCompleted).toList();

    // Map references by brainstorm and issue id
    final refsByBrainstorm = <int, List<ReferenceModel>>{};
    final refsByIssue = <int, List<ReferenceModel>>{};
    final standaloneRefs = <ReferenceModel>[];

    for (final ref in allReferences) {
      if (ref.isBrainstormRelated && ref.brainstormId != null) {
        refsByBrainstorm.putIfAbsent(ref.brainstormId!, () => []).add(ref);
      } else if (ref.isIssueRelated && ref.issueId != null) {
        refsByIssue.putIfAbsent(ref.issueId!, () => []).add(ref);
      } else if (ref.isStandalone) {
        standaloneRefs.add(ref);
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('# Proyek: ${project.name}');
    if (project.description.trim().isNotEmpty) {
      buffer.writeln(project.description.trim());
      buffer.writeln();
    }
    buffer.writeln('Status Proyek: ${project.status.label}');
    buffer.writeln();

    // 1. Milestones
    if (milestones.isNotEmpty) {
      buffer.writeln('## Tahapan Pengembangan');
      for (final m in milestones) {
        final check = m.isCompleted ? '[x]' : '[ ]';
        buffer.writeln('- $check ${m.name}');
        if (m.description.trim().isNotEmpty) {
          buffer.writeln('  Deskripsi: ${m.description.trim()}');
        }
      }
      buffer.writeln();
    }

    // 2. Active Brainstorms
    if (activeBrainstorms.isNotEmpty) {
      buffer.writeln('## Ide & Gagasan Aktif');

      // Group by milestones
      final mIdsWithIdeas = <int>{};
      for (final m in milestones) {
        final mIdeas =
            activeBrainstorms.where((b) => b.milestoneId == m.id).toList();
        if (mIdeas.isNotEmpty) {
          mIdsWithIdeas.add(m.id!);
          buffer.writeln('### Tahapan: ${m.name}');
          for (final b in mIdeas) {
            _writeBrainstormItem(buffer, b, refsByBrainstorm[b.id]);
          }
          buffer.writeln();
        }
      }

      // Standalone ideas (without milestone)
      final standaloneIdeas =
          activeBrainstorms.where((b) => b.milestoneId == null).toList();
      if (standaloneIdeas.isNotEmpty) {
        if (mIdsWithIdeas.isNotEmpty) {
          buffer.writeln('### Ide Tambahan (Tanpa Tahapan)');
        }
        for (final b in standaloneIdeas) {
          _writeBrainstormItem(buffer, b, refsByBrainstorm[b.id]);
        }
        buffer.writeln();
      }
    }

    // 3. Active Issues
    if (activeIssues.isNotEmpty) {
      buffer.writeln('## Masalah & Kendala Aktif');

      // Group by milestones
      final mIdsWithIssues = <int>{};
      for (final m in milestones) {
        final mIssues =
            activeIssues.where((i) => i.milestoneId == m.id).toList();
        if (mIssues.isNotEmpty) {
          mIdsWithIssues.add(m.id!);
          buffer.writeln('### Tahapan: ${m.name}');
          for (final i in mIssues) {
            _writeIssueItem(buffer, i, refsByIssue[i.id]);
          }
          buffer.writeln();
        }
      }

      // Standalone issues (without milestone)
      final standaloneIssues =
          activeIssues.where((i) => i.milestoneId == null).toList();
      if (standaloneIssues.isNotEmpty) {
        if (mIdsWithIssues.isNotEmpty) {
          buffer.writeln('### Kendala Tambahan (Tanpa Tahapan)');
        }
        for (final i in standaloneIssues) {
          _writeIssueItem(buffer, i, refsByIssue[i.id]);
        }
        buffer.writeln();
      }
    }

    // 4. Standalone References
    if (standaloneRefs.isNotEmpty) {
      buffer.writeln('## Referensi Proyek');
      for (final ref in standaloneRefs) {
        _writeReferenceItem(buffer, ref);
      }
    }

    return buffer.toString().trim();
  }

  /// Generates structured prompt context for a single milestone.
  /// Only includes uncompleted ideas and issues belonging to this milestone.
  Future<String> generateMilestoneContext(int milestoneId) async {
    final milestone = await _milestoneRepo.getMilestoneById(milestoneId);
    if (milestone == null) {
      throw Exception('Tahapan tidak ditemukan');
    }

    final project = await _projectRepo.getProjectById(milestone.projectId);
    final allBrainstorms = await _brainstormRepo.getBrainstormsByProjectId(
      milestone.projectId,
      milestoneId: milestoneId,
    );
    final allIssues = await _issueRepo.getIssuesByProjectId(
      milestone.projectId,
      milestoneId: milestoneId,
    );
    final allReferences =
        await _referenceRepo.getReferencesByProjectId(milestone.projectId);

    final activeBrainstorms =
        allBrainstorms.where((b) => !b.isCompleted).toList();
    final activeIssues = allIssues.where((i) => !i.isCompleted).toList();

    final refsByBrainstorm = <int, List<ReferenceModel>>{};
    final refsByIssue = <int, List<ReferenceModel>>{};

    for (final ref in allReferences) {
      if (ref.isBrainstormRelated && ref.brainstormId != null) {
        refsByBrainstorm.putIfAbsent(ref.brainstormId!, () => []).add(ref);
      } else if (ref.isIssueRelated && ref.issueId != null) {
        refsByIssue.putIfAbsent(ref.issueId!, () => []).add(ref);
      }
    }

    final buffer = StringBuffer();
    if (project != null) {
      buffer.writeln('# Proyek: ${project.name}');
      if (project.description.trim().isNotEmpty) {
        buffer.writeln(project.description.trim());
        buffer.writeln();
      }
    }

    final statusText = milestone.isCompleted ? 'Selesai' : 'Sedang Berjalan';
    buffer.writeln('## Tahapan: ${milestone.name} [$statusText]');
    if (milestone.description.trim().isNotEmpty) {
      buffer.writeln('Deskripsi: ${milestone.description.trim()}');
      buffer.writeln();
    }

    // Active Brainstorms
    if (activeBrainstorms.isNotEmpty) {
      buffer.writeln('### Ide & Gagasan Aktif');
      for (final b in activeBrainstorms) {
        _writeBrainstormItem(buffer, b, refsByBrainstorm[b.id]);
      }
      buffer.writeln();
    }

    // Active Issues
    if (activeIssues.isNotEmpty) {
      buffer.writeln('### Masalah & Kendala Aktif');
      for (final i in activeIssues) {
        _writeIssueItem(buffer, i, refsByIssue[i.id]);
      }
    }

    return buffer.toString().trim();
  }

  /// Generates structured prompt context for a single brainstorm idea.
  Future<String> generateBrainstormContext(int brainstormId) async {
    final brainstorm = await _brainstormRepo.getBrainstormById(brainstormId);
    if (brainstorm == null) {
      throw Exception('Ide tidak ditemukan');
    }

    final project = await _projectRepo.getProjectById(brainstorm.projectId);
    MilestoneModel? milestone;
    if (brainstorm.milestoneId != null) {
      milestone = await _milestoneRepo.getMilestoneById(brainstorm.milestoneId!);
    }
    final references =
        await _referenceRepo.getReferencesByBrainstormId(brainstormId);

    final buffer = StringBuffer();
    if (project != null) {
      buffer.writeln('# Proyek: ${project.name}');
      if (project.description.trim().isNotEmpty) {
        buffer.writeln(project.description.trim());
        buffer.writeln();
      }
    }

    if (milestone != null) {
      buffer.writeln('Tahapan Terkait: ${milestone.name}');
    }

    buffer.writeln('## Ide & Gagasan: ${brainstorm.title}');
    if (brainstorm.description.trim().isNotEmpty) {
      buffer.writeln('Deskripsi:');
      buffer.writeln(brainstorm.description.trim());
      buffer.writeln();
    }
    buffer.writeln(
      'Status: ${brainstorm.isCompleted ? 'Selesai' : 'Aktif / Belum Selesai'}',
    );

    if (references.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### Referensi Terkait');
      for (final ref in references) {
        _writeReferenceItem(buffer, ref);
      }
    }

    return buffer.toString().trim();
  }

  /// Generates structured prompt context for a single issue.
  Future<String> generateIssueContext(int issueId) async {
    final issue = await _issueRepo.getIssueById(issueId);
    if (issue == null) {
      throw Exception('Kendala tidak ditemukan');
    }

    final project = await _projectRepo.getProjectById(issue.projectId);
    MilestoneModel? milestone;
    if (issue.milestoneId != null) {
      milestone = await _milestoneRepo.getMilestoneById(issue.milestoneId!);
    }
    final references = await _referenceRepo.getReferencesByIssueId(issueId);

    final buffer = StringBuffer();
    if (project != null) {
      buffer.writeln('# Proyek: ${project.name}');
      if (project.description.trim().isNotEmpty) {
        buffer.writeln(project.description.trim());
        buffer.writeln();
      }
    }

    if (milestone != null) {
      buffer.writeln('Tahapan Terkait: ${milestone.name}');
    }

    buffer.writeln('## Masalah & Kendala: ${issue.title}');
    if (issue.description.trim().isNotEmpty) {
      buffer.writeln('Deskripsi:');
      buffer.writeln(issue.description.trim());
      buffer.writeln();
    }
    buffer.writeln(
      'Status: ${issue.isCompleted ? 'Selesai / Teratasi' : 'Aktif / Belum Terselesaikan'}',
    );

    if (references.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### Referensi Terkait');
      for (final ref in references) {
        _writeReferenceItem(buffer, ref);
      }
    }

    return buffer.toString().trim();
  }

  void _writeBrainstormItem(
    StringBuffer buffer,
    BrainstormModel brainstorm,
    List<ReferenceModel>? refs,
  ) {
    buffer.writeln('- ${brainstorm.title}');
    if (brainstorm.description.trim().isNotEmpty) {
      buffer.writeln('  Deskripsi: ${brainstorm.description.trim()}');
    }
    if (refs != null && refs.isNotEmpty) {
      for (final ref in refs) {
        buffer.writeln('  Referensi: [${ref.title}](${ref.url})');
      }
    }
  }

  void _writeIssueItem(
    StringBuffer buffer,
    IssueModel issue,
    List<ReferenceModel>? refs,
  ) {
    buffer.writeln('- ${issue.title}');
    if (issue.description.trim().isNotEmpty) {
      buffer.writeln('  Deskripsi: ${issue.description.trim()}');
    }
    if (refs != null && refs.isNotEmpty) {
      for (final ref in refs) {
        buffer.writeln('  Referensi: [${ref.title}](${ref.url})');
      }
    }
  }

  void _writeReferenceItem(StringBuffer buffer, ReferenceModel ref) {
    final notePart =
        ref.notes != null && ref.notes!.trim().isNotEmpty ? ' — ${ref.notes!.trim()}' : '';
    buffer.writeln('- [${ref.title}](${ref.url})$notePart');
  }
}
