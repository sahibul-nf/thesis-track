import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
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
        child: ListView(
          shrinkWrap: true,
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
                    'New Thesis',
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
            Container(
              padding: EdgeInsets.all(AppTheme.spaceLG),
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
            Container(
              padding: EdgeInsets.all(AppTheme.spaceLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final isLoading = _thesisController.isCreating;
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
