import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/file_repository.dart';

class FileController extends GetxController {
  static FileController get to => Get.find();
  
  final FileRepository _fileRepository = FileRepository();
  final _isLoading = false.obs;
  final _uploadProgress = 0.0.obs; // Progress upload dari 0.0 sampai 100.0
  final _bytesSent = 0.obs; // Tambahkan ini
  final _totalBytes = 0.obs; // Tambahkan ini
  final _isUploading = false.obs; // Tambahkan state baru untuk tracking upload
  final _isProcessing =
      false.obs; // Tambahkan state baru untuk tracking proses server

  bool get isLoading => _isLoading.value;
  double get uploadProgress => _uploadProgress.value;
  int get bytesSent => _bytesSent.value; // Getter untuk bytes terkirim
  int get totalBytes => _totalBytes.value; // Getter untuk total bytes
  bool get isUploading => _isUploading.value;
  bool get isProcessing => _isProcessing.value;

  // Untuk memperbarui progress
  void updateProgress(int sent, int total) {
    _bytesSent.value = sent;
    _totalBytes.value = total;
    if (total > 0) {
      _uploadProgress.value = (sent / total) * 100;
    }
  }

  // Reset progress saat selesai
  void resetProgress() {
    _uploadProgress.value = 0.0;
    _bytesSent.value = 0;
    _totalBytes.value = 0;
  }

  Future<FilePickerResult?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }

  Future<String?> uploadThesisFinal(Thesis thesis, dynamic file) async {
    try {
      _isLoading.value = true;
      _isUploading.value = true;
      resetProgress();

      final result = await _fileRepository.uploadThesisFinal(
        thesis.id,
        file,
        onProgress: (sent, total) {
          if (total != 0) {
            final progress = (sent / total) * 100;
            updateProgress(sent, total);
            if (progress >= 100) {
              _isUploading.value = false;
              _isProcessing.value = true; // Mulai proses server
            }
          }
        },
      );
      
      return result.fold(
        (failure) {
          return failure.message;
        },
        (url) {
          thesis.setFinalDocumentUrlRx(url);
          return null;
        },
      );
    } finally {
      _isUploading.value = false;
      _isProcessing.value = false;
      _isLoading.value = false;
      resetProgress();
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

  String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
