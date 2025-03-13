import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/admin_repository.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  late final ThesisController _thesisController;
  late final IAdminRepository _adminRepository;
  AdminController(
      {ThesisController? thesisController, IAdminRepository? adminRepository}) {
    _thesisController = thesisController ?? ThesisController.to;
    _adminRepository = adminRepository ?? AdminRepository();
  }

  final _users = Rx<List<User>>([]);
  List<User> get users => _users.value;
  List<User> get students =>
      users.where((user) => user.role == UserRole.student).toList();
  List<User> get lecturers =>
      users.where((user) => user.role == UserRole.lecturer).toList();

  int get totalUsers => users.length;
  int get totalStudents => students.length;
  int get totalLecturers => lecturers.length;

  int get totalCompletedTheses {
    return _thesisController.myTheses
        .where((thesis) => thesis.status == ThesisStatus.completed)
        .length;
  }

  int get totalOnTrackTheses {
    return _thesisController.myTheses
        .where((thesis) => thesis.status != ThesisStatus.completed)
        .length;
  }

  List<Thesis> get recentCompletedTheses {
    return _thesisController.myTheses
        .where((thesis) => thesis.status == ThesisStatus.completed)
        .toList()
      ..sort((a, b) => b.completionDate!.compareTo(a.completionDate!));
  }

  List<Thesis> get recentOnTrackTheses {
    return _thesisController.myTheses
        .where((thesis) => thesis.status != ThesisStatus.completed)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // -- Avg Completion Time in months --
  double get avgCompletionTime {
    final completedTheses = _thesisController.myTheses
        .where((thesis) => thesis.status == ThesisStatus.completed)
        .toList();

    if (completedTheses.isEmpty) {
      return 0.0;
    }

    // Calculate total days between submission and completion for all theses
    final totalDays = completedTheses.fold<int>(
      0,
      (sum, thesis) {
        if (thesis.completionDate == null) {
          return sum;
        }
        return sum +
            thesis.completionDate!.difference(thesis.submissionDate).inDays;
      },
    );

    // Calculate average days and round to 1 decimal place
    final averageDays = totalDays / completedTheses.length;
    return double.parse((averageDays).toStringAsFixed(1));
  }

  // -- Success Rate --
  double get successRate {
    final totalTheses = _thesisController.myTheses.length;
    final completedTheses = _thesisController.myTheses
        .where((thesis) => thesis.status == ThesisStatus.completed)
        .toList();
    final successRate =
        totalTheses != 0 ? completedTheses.length / totalTheses : 0.0;
    return successRate;
  }

  // -- Loading State --
  final _isUserLoading = false.obs;
  bool get isUserLoading => _isUserLoading.value;

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  Future<String?> getAllUsers() async {
    try {
      _isUserLoading.value = true;
      final result = await _adminRepository.getAllUsers();
      return result.fold(
        (failure) => failure.message,
        (users) {
          _users.value = users;
          return null;
        },
      );
    } finally {
      _isUserLoading.value = false;
    }
  }

  Future<String?> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      _isUserLoading.value = true;
      final result = await _adminRepository.updateUserRole(
        userId: userId,
        role: role,
      );
      return result.fold(
        (failure) => failure.message,
        (updatedUser) {
          final index = _users.value.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users.value[index] = updatedUser;
          }
          return null;
        },
      );
    } finally {
      _isUserLoading.value = false;
    }
  }

  Future<String?> deleteUser(String userId) async {
    try {
      _isUserLoading.value = true;
      final result = await _adminRepository.deleteUser(userId);
      return result.fold(
        (failure) => failure.message,
        (_) {
          _users.value.removeWhere((u) => u.id == userId);
          return null;
        },
      );
    } finally {
      _isUserLoading.value = false;
    }
  }
}
