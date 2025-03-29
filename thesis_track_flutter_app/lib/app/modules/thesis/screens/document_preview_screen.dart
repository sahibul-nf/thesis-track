import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String url;

  const DocumentPreviewScreen({
    super.key,
    required this.url,
  });

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        constraints: const BoxConstraints(maxWidth: 1024, maxHeight: 900),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                    'Document Preview',
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: SfPdfViewer.network(
                  widget.url,
                  key: _pdfViewerKey,
                  onDocumentLoadFailed: (details) {
                    MyToast.showShadcnUIToast(
                      context,
                      'Error',
                      details.description,
                      isError: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
