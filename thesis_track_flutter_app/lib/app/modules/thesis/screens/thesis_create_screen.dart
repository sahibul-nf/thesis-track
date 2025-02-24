import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/button.dart';
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
  User? _selectedSupervisor;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  Future<void> _loadSupervisors() async {
    await _authController.getSupervisors();
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
        supervisorId: _selectedSupervisor!.id,
      );

      if (context.mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Submit Thesis',
      ),
      body: PageLayout(
        compactLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        mediumLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
        expandedLayout: SinglePaneLayout(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
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
                  final supervisors = _authController.supervisors;

                  return DropdownButtonFormField<User>(
                    value: _selectedSupervisor,
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
                      setState(() {
                        _selectedSupervisor = value;
                      });
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
            return ThesisButton(
              text: 'Submit',
              onPressed: _submit,
              isLoading: _thesisController.isLoading,
            );
          }),
        ],
      ),
    );
  }
}
