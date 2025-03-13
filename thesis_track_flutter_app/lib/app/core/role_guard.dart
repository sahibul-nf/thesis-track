import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class RoleGuard {
  static User? getCurrentUser() {
    return StorageService.getUser();
  }

  static bool canEditThesis(String ownerId) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    if (role == UserRole.student) {
      return user.id == ownerId;
    }

    return role == UserRole.admin;
  }

  static bool canDeleteThesis(String ownerId) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    if (role == UserRole.student) {
      return user.id == ownerId;
    }

    return role == UserRole.admin;
  }

  static bool canCreateThesis() {
    final user = getCurrentUser();
    if (user == null) return false;

    final role = user.role;

    return role == UserRole.student;
  }

  static bool canReviewThesis() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.lecturer || role == UserRole.admin;
  }

  static bool canManageUsers() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.admin;
  }

  static bool canUploadDocuments() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.student;
  }

  static bool canAddProgress() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.student;
  }

  /// Review Progress Guard
  /// Only reviewer can review progress
  static bool canReviewProgress(ProgressModel progress) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.lecturer && progress.reviewerId == user.id;
  }

  /// Add Comment Guard
  /// All authenticated users can add comments
  static bool canAddComment() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role != null;
  }

  static bool canAssignSupervisor(ThesisStatus status) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.admin;
  }

  /// Assign Examiner Guard
  /// Only admin can assign examiners
  static bool canAssignExaminer(Thesis thesis) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;
    if (role != UserRole.admin) return false;

    // Thesis must be in progress
    if (thesis.status != ThesisStatus.inProgress) return false;

    // // Supervisor must be approved proposal defense
    // if (thesis.supervisors.any((e) => e.user.id == user.id && e.role == ThesisLectureRole.supervisor && e.proposalDefenseApprovedAt == null)) return false;

    // // Supervisor must be approved final defense
    // if (thesis.supervisors.any((e) => e.user.id == user.id && e.role == ThesisLectureRole.supervisor && e.finalDefenseApprovedAt == null)) return false;

    return true;
  }

  /// Approve Proposal Defense Thesis Guard
  /// Supervisor and examiners can approve a thesis
  static RxBool canApproveThesisForProposalDefense(Thesis thesis) {
    final user = getCurrentUser();
    if (user == null) return RxBool(false);

    final role = user.role;
    var lectureId = user.id;

    // Only lecturers can approve a thesis
    if (role != UserRole.lecturer) return RxBool(false);

    // Thesis must be in progress
    // if (thesis.status != ThesisStatus.inProgress) return false;

    // Lecturer must be a supervisor or examiner
    var isSupervisor = thesis.supervisors.any((e) => e.user.id == lectureId);
    var isExaminer = thesis.examiners.any((e) => e.user.id == lectureId);
    if (!isSupervisor && !isExaminer) return RxBool(false);

    // Supervisor or examiner must have at least progress session reviewed
    var progressSessions = thesis.progresses;
    if (progressSessions.isEmpty) return RxBool(false);

    // Check if the progress session is reviewed
    var isReviewed = progressSessions.any((e) =>
        e.status.value.toLowerCase() == 'reviewed' &&
        e.reviewerId == lectureId);
    if (!isReviewed) return RxBool(false);

    // Check if the lecturer has approved the thesis for proposal defense
    var isApprovedForProposalDefense = thesis.supervisors.any(
        (e) => e.user.id == lectureId && e.proposalDefenseApprovedAt != null);
    if (isApprovedForProposalDefense) return RxBool(false);

    return RxBool(true);
  }

  /// Approve Final Defense Thesis Guard
  /// Supervisor and examiners can approve a thesis
  static bool canApproveThesisForFinalDefense(Thesis thesis) {
    final user = getCurrentUser();
    if (user == null) return false;

    final role = user.role;
    var lectureId = user.id;

    // Only lecturers can approve a thesis
    if (role != UserRole.lecturer) return false;

    // Thesis must be in progress
    // if (thesis.status != ThesisStatus.inProgress) return false;

    // Lecturer must be a supervisor or examiner
    var isSupervisor = thesis.supervisors.any((e) => e.user.id == lectureId);
    var isExaminer = thesis.examiners.any((e) => e.user.id == lectureId);
    if (!isSupervisor && !isExaminer) return false;

    // Supervisor or examiner must have at least progress session reviewed
    var progressSessions = thesis.progresses;
    if (progressSessions.isEmpty) return false;

    // Check if the progress session is reviewed
    var isReviewed = progressSessions.any((e) =>
        e.status.value.toLowerCase() == 'reviewed' &&
        e.reviewerId == lectureId);
    if (!isReviewed) return false;

    // Thesis must be have ready Proposal Defense
    if (!thesis.isProposalReady) return false;

    // Check if the lecturer has approved the thesis for final defense
    var isApprovedForFinalDefense = thesis.supervisors
        .any((e) => e.user.id == lectureId && e.finalDefenseApprovedAt != null);
    if (isApprovedForFinalDefense) return false;

    return true;
  }

  /// Accept Thesis Guard
  /// Only admin can accept a thesis submission
  static bool canAcceptThesisSubmission(Thesis thesis) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    // Only admin can accept a thesis submission
    if (role != UserRole.admin) return false;

    // Thesis must be pending
    if (thesis.status != ThesisStatus.pending) return false;

    // Thesis must have a supervisor assigned
    if (thesis.supervisorId.isEmpty) return false;

    return true;
  }

  /// Mark as Completed Guard
  /// Only admin can mark a thesis as completed
  static bool canMarkAsCompleted(Thesis thesis) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    if (role != UserRole.admin) return false;

    // If the thesis is completed, return false
    if (thesis.status == ThesisStatus.completed) return false;

    var isUnderReview = thesis.status == ThesisStatus.underReview;
    var isProposalReady = thesis.isProposalReady;
    var isFinalExamReady = thesis.isFinalExamReady;
    var isFinalDocUploaded =
        thesis.finalDocumentUrl != null && thesis.finalDocumentUrl!.isNotEmpty;

    // If the thesis is not proposal ready or final exam ready, return false
    if (!isProposalReady || !isFinalExamReady) return false;

    // If the thesis is not under review or the final document is not uploaded, return false
    if (!isUnderReview || !isFinalDocUploaded) return false;

    return true;
  }

  static bool canAssignReviewer(String userId) {
    // ONLY owner of the thesis can assign reviewer
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    var isOwner = user.id == userId;
    return role == UserRole.student && isOwner;
  }

  static bool canEditProgress() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.student;
  }

  static bool canDeleteProgress() {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;

    return role == UserRole.student;
  }
}
