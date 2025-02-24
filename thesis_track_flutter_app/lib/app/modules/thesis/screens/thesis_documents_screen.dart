import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/file/controllers/file_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/widgets/app_bar.dart';
import 'package:thesis_track_flutter_app/app/widgets/button.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class ThesisDocumentsScreen extends StatefulWidget {
  const ThesisDocumentsScreen({
    super.key,
    required this.thesisId,
  });

  final String thesisId;

  @override
  State<ThesisDocumentsScreen> createState() => _ThesisDocumentsScreenState();
}

class _ThesisDocumentsScreenState extends State<ThesisDocumentsScreen> {
  final _thesisController = Get.find<ThesisController>();
  final _fileController = Get.find<FileController>();
  final _authController = Get.find<AuthController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThesis();
  }

  Future<void> _loadThesis() async {
    await _thesisController.getThesisById(widget.thesisId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThesisAppBar(
        title: 'Thesis Documents',
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Obx(() {
          if (_thesisController.isLoading) {
            return const LoadingWidget();
          }

          final thesis = _thesisController.selectedThesis;
          if (thesis == null) {
            return const EmptyStateWidget(
              message: 'Thesis not found',
              icon: Icons.school_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (RoleGuard.canUploadDocuments() &&
                  thesis.status != 'completed') ...[
                ThesisCard(
                  title: 'Upload Document',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select the type of document you want to upload:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ThesisButton(
                              text: 'Upload Draft',
                              onPressed: () => _uploadDocument(isDraft: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ThesisButton(
                              text: 'Upload Final',
                              onPressed: thesis.status == 'approved'
                                  ? () => _uploadDocument(isDraft: false)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (thesis.status != 'approved')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Final document can only be uploaded after thesis is approved',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (thesis.draftDocumentUrl != null)
                _buildDocumentCard(
                  title: 'Draft Document',
                  url: thesis.draftDocumentUrl!,
                  canDelete: RoleGuard.canUploadDocuments() &&
                      thesis.status != 'completed',
                ),
              if (thesis.finalDocumentUrl != null) ...[
                if (thesis.draftDocumentUrl != null) const SizedBox(height: 16),
                _buildDocumentCard(
                  title: 'Final Document',
                  url: thesis.finalDocumentUrl!,
                  canDelete: RoleGuard.canUploadDocuments() &&
                      thesis.status != 'completed',
                ),
              ],
              if (thesis.draftDocumentUrl == null &&
                  thesis.finalDocumentUrl == null)
                const EmptyStateWidget(
                  message: 'No documents uploaded yet',
                  icon: Icons.description_outlined,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String url,
    bool canDelete = false,
  }) {
    final fileName = url.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    return ThesisCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                fileExtension == 'PDF'
                    ? Icons.picture_as_pdf
                    : Icons.description_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ThesisButton(
                  text: 'Download',
                  onPressed: () => _downloadDocument(url),
                  icon: Icons.download_outlined,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: ThesisButton(
                    text: 'Delete',
                    onPressed: () => _deleteDocument(url),
                    icon: Icons.delete_outline,
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument({required bool isDraft}) async {
    final result = await _fileController.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name.toLowerCase();

    // Validate file type
    if (!fileName.endsWith('.pdf')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Only PDF files are allowed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Check file size (max 10MB)
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File size must be less than 10MB'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      String? errorMessage;
      if (isDraft) {
        errorMessage = await _fileController.uploadThesisDraft(
          widget.thesisId,
          file,
        );
      } else {
        // Show confirmation dialog for final document
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Final Document'),
            content: const Text(
              'Are you sure you want to upload the final document? This will replace the existing final document if one exists.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Upload'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        errorMessage = await _fileController.uploadThesisFinal(
          widget.thesisId,
          file,
        );
      }

      if (errorMessage != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        await _loadThesis(); // Refresh thesis data
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft
                  ? 'Draft document uploaded successfully'
                  : 'Final document uploaded successfully',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDocument(String url) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final errorMessage = await _fileController.deleteDocument(url);
      if (errorMessage != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        await _loadThesis(); // Refresh thesis data
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document deleted successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open document'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
