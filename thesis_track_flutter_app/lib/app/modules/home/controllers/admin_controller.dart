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

  List<Thesis> get pendingActionTheses {
    return _thesisController.myTheses
        .where((thesis) =>
            thesis.status == ThesisStatus.pending ||
            (thesis.status == ThesisStatus.underReview &&
                thesis.finalDocumentUrlRx.isNotEmpty))
        .toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
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

  /// Get formatted avg completion time
  String get formattedAvgCompletionTime {
    final avgCompletionTime = this.avgCompletionTime; // in days

    if (avgCompletionTime < 30) {
      return '${avgCompletionTime.toStringAsFixed(0)} days';
    } else if (avgCompletionTime < 365) {
      return '${(avgCompletionTime / 30).toStringAsFixed(0)} months';
    } else {
      return '${(avgCompletionTime / 365).toStringAsFixed(0)} years';
    }
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

  // Menghitung avg completion time untuk periode tertentu
  double getAvgCompletionTimeForPeriod(DateTime startDate, DateTime endDate) {
    final completedTheses = _thesisController.myTheses
        .where((thesis) =>
            thesis.status == ThesisStatus.completed &&
            thesis.completionDate != null &&
            thesis.completionDate!.isAfter(startDate) &&
            thesis.completionDate!.isBefore(endDate))
        .toList();

    if (completedTheses.isEmpty) {
      return 0.0;
    }

    final totalDays = completedTheses.fold<int>(
      0,
      (sum, thesis) {
        return sum +
            thesis.completionDate!.difference(thesis.submissionDate).inDays;
      },
    );

    return totalDays / completedTheses.length;
  }

  // Menghitung trend (perbandingan dengan periode sebelumnya)
  String get completionTimeTrend {
    final now = DateTime.now();
    final currentPeriodStart =
        now.subtract(const Duration(days: 30)); // 30 hari terakhir
    final previousPeriodStart = currentPeriodStart
        .subtract(const Duration(days: 30)); // 30 hari sebelumnya

    final currentAvg = getAvgCompletionTimeForPeriod(currentPeriodStart, now);
    final previousAvg =
        getAvgCompletionTimeForPeriod(previousPeriodStart, currentPeriodStart);

    if (previousAvg == 0) return '+0.0%';

    final percentageChange = ((currentAvg - previousAvg) / previousAvg) * 100;

    // Format dengan tanda + atau - dan 1 desimal
    final trend = percentageChange.toStringAsFixed(1);
    return percentageChange > 0 ? '+$trend%' : '$trend%';
  }

  // Menghitung success rate untuk periode tertentu
  double getSuccessRateForPeriod(DateTime startDate, DateTime endDate) {
    final thesesInPeriod = _thesisController.myTheses
        .where((thesis) =>
            thesis.submissionDate.isAfter(startDate) &&
            thesis.submissionDate.isBefore(endDate))
        .toList();

    if (thesesInPeriod.isEmpty) return 0.0;

    final completedThesesInPeriod = thesesInPeriod
        .where((thesis) =>
            thesis.status == ThesisStatus.completed &&
            thesis.completionDate != null &&
            thesis.completionDate!.isBefore(endDate))
        .length;

    return completedThesesInPeriod / thesesInPeriod.length;
  }

  // Menghitung trend success rate
  String get successRateTrend {
    final now = DateTime.now();
    final currentPeriodStart = now.subtract(const Duration(days: 30));
    final previousPeriodStart =
        currentPeriodStart.subtract(const Duration(days: 30));

    final currentRate = getSuccessRateForPeriod(currentPeriodStart, now);
    final previousRate =
        getSuccessRateForPeriod(previousPeriodStart, currentPeriodStart);

    if (previousRate == 0) return '+0.0%';

    final percentageChange =
        ((currentRate - previousRate) / previousRate) * 100;

    // Format dengan tanda + atau - dan 1 desimal
    final trend = percentageChange.toStringAsFixed(1);
    return percentageChange > 0 ? '+$trend%' : '$trend%';
  }
  
  // Format success rate ke persentase
  String get formattedSuccessRate {
    return '${(successRate * 100).toStringAsFixed(1)}%';
  }

  Map<String, double> get projectHealthDistribution {
    final activeTheses = _thesisController.myTheses
        .where((thesis) => thesis.status != ThesisStatus.completed);
    
    final total = activeTheses.length;
    if (total == 0) return {'On Track': 0, 'At Risk': 0, 'Delayed': 0};

    final onTrack = activeTheses
        .where((thesis) => 
          thesis.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 14))))
        .length;
    
    final atRisk = activeTheses
        .where((thesis) => 
          thesis.updatedAt.isBefore(DateTime.now().subtract(const Duration(days: 14))) &&
          thesis.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;
    
    final delayed = total - onTrack - atRisk;

    return {
      'On Track': (onTrack / total) * 100, // 14 days
      'At Risk': (atRisk / total) * 100, // 14 - 30 days
      'Delayed': (delayed / total) * 100, // > 30 days
    };
  }

  String get formattedProjectHealth {
    final health = projectHealthDistribution;
    return '${health['On Track']?.toStringAsFixed(1)}%';
  }

  String get projectHealthTrend {
    // Bandingkan dengan bulan sebelumnya
    final now = DateTime.now();
    final currentPeriodStart = now.subtract(const Duration(days: 30));
    final previousPeriodStart = currentPeriodStart.subtract(const Duration(days: 30));

    final currentHealth = getProjectHealthForPeriod(currentPeriodStart, now);
    final previousHealth = getProjectHealthForPeriod(previousPeriodStart, currentPeriodStart);

    if (previousHealth == 0) return '+0.0%';

    final percentageChange = ((currentHealth - previousHealth) / previousHealth) * 100;
    final trend = percentageChange.toStringAsFixed(1);
    return percentageChange > 0 ? '+$trend%' : '$trend%';
  }

  double getProjectHealthForPeriod(DateTime start, DateTime end) {
    final thesesInPeriod = _thesisController.myTheses
        .where((thesis) => 
          thesis.status != ThesisStatus.completed &&
          thesis.updatedAt.isAfter(start) &&
          thesis.updatedAt.isBefore(end));
    
    if (thesesInPeriod.isEmpty) return 0.0;

    final onTrack = thesesInPeriod
        .where((thesis) => 
          thesis.updatedAt.isAfter(end.subtract(const Duration(days: 14))))
        .length;

    return onTrack / thesesInPeriod.length * 100;
  }
}
