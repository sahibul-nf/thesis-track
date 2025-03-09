import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentSection extends StatefulWidget {
  const DocumentSection({super.key, required this.thesis});
  final Thesis thesis;

  @override
  State<DocumentSection> createState() => _DocumentSectionState();
}

class _DocumentSectionState extends State<DocumentSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thesis = widget.thesis;

    if ((thesis.draftDocumentUrl?.isEmpty ?? true) &&
        (thesis.finalDocumentUrl?.isEmpty ?? true)) {
      return const EmptyStateWidget(
        icon: Iconsax.document_text,
        title: 'Documents Not Found',
        message: 'Start by uploading your thesis draft or final document',
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppTheme.spaceLG),
      child: ThesisCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spaceXS),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  ),
                  child: Icon(
                    Iconsax.document_upload,
                    size: 16,
                    color: theme.colorScheme.tertiary,
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
            SizedBox(height: AppTheme.spaceMD),

            // Document List
            if (thesis.draftDocumentUrl != null)
              _buildDocumentItem(
                icon: Iconsax.document_text,
                title: 'Draft Document',
                subtitle: 'Latest version of thesis draft',
                url: thesis.draftDocumentUrl,
                theme: theme,
                color: theme.colorScheme.primary,
              ),
            if (thesis.draftDocumentUrl != null)
              Divider(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            _buildDocumentItem(
              icon: Iconsax.document_favorite,
              title: 'Final Document',
              subtitle: 'Approved final version',
              url: thesis.finalDocumentUrl,
              theme: theme,
              color: AppTheme.successColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? url,
    required ThemeData theme,
    required Color color,
  }) {
    return InkWell(
      onTap: url != null ? () => _openDocument(url) : null,
      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceSM),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.chipRadius),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(width: AppTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (url != null)
              Icon(
                Iconsax.document_download,
                size: 20,
                color: theme.colorScheme.primary,
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Not Available',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDocument(String url) {
    launchUrl(Uri.parse(url));
  }

  void _previewDocument(String url) {
    // Implement document preview logic here
    // You can use a PDF viewer or webview depending on document type
    context.pushNamed('/document-preview', extra: {'url': url});
  }
}
