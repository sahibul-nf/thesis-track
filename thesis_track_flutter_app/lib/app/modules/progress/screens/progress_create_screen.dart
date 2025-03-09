import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/text_field.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

class ProgressCreateScreen extends StatefulWidget {
  const ProgressCreateScreen({
    super.key,
    required this.thesis,
  });

  final Thesis thesis;

  @override
  State<ProgressCreateScreen> createState() => _ProgressCreateScreenState();
}

class _ProgressCreateScreenState extends State<ProgressCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _progressDescriptionController = TextEditingController();
  final _documentUrlController = TextEditingController();
  final _progressController = Get.find<ProgressController>();
  User? _selectedReviewer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _progressDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final err = await _progressController.addProgress(
      thesis: widget.thesis,
      reviewerId: _selectedReviewer!.id,
      documentUrl: _documentUrlController.text,
      progressDescription: _progressDescriptionController.text,
    );

    if (err != null) {
      return MyToast.showShadcnUIToast(
        context,
        'Error',
        err,
        isError: true,
      );
    }

    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1024, maxHeight: 800),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppBar(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0.0,
              centerTitle: false,
              forceMaterialTransparency: true,
              toolbarHeight: 60,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppTheme.spaceLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppTheme.spaceMD,
                  children: [
                    ThesisTextField(
                      controller: _progressDescriptionController,
                      maxLines: 5,
                      label: 'What progress have you made?',
                      hint:
                          'Describe your recent thesis progress and achievements...',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your progress description';
                        }

                        if (value.length < 10) {
                          return 'Please provide at least 10 characters to better describe your progress';
                        }

                        return null;
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who should review this progress?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        DropdownButtonFormField<User>(
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          value: _selectedReviewer,
                          decoration: const InputDecoration(
                            hintText: 'Choose a reviewer',
                          ),
                          items: widget.thesis.lecturers
                              .map(
                                (lecturer) => DropdownMenuItem(
                                  value: lecturer,
                                  child: Text(lecturer.name),
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
                              return 'Please select a reviewer for your progress';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThesisTextField(
                          controller: _documentUrlController,
                          label: 'Document Link',
                          hint:
                              'Share your document link (Google Drive, OneDrive, etc.)',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your document link';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.spaceSM),
                        // Info card
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceMD,
                            vertical: AppTheme.spaceMD,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.cardRadius),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: AppTheme.spaceMD),
                              Expanded(
                                child: Text(
                                  'Please ensure you have configured proper access permissions for your document. The reviewer should have edit/comment access to review your work effectively.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(AppTheme.spaceLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final isLoading = _progressController.isLoading;
                    return FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(170, 48),
                      ),
                      icon: isLoading ? null : const Icon(Iconsax.send_2),
                      label: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                strokeCap: StrokeCap.round,
                              ),
                            )
                          : const Text('Submit'),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
