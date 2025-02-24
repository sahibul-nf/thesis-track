import 'package:thesis_track_flutter_app/app/core/storage_service.dart';

enum UserRole {
  student,
  lecturer,
  admin;

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == role.toLowerCase(),
      orElse: () => UserRole.student,
    );
  }
}

class RoleGuard {
  static UserRole? getCurrentRole() {
    final userData = StorageService.getUser();
    return UserRole.fromString(userData?['role'] as String?);
  }

  static bool canCreateThesis() {
    return getCurrentRole() == UserRole.student;
  }

  static bool canReviewThesis() {
    final role = getCurrentRole();
    return role == UserRole.lecturer || role == UserRole.admin;
  }

  static bool canManageUsers() {
    return getCurrentRole() == UserRole.admin;
  }

  static bool canUploadDocuments() {
    return getCurrentRole() == UserRole.student;
  }

  static bool canAddProgress() {
    return getCurrentRole() == UserRole.student;
  }

  static bool canReviewProgress() {
    final role = getCurrentRole();
    return role == UserRole.lecturer || role == UserRole.admin;
  }

  static bool canAssignSupervisor() {
    return getCurrentRole() == UserRole.admin;
  }

  static bool canAssignExaminer() {
    return getCurrentRole() == UserRole.admin;
  }

  static bool canApproveThesis() {
    final role = getCurrentRole();
    return role == UserRole.lecturer || role == UserRole.admin;
  }

  static bool canMarkAsCompleted() {
    final role = getCurrentRole();
    return role == UserRole.lecturer || role == UserRole.admin;
  }

  static bool canAddComment() {
    // All authenticated users can add comments
    return getCurrentRole() != null;
  }
}
