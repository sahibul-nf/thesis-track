import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:thesis_track_app/features/document/data/repository/document_repository_impl.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String thesisId;
  final bool isFinal;

  const DocumentUploadScreen({
    Key? key,
    required this.thesisId,
    this.isFinal = false,
  }) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _errorMessage;
  final _repository = DocumentRepositoryImpl();

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 10 * 1024 * 1024) { // 10MB
          setState(() {
            _errorMessage = 'File size exceeds 10MB limit';
            _selectedFile = null;
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final url = widget.isFinal
          ? await _repository.uploadFinalDocument(widget.thesisId, _selectedFile!)
          : await _repository.uploadDraftDocument(widget.thesisId, _selectedFile!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document uploaded successfully')),
      );

      Navigator.pop(context, url);
    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFinal ? 'Upload Final Document' : 'Upload Draft Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Select PDF File'),
            ),
            if (_selectedFile != null) ...[  
              const SizedBox(height: 16),
              Text(
                'Selected file: ${_selectedFile!.path.split('/').last}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (_errorMessage != null) ...[  
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedFile == null || _isUploading ? null : _uploadDocument,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}