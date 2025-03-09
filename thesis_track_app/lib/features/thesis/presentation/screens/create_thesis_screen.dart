import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thesis_track_app/features/thesis/presentation/controllers/thesis_controller.dart';

class CreateThesisScreen extends GetView<ThesisController> {
  const CreateThesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final abstractController = TextEditingController();
    final researchFieldController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Thesis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: abstractController,
                decoration: const InputDecoration(
                  labelText: 'Abstract',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an abstract';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: researchFieldController,
                decoration: const InputDecoration(
                  labelText: 'Research Field',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a research field';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              controller.createThesis({
                                'title': titleController.text,
                                'abstract': abstractController.text,
                                'research_field': researchFieldController.text,
                              });
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}