/// Domain/Data model representing a Reference link or document.
class ReferenceModel {
  final int? id;
  final int projectId;
  final int? brainstormId;
  final int? issueId;
  final String title;
  final String url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferenceModel({
    this.id,
    required this.projectId,
    this.brainstormId,
    this.issueId,
    required this.title,
    required this.url,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : assert(
          brainstormId == null || issueId == null,
          'A reference cannot be linked to both a brainstorm idea and an issue simultaneously.',
        ),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Whether this reference is a project-level standalone reference.
  bool get isStandalone => brainstormId == null && issueId == null;

  /// Whether this reference is connected to a brainstorm idea.
  bool get isBrainstormRelated => brainstormId != null;

  /// Whether this reference is connected to an issue / technical bug.
  bool get isIssueRelated => issueId != null;

  /// Converts model instance to a Map for SQLite insertion/updating.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'project_id': projectId,
      'brainstorm_id': brainstormId,
      'issue_id': issueId,
      'title': title,
      'url': url,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Creates a model instance from an SQLite Map.
  factory ReferenceModel.fromMap(Map<String, dynamic> map) {
    return ReferenceModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      brainstormId: map['brainstorm_id'] as int?,
      issueId: map['issue_id'] as int?,
      title: map['title'] as String,
      url: map['url'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Copies existing instance with modified fields.
  ReferenceModel copyWith({
    int? id,
    int? projectId,
    int? brainstormId,
    bool clearBrainstormId = false,
    int? issueId,
    bool clearIssueId = false,
    String? title,
    String? url,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final effectiveBrainstormId =
        clearBrainstormId ? null : (brainstormId ?? this.brainstormId);
    final effectiveIssueId =
        clearIssueId ? null : (issueId ?? this.issueId);

    return ReferenceModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      brainstormId: effectiveBrainstormId,
      issueId: effectiveIssueId,
      title: title ?? this.title,
      url: url ?? this.url,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectId == other.projectId &&
          brainstormId == other.brainstormId &&
          issueId == other.issueId &&
          title == other.title &&
          url == other.url &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      projectId.hashCode ^
      brainstormId.hashCode ^
      issueId.hashCode ^
      title.hashCode ^
      url.hashCode ^
      notes.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'ReferenceModel(id: $id, projectId: $projectId, brainstormId: $brainstormId, issueId: $issueId, title: $title, url: $url)';
  }
}
