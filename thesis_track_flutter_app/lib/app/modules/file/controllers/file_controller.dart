import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/file_repository.dart';

class FileController extends GetxController {
  static FileController get to => Get.find();
  
  final FileRepository _fileRepository = FileRepository();
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

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
      final result = await _fileRepository.uploadThesisDraft(thesisId, file);
      return result.fold(
        (failure) {
          return failure.message;
        },
        (url) => url,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> uploadThesisFinal(Thesis thesis, dynamic file) async {
    try {
      _isLoading.value = true;
      final result = await _fileRepository.uploadThesisFinal(thesis.id, file);
      return result.fold(
        (failure) {
          return failure.message;
        },
        (url) {
          thesis.finalDocumentUrl!.value = url;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> deleteDocument(String url) async {
    try {
      _isLoading.value = true;
      final result = await _fileRepository.deleteDocument(url);
      return result.fold(
        (failure) {
          return failure.message;
        },
        (_) => null,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
