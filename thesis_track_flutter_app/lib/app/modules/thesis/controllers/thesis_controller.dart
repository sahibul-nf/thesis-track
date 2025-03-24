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
    examiners: RxList<ThesisLecture>([]),
    thesisProgress: ThesisProgress(
      totalProgress: 20,
      details: ProgressDetails(
        initialPhase: 10,
        proposalPhase: 10,
        researchPhase: 10,
        finalPhase: 10,
      ),
    ),
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
    examiners: RxList<ThesisLecture>([]),
    thesisProgress: ThesisProgress(
      totalProgress: 70,
      details: ProgressDetails(
        initialPhase: 20,
        proposalPhase: 20,
        researchPhase: 20,
        finalPhase: 20,
      ),
    ),
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

  final _allTheses = Rx<List<Thesis>>([]);
  final _myTheses = Rx<List<Thesis>>([]);
  final _isLoadingMyThesis = false.obs;
  final _isLoadingAllTheses = false.obs;
  final _error = Rxn<String>();
  final _otherTheses = <Thesis>[].obs;
  final _isCreating = false.obs;
  final _isApprovingForDefense = false.obs;
  final _isAssigningExaminer = false.obs;
  final _topProgressTheses = <Thesis>[].obs;
  final _selectedYear = ''.obs;
  final _searchQuery = ''.obs;

  List<Thesis> get allTheses => _allTheses.value;
  List<Thesis> get myTheses => _myTheses.value;
  bool get isLoadingMyThesis => _isLoadingMyThesis.value;
  bool get isLoadingAllTheses => _isLoadingAllTheses.value;
  String? get error => _error.value;
  List<Thesis> get otherTheses => _otherTheses;
  bool get isCreating => _isCreating.value;
  bool get isApprovingForDefense => _isApprovingForDefense.value;
  bool get isAssigningExaminer => _isAssigningExaminer.value;
  String get selectedYear => _selectedYear.value;
  List<Thesis> get topProgressTheses => _topProgressTheses;
  int get topProgressThesesCount => _topProgressTheses.length;
  int get myTopProgressPosition => _topProgressTheses.indexWhere(
        (thesis) => thesis.id == _myTheses.value.first.id,
      );
  String get searchQuery => _searchQuery.value;

  List<Thesis> get filteredTheses {
    if (_searchQuery.value.isEmpty) return _allTheses.value;

    return _allTheses.value.where((thesis) {
      return thesis.title
          .toLowerCase()
          .contains(_searchQuery.value.toLowerCase());
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getMyTheses();
    getAllTheses();
  }

  Future<void> onRefresh() async {
    await getMyTheses();
    getAllTheses();
  }

  Future<void> getAllTheses() async {
    try {
      _isLoadingAllTheses.value = true;
      final result = await _thesisRepository.getAllTheses();
      result.fold(
        (failure) => _allTheses.value = [],
        (theses) {
          _allTheses.value = theses;
          getTopProgressTheses();
          for (var thesis in theses) {
            _progressController.getProgressesByThesis(thesis);
          }
        },
      );
    } finally {
      _isLoadingAllTheses.value = false;
    }
  }

  Future<String?> getMyTheses() async {
    try {
      _isLoadingMyThesis.value = true;
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
              _progressController.getProgressesByThesis(thesis);
            }
          }
          return null;
        },
      );
    } finally {
      _isLoadingMyThesis.value = false;
    }
  }

  Future<String?> getThesisById(String id) async {
    try {
      _isLoadingMyThesis.value = true;
      final result = await _thesisRepository.getThesisById(id);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (thesis) {
          // Get progress for the thesis
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
      _isLoadingMyThesis.value = false;
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
      _isLoadingMyThesis.value = true;
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
      _isLoadingMyThesis.value = false;
    }
  }

  Future<String?> assignSupervisor(String thesisId, String lectureId) async {
    try {
      _isLoadingMyThesis.value = true;
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
      _isLoadingMyThesis.value = false;
    }
  }

  Future<String?> assignExaminer(
    Thesis thesis,
    ThesisLecture thesisLecture,
  ) async {
    try {
      _isAssigningExaminer.value = true;
      final result = await _thesisRepository.assignExaminer(
        thesis.id,
        thesisLecture.user.id,
      );
      return result.fold(
        (failure) {
          return failure.message;
        },
        (_) async {
          // add the thesis lecture to the thesis
          thesis.examiners.add(thesisLecture);
          return null;
        },
      );
    } finally {
      _isAssigningExaminer.value = false;
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
      _isLoadingMyThesis.value = true;
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
      _isLoadingMyThesis.value = false;
    }
  }

  // Get unique years from theses
  List<String?> get availableYears {
    final years =
        allTheses.map((thesis) => thesis.student.year).toSet().toList();
    years.sort((a, b) => b!.compareTo(a!));
    return years;
  }

  // Get top progress theses filtered by year
  Future<void> getTopProgressTheses([String? year]) async {
    if (year != null) _selectedYear.value = year;

    // Get date 6 months ago
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

    // Filter theses from last 6 months
    var filteredTheses = allTheses.where((thesis) {
      // Check if thesis is active in last 6 months
      final isActive = thesis.updatedAt.isAfter(sixMonthsAgo);

      // Apply year filter if selected
      final matchesYear =
          selectedYear.isEmpty || thesis.student.year == selectedYear;

      return isActive && matchesYear;
    }).toList();

    // Sort by progress percentage
    filteredTheses.sort((a, b) {
      final aProgress = a.thesisProgress?.totalProgress ?? 0;
      final bProgress = b.thesisProgress?.totalProgress ?? 0;

      // If progress is equal, sort by last update (most recent first)
      if (aProgress == bProgress) {
        return b.updatedAt.compareTo(a.updatedAt);
      }

      return bProgress.compareTo(aProgress);
    });

    _topProgressTheses.value = filteredTheses;
  }

  void updateSearch(String query) {
    _searchQuery.value = query;
  }
}
