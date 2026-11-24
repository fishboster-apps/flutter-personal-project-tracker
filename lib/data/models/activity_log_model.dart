import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

/// Domain/Data model representing an Activity Log entry.
class ActivityLogModel {
  final int? id;
  final int projectId;
  final String entityType; // 'project', 'milestone', 'brainstorm', 'issue', 'reference'
  final int? entityId;
  final String action; // 'create', 'update', 'delete', 'complete', 'reorder'
  final String description;
  final DateTime createdAt;

  ActivityLogModel({
    this.id,
    required this.projectId,
    required this.entityType,
    this.entityId,
    required this.action,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts model instance to a Map for SQLite insertion.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'project_id': projectId,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a model instance from an SQLite Map.
  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as int?,
      action: map['action'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Copies existing instance with modified fields.
  ActivityLogModel copyWith({
    int? id,
    int? projectId,
    String? entityType,
    int? entityId,
    String? action,
    String? description,
    DateTime? createdAt,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Human-friendly entity label in Indonesian.
  String get entityLabel {
    switch (entityType) {
      case 'project':
        return 'Proyek';
      case 'milestone':
        return 'Tahapan';
      case 'brainstorm':
        return 'Ide';
      case 'issue':
        return 'Kendala';
      case 'reference':
        return 'Referensi';
      default:
        return 'Aktivitas';
    }
  }

  /// Representative icon for this activity entry.
  IconData get icon {
    if (action == 'complete') return Icons.check_circle_outline;
    if (action == 'reorder') return Icons.reorder;
    if (action == 'delete') return Icons.delete_outline;
    if (action == 'update') return Icons.edit_outlined;

    switch (entityType) {
      case 'milestone':
        return Icons.flag_outlined;
      case 'brainstorm':
        return Icons.lightbulb_outline;
      case 'issue':
        return Icons.bug_report_outlined;
      case 'reference':
        return Icons.link;
      case 'project':
        return Icons.folder_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// Representative accent color for this activity entry.
  Color get color {
    if (action == 'complete') return AppColors.success;
    if (action == 'delete') return AppColors.error;
    if (entityType == 'issue') return AppColors.warning;
    return AppColors.primaryAccent;
  }

  /// Relative human-readable time format in Indonesian.
  String formatRelativeTime({DateTime? referenceNow}) {
    final now = referenceNow ?? DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24 && createdAt.day == now.day) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1 || (difference.inHours < 48 && createdAt.day == now.day - 1)) {
      final timeStr = DateFormat('HH:mm').format(createdAt);
      return 'Kemarin, $timeStr';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectId == other.projectId &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          action == other.action &&
          description == other.description &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      entityType.hashCode ^
      entityId.hashCode ^
      action.hashCode ^
      description.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'ActivityLogModel(id: $id, projectId: $projectId, entityType: $entityType, action: $action, description: $description)';
  }
}
