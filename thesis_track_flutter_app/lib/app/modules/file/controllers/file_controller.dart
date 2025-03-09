import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/file_repository.dart';

class FileController extends GetxController {
  final FileRepository _fileRepository = FileRepository();
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<FilePickerResult?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }

  Future<String?> uploadThesisDraft(String thesisId, File file) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      final result = await _fileRepository.uploadThesisDraft(thesisId, file);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (url) => url,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> uploadThesisFinal(String thesisId, File file) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      final result = await _fileRepository.uploadThesisFinal(thesisId, file);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (url) => url,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> uploadProgressDocument(String progressId, File file) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      final result =
          await _fileRepository.uploadProgressDocument(progressId, file);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (url) => url,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> deleteDocument(String url) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      final result = await _fileRepository.deleteDocument(url);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (_) => null,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
