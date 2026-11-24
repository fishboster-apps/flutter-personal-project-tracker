import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Initial placeholder HomeScreen demonstrating dark theme and app branding.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Project Tracker'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_special_outlined,
                size: 64,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Personal Project Tracker',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pelacak progres proyek coding offline-first.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
