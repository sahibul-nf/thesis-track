import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/text_field.dart';

class ThesisCreateScreen extends StatefulWidget {
  const ThesisCreateScreen({super.key});

  @override
  State<ThesisCreateScreen> createState() => _ThesisCreateScreenState();
}

class _ThesisCreateScreenState extends State<ThesisCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _abstractController = TextEditingController();
  final _researchFieldController = TextEditingController();
  final _thesisController = Get.find<ThesisController>();
  final _authController = Get.find<AuthController>();
  final Rx<User?> _selectedSupervisor = Rx<User?>(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _abstractController.dispose();
    _researchFieldController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await _thesisController.createThesis(
        title: _titleController.text,
        abstract: _abstractController.text,
        researchField: _researchFieldController.text,
        supervisorId: _selectedSupervisor.value?.id ?? '',
      );

      if (context.mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          ThesisCard(
            title: 'Thesis Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThesisTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter thesis title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter thesis title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ThesisTextField(
                  controller: _abstractController,
                  label: 'Abstract',
                  hint: 'Enter thesis abstract',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter thesis abstract';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ThesisTextField(
                  controller: _researchFieldController,
                  label: 'Research Field',
                  hint: 'Enter research field',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter research field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Supervisor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final supervisors = AdminController.to.lecturers;

                  return DropdownButtonFormField<User?>(
                    value: _selectedSupervisor.value,
                    decoration: const InputDecoration(
                      hintText: 'Select supervisor',
                      border: OutlineInputBorder(),
                    ),
                    items: supervisors
                        .map(
                          (supervisor) => DropdownMenuItem(
                            value: supervisor,
                            child: Text(supervisor.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      _selectedSupervisor.value = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select supervisor';
                      }
                      return null;
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isCreating = _thesisController.isCreating;
            return FilledButton(
              onPressed: isCreating ? null : _submit,
              child: isCreating
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit'),
            );
          }),
        ],
      ),
    );
  }
}
