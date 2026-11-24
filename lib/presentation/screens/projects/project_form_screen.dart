import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/project_repository.dart';

/// Form screen for creating or editing a Project.
class ProjectFormScreen extends StatefulWidget {
  final ProjectModel? project;
  final ProjectRepository? repository;

  const ProjectFormScreen({
    super.key,
    this.project,
    this.repository,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late ProjectStatus _selectedStatus;
  late final ProjectRepository _repository;
  bool _isLoading = false;

  bool get isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProjectRepository();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController =
        TextEditingController(text: widget.project?.description ?? '');
    _selectedStatus = widget.project?.status ?? ProjectStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      if (isEdit) {
        final updatedProject = widget.project!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _selectedStatus,
          updatedAt: now,
        );
        await _repository.updateProject(updatedProject);
      } else {
        final newProject = ProjectModel(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _selectedStatus,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insertProject(newProject);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Proyek berhasil diperbarui' : 'Proyek berhasil dibuat',
            style: const TextStyle(color: AppColors.primaryText),
          ),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Proyek' : 'Tambah Proyek'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProject,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: AppColors.primaryAccent),
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Nama Proyek *',
                  hintText: 'Contoh: E-Commerce Mobile App',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama proyek tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Proyek',
                  hintText: 'Tujuan, ruang lingkup, atau catatan proyek',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<ProjectStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Proyek',
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.label,
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryText),
                    ),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    setState(() => _selectedStatus = newStatus);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProject,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'Perbarui Proyek' : 'Simpan Proyek',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
