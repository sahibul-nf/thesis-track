import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/thesis_repository.dart';

class ThesisController extends GetxController {
  final ThesisRepository _thesisRepository = ThesisRepository();
  final _theses = <Thesis>[].obs;
  final _selectedThesis = Rxn<Thesis>();
  final _lecturers = <User>[].obs;
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  List<Thesis> get theses => _theses;
  Thesis? get selectedThesis => _selectedThesis.value;
  List<User> get lecturers => _lecturers;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<String?> getAllTheses() async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.getAllTheses();
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (theses) {
          _theses.value = theses;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> getThesisById(String id) async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.getThesisById(id);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (thesis) {
          _selectedThesis.value = thesis;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> getLecturers() async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.getLecturers();
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (lecturers) {
          _lecturers.value = lecturers;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> createThesis({
    required String title,
    required String abstract,
    required String researchField,
    required String supervisorId,
  }) async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.createThesis(
        title: title,
        abstract: abstract,
        researchField: researchField,
        supervisorId: supervisorId,
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (thesis) {
          _theses.add(thesis);
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> assignSupervisor(String thesisId, String lectureId) async {
    try {
      _isLoading.value = true;
      final result =
          await _thesisRepository.assignSupervisor(thesisId, lectureId);
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

  Future<String?> assignExaminer(String thesisId, String lectureId) async {
    try {
      _isLoading.value = true;
      final result =
          await _thesisRepository.assignExaminer(thesisId, lectureId);
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

  Future<String?> approveThesis(String thesisId) async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.approveThesis(thesisId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (_) async {
          await getAllTheses(); // Refresh the list
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> markAsCompleted(String thesisId) async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.markAsCompleted(thesisId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (_) async {
          await getAllTheses(); // Refresh the list
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> getThesisProgress(String thesisId) async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.getThesisProgress(thesisId);
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
