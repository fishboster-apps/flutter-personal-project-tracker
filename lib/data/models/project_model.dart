/// Enum representing lifecycle status of a project.
enum ProjectStatus {
  active('active', 'Aktif'),
  onHold('on_hold', 'Tertunda'),
  completed('completed', 'Selesai'),
  archived('archived', 'Diarsipkan');

  final String value;
  final String label;

  const ProjectStatus(this.value, this.label);

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProjectStatus.active,
    );
  }
}

/// Domain/Data model representing a Project.
class ProjectModel {
  final int? id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    this.id,
    required this.name,
    this.description = '',
    this.status = ProjectStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Converts model instance to a Map for SQLite insertion/updating.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a model instance from SQLite Map.
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      status: ProjectStatus.fromString((map['status'] as String?) ?? 'active'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Copies existing instance with modified fields.
  ProjectModel copyWith({
    int? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
