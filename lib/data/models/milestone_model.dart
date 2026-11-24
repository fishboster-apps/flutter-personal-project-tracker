/// Domain/Data model representing a Milestone (Tahapan).
class MilestoneModel {
  final int? id;
  final int projectId;
  final String name;
  final String description;
  final bool isCompleted;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilestoneModel({
    this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    this.isCompleted = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Converts model instance to a Map for SQLite insertion/updating.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'project_id': projectId,
      'name': name,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a model instance from an SQLite Map.
  factory MilestoneModel.fromMap(Map<String, dynamic> map) {
    return MilestoneModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      sortOrder: (map['sort_order'] as int? ?? 0),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Copies existing instance with modified fields.
  MilestoneModel copyWith({
    int? id,
    int? projectId,
    String? name,
    String? description,
    bool? isCompleted,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
