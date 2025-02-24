import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/button.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/text_field.dart';

class ProgressCreateScreen extends StatefulWidget {
  const ProgressCreateScreen({
    super.key,
    required this.thesisId,
  });

  final String thesisId;

  @override
  State<ProgressCreateScreen> createState() => _ProgressCreateScreenState();
}

class _ProgressCreateScreenState extends State<ProgressCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _progressDescriptionController = TextEditingController();
  final _progressController = Get.find<ProgressController>();
  final _authController = Get.find<AuthController>();
  User? _selectedReviewer;

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
    _progressDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await _progressController.addProgress(
        thesisId: widget.thesisId,
        reviewerId: _selectedReviewer!.id,
        progressDescription: _progressDescriptionController.text,
      );

      if (context.mounted) {
        context.go('/thesis/${widget.thesisId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Add Progress',
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
            title: 'Progress Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThesisTextField(
                  controller: _progressDescriptionController,
                  label: 'Progress Description',
                  hint: 'Enter progress description',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter progress description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Reviewer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final supervisors = _authController.supervisors;

                  return DropdownButtonFormField<User>(
                    value: _selectedReviewer,
                    decoration: const InputDecoration(
                      hintText: 'Select reviewer',
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
                        _selectedReviewer = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select reviewer';
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
              isLoading: _progressController.isLoading,
            );
          }),
        ],
      ),
    );
  }
}
