import 'package:sqflite/sqflite.dart';

/// Database schema definition and migration manager.
class DatabaseMigrations {
  DatabaseMigrations._();

  static const int currentVersion = 1;

  // Table Names
  static const String tableProjects = 'projects';
  static const String tableMilestones = 'milestones';
  static const String tableBrainstorms = 'brainstorms';
  static const String tableIssues = 'issues';
  static const String tableReferences = 'references';
  static const String tableActivityLogs = 'activity_logs';

  /// Initial schema creation (v1).
  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Projects Table
    batch.execute('''
      CREATE TABLE $tableProjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Milestones Table
    batch.execute('''
      CREATE TABLE $tableMilestones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        is_completed INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $tableProjects (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE INDEX idx_milestones_project_id ON $tableMilestones (project_id)
    ''');

    // 3. Brainstorms Table
    batch.execute('''
      CREATE TABLE $tableBrainstorms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        milestone_id INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $tableProjects (id) ON DELETE CASCADE,
        FOREIGN KEY (milestone_id) REFERENCES $tableMilestones (id) ON DELETE SET NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX idx_brainstorms_project_id ON $tableBrainstorms (project_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_brainstorms_milestone_id ON $tableBrainstorms (milestone_id)
    ''');

    // 4. Issues Table
    batch.execute('''
      CREATE TABLE $tableIssues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        milestone_id INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $tableProjects (id) ON DELETE CASCADE,
        FOREIGN KEY (milestone_id) REFERENCES $tableMilestones (id) ON DELETE SET NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX idx_issues_project_id ON $tableIssues (project_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_issues_milestone_id ON $tableIssues (milestone_id)
    ''');

    // 5. References Table (Quoted to avoid SQLite reserved keyword conflict)
    batch.execute('''
      CREATE TABLE "$tableReferences" (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        brainstorm_id INTEGER,
        issue_id INTEGER,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK ((brainstorm_id IS NULL) OR (issue_id IS NULL)),
        FOREIGN KEY (project_id) REFERENCES $tableProjects (id) ON DELETE CASCADE,
        FOREIGN KEY (brainstorm_id) REFERENCES $tableBrainstorms (id) ON DELETE SET NULL,
        FOREIGN KEY (issue_id) REFERENCES $tableIssues (id) ON DELETE SET NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX idx_references_project_id ON "$tableReferences" (project_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_references_brainstorm_id ON "$tableReferences" (brainstorm_id)
    ''');
    batch.execute('''
      CREATE INDEX idx_references_issue_id ON "$tableReferences" (issue_id)
    ''');

    // 6. Activity Logs Table
    batch.execute('''
      CREATE TABLE $tableActivityLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $tableProjects (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE INDEX idx_activity_logs_project_id ON $tableActivityLogs (project_id)
    ''');

    await batch.commit(noResult: true);
  }

  /// Incremental database migration handler for future versions.
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Incremental migrations can be added here:
    // if (oldVersion < 2) { ... }
  }
}
