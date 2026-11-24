import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/screens/projects/project_list_screen.dart';

/// Root Application Widget configured with Material 3 Dark Mode.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const ProjectListScreen(),
    );
  }
}
