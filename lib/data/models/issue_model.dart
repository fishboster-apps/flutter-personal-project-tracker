/// Domain/Data model representing an Issue or Problem item.
class IssueModel {
  final int? id;
  final int projectId;
  final int? milestoneId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  IssueModel({
    this.id,
    required this.projectId,
    this.milestoneId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Converts model instance to a Map for SQLite insertion/updating.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'project_id': projectId,
      'milestone_id': milestoneId,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a model instance from an SQLite Map.
  factory IssueModel.fromMap(Map<String, dynamic> map) {
    return IssueModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      milestoneId: map['milestone_id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Copies existing instance with modified fields.
  IssueModel copyWith({
    int? id,
    int? projectId,
    int? milestoneId,
    bool clearMilestoneId = false,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IssueModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      milestoneId: clearMilestoneId ? null : (milestoneId ?? this.milestoneId),
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
