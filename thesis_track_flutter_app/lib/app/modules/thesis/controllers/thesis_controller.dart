import 'dart:developer';

import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/thesis_repository.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';

// mock data for other theses
final mockOtherTheses = [
  Thesis(
    id: '1',
    studentId: '1',
    supervisorId: '12',
    title: 'Performance Evaluation of Flutter Framework',
    abstract: 'Abstract 1',
    researchField: 'Research Field 1',
    status: ThesisStatus.inProgress,
    submissionDate: DateTime.now(),
    isProposalReady: false,
    isFinalExamReady: false,
    student: User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      role: UserRole.student,
      department: 'Department 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    mainSupervisor: User(
      id: '12',
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      role: UserRole.lecturer,
      department: 'Department 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    supervisors: [
      ThesisLecture(
        user: User(
          id: '12',
          name: 'John Doe',
          email: 'john.doe@example.com',
          role: UserRole.lecturer,
          department: 'Department 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        role: ThesisLectureRole.supervisor,
      ),
    ],
    examiners: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Thesis(
    id: '2',
    studentId: '2',
    supervisorId: '13',
    title: 'Network Security in IoT Devices',
    abstract: 'Abstract 2',
    researchField: 'Research Field 2',
    status: ThesisStatus.pending,
    submissionDate: DateTime.now(),
    isProposalReady: false,
    isFinalExamReady: false,
    student: User(
      id: '2',
      name: 'Alice Smith',
      email: 'alice.smith@example.com',
      role: UserRole.student,
      department: 'Department 2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    mainSupervisor: User(
      id: '13',
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      role: UserRole.lecturer,
      department: 'Department 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    supervisors: [],
    examiners: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

class ThesisController extends GetxController {
  static ThesisController get to => Get.find();

  late final ThesisRepository _thesisRepository;
  late final ProgressController _progressController;

  ThesisController({
    ProgressController? progressController,
    ThesisRepository? thesisRepository,
  }) {
    _progressController = progressController ?? Get.find();
    _thesisRepository = thesisRepository ?? ThesisRepository();
  }

  final _myTheses = Rx<List<Thesis>>([]);
  final _thesisProgress = Rxn<ThesisProgress>();
  final _isLoading = false.obs;
  final _error = Rxn<String>();
  final _otherTheses = <Thesis>[].obs;
  final _isCreating = false.obs;
  final _isApprovingForDefense = false.obs;

  List<Thesis> get myTheses => _myTheses.value;
  ThesisProgress? get thesisProgress => _thesisProgress.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  List<Thesis> get otherTheses => _otherTheses;
  bool get isCreating => _isCreating.value;
  bool get isApprovingForDefense => _isApprovingForDefense.value;

  @override
  void onInit() {
    super.onInit();
    getMyTheses();

    // mock data for other theses
    _otherTheses.value = mockOtherTheses;
  }

  Future<String?> getMyTheses() async {
    try {
      _isLoading.value = true;
      final result = await _thesisRepository.getMyTheses();
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (theses) async {
          _myTheses.value = theses;
          log('myTheses: ${_myTheses.value.length}');

          if (_myTheses.value.isNotEmpty) {
            for (var thesis in _myTheses.value) {
              getThesisProgress(thesis.id);
              _progressController.getProgressesByThesis(thesis);
            }
          }
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
          // Get progress for the thesis
          getThesisProgress(thesis.id);
          _progressController.getProgressesByThesis(thesis);

          // update the _myTheses list with the new thesis
          if (_myTheses.value.any((element) => element.id == thesis.id)) {
            _myTheses.value.removeWhere((element) => element.id == thesis.id);
            _myTheses.value.add(thesis);
          }

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
      _isCreating.value = true;
      final result = await _thesisRepository.createThesis(
        title: title,
        abstract: abstract,
        researchField: researchField,
        supervisorId: supervisorId,
      );
      return result.fold(
        (failure) {
          return failure.message;
        },
        (thesis) {
          _myTheses.value.add(thesis);
          return null;
        },
      );
    } finally {
      _isCreating.value = false;
    }
  }

  /// Accept Thesis Submission & Assign Supervisor By Admin
  Future<String?> acceptThesis(String thesisId, String lectureId) async {
    try {
      _isLoading.value = true;
      final result =
          await _thesisRepository.assignSupervisor(thesisId, lectureId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (_) async {
          await getThesisById(thesisId);
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

  Future<String?> approveThesisForDefense(String thesisId) async {
    try {
      _isApprovingForDefense.value = true;
      final result = await _thesisRepository.approveThesisForDefense(thesisId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (_) async {
          await getMyTheses(); // Refresh the list
          return null;
        },
      );
    } finally {
      _isApprovingForDefense.value = false;
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
          await getMyTheses(); // Refresh the list
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
        (progress) {
          _thesisProgress.value = progress;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
