import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/file/controllers/file_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentSection extends StatefulWidget {
  const DocumentSection({super.key, required this.thesis});
  final Thesis thesis;

  @override
  State<DocumentSection> createState() => _DocumentSectionState();
}

class _DocumentSectionState extends State<DocumentSection> {
  final fileController = Get.find<FileController>();

  bool get canUploadFinal {
    final user = AuthController.to.user;
    if (user == null) return false;

    // Hanya student yang bisa upload final
    if (user.role != UserRole.student) return false;

    // Harus status Under Review
    if (widget.thesis.status != ThesisStatus.underReview) return false;

    // Jika sudah ada final document, tidak bisa upload lagi
    if (widget.thesis.finalDocumentUrl != null &&
        widget.thesis.finalDocumentUrl!.isNotEmpty) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesis = widget.thesis;

    return Obx(() {
      return Padding(
      padding: EdgeInsets.all(AppTheme.spaceLG),
      child: ThesisCard(
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spaceXS),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.chipRadius),
                          ),
                          child: Icon(
                            Iconsax.document_favorite,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: AppTheme.spaceSM),
                        Text(
                          'Documents',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canUploadFinal)
                    Flexible(
                      child: FilledButton.icon(
                        onPressed: () => _showUploadDialog(context),
                        icon: const Icon(Iconsax.document_upload),
                        label: const Text('Upload Docs'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(100, 40),                          
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppTheme.spaceMD),
              if (widget.thesis.finalDocumentUrlRx.isEmpty) ...[
                Center(
                  child: (FileController.to.isLoading)
                      ? Container(
                          padding: EdgeInsets.all(AppTheme.spaceLG),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 45,
                                    height: 45,
                                    child: CircularProgressIndicator(
                                      value: FileController.to.isUploading
                                          ? FileController.to.uploadProgress /
                                              100
                                          : null,
                                      strokeWidth: 5,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  if (FileController.to.isUploading) ...[
                                    Column(
                                      children: [
                                        Text(
                                          "${FileController.to.uploadProgress.toStringAsFixed(1)}%",
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          "${FileController.to.formatBytes(FileController.to.bytesSent)}\n${FileController.to.formatBytes(FileController.to.totalBytes)}",
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: AppTheme.spaceMD),
                              Text(
                                FileController.to.isUploading
                                    ? 'Uploading your document...'
                                    : 'Processing your document...',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spaceSM),
                              Text(
                                FileController.to.isUploading
                                    ? 'Please wait while we upload your thesis document'
                                    : 'Almost done! We are processing your document',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : EmptyStateWidget(
                          icon: Iconsax.document_favorite,
                          title: 'No Final Document',
                          message: canUploadFinal
                              ? 'Upload your final thesis document. This should be the approved version after all revisions.'
                              : 'Final document has not been uploaded yet',
                        ),
                ),
              ] else
                Container(
                  padding: EdgeInsets.all(AppTheme.spaceMD),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppTheme.spaceSM),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.chipRadius),
                            ),
                            child: Icon(
                              Iconsax.document_favorite,
                              size: 24,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Final Thesis Document',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Created by ${thesis.student.name}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Iconsax.document_download,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => _openDocument(
                                    widget.thesis.finalDocumentUrlRx.value),
                                tooltip: 'Download',
                              ),
                              IconButton(
                                icon: Icon(
                                  Iconsax.eye,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => _previewDocument(
                                    widget.thesis.finalDocumentUrlRx.value),
                                tooltip: 'Preview',
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spaceMD),
                      Container(
                        padding: EdgeInsets.all(AppTheme.spaceSM),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.chipRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: AppTheme.spaceXS),
                            Expanded(
                              child: Text(
                                'Congratulations! This is the final, approved version of this thesis document. Ensure it is comprehensive and error-free.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ),
    );
    });
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    showDialog<File?>(
      context: context,
      builder: (context) => DocumentUploadDialog(
        title: 'Upload Final Document',
        message:
            'Upload your final thesis document. This should be the approved version after all revisions.',
        thesis: widget.thesis,
      ),
    );
  }

  void _openDocument(String url) {
    launchUrl(Uri.parse(url));
  }

  void _previewDocument(String url) {
    context.go(RouteLocation.toDocumentPreview(url));
  }
}

class DocumentUploadDialog extends StatefulWidget {
  final String title;
  final String message;
  final Thesis thesis;

  const DocumentUploadDialog({
    required this.title,
    required this.message,
    required this.thesis,
    super.key,
  });

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  final isDragging = false.obs;
  final selectedFile = Rx<XFile?>(null);
  final errorMessage = Rx<String?>(null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    widget.title,
                    style: theme.textTheme.titleMedium,
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMD,
                vertical: AppTheme.spaceMD,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Upload Area
                  Obx(
                    () => DropTarget(
                      onDragDone: (detail) {
                        handleFileDrop(detail);
                      },
                      onDragEntered: (detail) {
                        isDragging.value = true;
                      },
                      onDragExited: (detail) {
                        isDragging.value = false;
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(8),
                        padding: EdgeInsets.zero,
                        color: isDragging.value
                            ? Theme.of(context).colorScheme.primary
                            : errorMessage.value != null
                                ? Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(0.5)
                                : Theme.of(context).colorScheme.outlineVariant,
                        strokeWidth: 1,
                        dashPattern: const [6, 4],
                        child: Stack(
                          children: [
                            // Background container
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isDragging.value
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.1),
                              ),
                              child: InkWell(
                                onTap: onChooseFile,
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon and Text
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: selectedFile.value == null
                                              ? 48
                                              : 32),
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          // Jika dalam proses upload, tampilkan progress circle
                                          if (FileController.to.isLoading) ...[
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 45,
                                                  height: 45,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: FileController
                                                            .to.isUploading
                                                        ? FileController.to
                                                                .uploadProgress /
                                                            100
                                                        : null,
                                                    strokeWidth: 5,
                                                    strokeCap: StrokeCap.round,
                                                    backgroundColor: theme
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                                if (FileController
                                                    .to.isUploading)
                                                  Text(
                                                    "${FileController.to.uploadProgress.toStringAsFixed(1)}%",
                                                    style: theme
                                                        .textTheme.titleSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme
                                                          .colorScheme.primary
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Bytes sent
                                            Text(
                                              FileController.to.isUploading
                                                  ? "${FileController.to.formatBytes(FileController.to.bytesSent)} / ${FileController.to.formatBytes(FileController.to.totalBytes)}"
                                                  : "Your document is being processed...",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(),
                                            ),
                                          ] else ...[
                                            // Normal icon saat tidak upload
                                            Icon(
                                              selectedFile.value == null
                                                  ? isDragging.value
                                                      ? Iconsax.document_upload
                                                      : Iconsax.document_1
                                                  : Iconsax.document_text,
                                              size: 32,
                                              color: isDragging.value
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              selectedFile.value == null
                                                  ? 'Click to choose PDF file'
                                                  : selectedFile.value!.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: isDragging.value
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : null,
                                              ),
                                            ),
                                            if (selectedFile.value == null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'or drag and drop here',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                    // File Info
                                    if (selectedFile.value != null &&
                                        !FileController.to.isLoading) ...[
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          // Delete
                                          TextButton.icon(
                                            onPressed: () {
                                              selectedFile.value = null;
                                              errorMessage.value = null;
                                            },
                                            icon: const Icon(
                                              Iconsax.trash,
                                              size: 16,
                                            ),
                                            label: const Text('Delete'),
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              textStyle:
                                                  theme.textTheme.bodySmall,
                                              iconColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                          // Change
                                          TextButton.icon(
                                            onPressed: onChooseFile,
                                            icon: const Icon(
                                              Iconsax.refresh,
                                              size: 16,
                                            ),
                                            label: const Text('Change'),
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              textStyle:
                                                  theme.textTheme.bodySmall,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppTheme.spaceSM)
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Error Message
                  Obx(
                    () => errorMessage.value != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.danger,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage.value!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: AppTheme.spaceLG),
                  // Upload button
                  Obx(() {
                    bool isLoading = FileController.to.isLoading;
                    bool isUploading = FileController.to.isUploading;
                    bool isDisabled = selectedFile.value == null || isLoading;
                    return FilledButton(
                      onPressed: isDisabled ? null : onUpload,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: isLoading
                          ? isUploading
                              ? const Text('Uploading...')
                              : const Text('Processing...')
                          : const Text('Upload'),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onUpload() async {
    final file = selectedFile.value;
    if (file == null) return;

    try {
      dynamic fileToUpload;
      if (kIsWeb) {
        // For web platform, send bytes
        final bytes = await file.readAsBytes();
        fileToUpload = bytes;
      } else {
        // For mobile platform, send File
        fileToUpload = File(file.path);
      }

      final err = await FileController.to.uploadThesisFinal(
        widget.thesis,
        fileToUpload,
      );

      if (err != null) {
        errorMessage.value = err;
        return;
      }

      MyToast.showShadcnUIToast(
        context,
        'Document uploaded successfully',
        'Your thesis document has been uploaded.',
      );

      context.pop();
    } catch (e) {
      errorMessage.value = 'Error uploading file: ${e.toString()}';
    }
  }

  void handleFileDrop(DropDoneDetails details) async {
    if (details.files.isEmpty) {
      errorMessage.value = 'No file selected';
      return;
    }

    final file = details.files.single;
    final err = await validatePDFile(file);
    if (err != null) {
      errorMessage.value = err;
      return;
    }

    selectedFile.value = XFile(file.path);
    errorMessage.value = null;
  }

  void onChooseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = kIsWeb
        ? XFile.fromData(
            result.files.first.bytes!,
            name: result.files.first.name,
            mimeType: 'application/pdf',
          )
        : XFile(result.files.single.path!);
    final err = await validatePDFile(file);
    if (err != null) {
      errorMessage.value = err;
      return;
    }

    if (!context.mounted) return;

    selectedFile.value = file;
    errorMessage.value = null;
  }

  Future<String?> validatePDFile(XFile file) async {
    // Basic validations only
    try {
      // 1. Check file extension
      if (!file.name.toLowerCase().endsWith('.pdf')) {
        return 'Oops! Only PDF file are accepted';
      }

      // 2. Check if file is not empty
      final fileSize = await file.length();
      if (fileSize == 0) {
        return 'File is empty';
      }

      // 3. Check file size
      if (fileSize > 10 * 1024 * 1024) {
        return 'File size exceeds the maximum limit of 10MB';
      }

      // 4. Quick peek at content (just first few bytes)
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return 'Unable to read file';
      }

      return null; // Validation passed
    } catch (e) {
      return 'Error reading file';
    }
  }
}
