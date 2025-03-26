import 'package:get/get.dart';
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

  static bool canAssignSupervisor(Thesis thesis) {
    final user = getCurrentUser();
    if (user == null) return false;

    final role = user.role;
    if (role != UserRole.admin) return false;

    // Thesis must be in progress
    if (thesis.status != ThesisStatus.inProgress) return false;

    // Maximum 2 supervisors
    if (thesis.supervisors.length >= 2) return false;

    return true;
  }

  /// Assign Examiner Guard
  /// Only admin can assign examiners
  static bool canAssignProposalDefenseExaminer(Thesis thesis) {
    final user = getCurrentUser();
    final role = user?.role;

    if (user == null) return false;
    if (role != UserRole.admin) return false;

    // Thesis must be in progress
    if (thesis.status != ThesisStatus.inProgress) return false;

    // Maximum 2 examiners with role proposal defense
    var allProposalDefenseExaminers = thesis.examiners
        .where((e) =>
            e.examinerType == ThesisLectureExaminerType.proposalDefenseExaminer)
        .toList();
    if (allProposalDefenseExaminers.length >= 2) return false;

    // Thesis must be proposal ready
    if (!thesis.isProposalReady) return false;

    // // Supervisor must be approved proposal defense
    // if (thesis.supervisors.any((e) => e.user.id == user.id && e.role == ThesisLectureRole.supervisor && e.proposalDefenseApprovedAt == null)) return false;

    // // Supervisor must be approved final defense
    // if (thesis.supervisors.any((e) => e.user.id == user.id && e.role == ThesisLectureRole.supervisor && e.finalDefenseApprovedAt == null)) return false;

    return true;
  }

  static bool canAssignFinalDefenseExaminer(Thesis thesis) {
    final user = getCurrentUser();
    if (user == null) return false;

    final role = user.role;
    if (role != UserRole.admin) return false;

    // Thesis must be in progress
    if (thesis.status != ThesisStatus.inProgress) return false;

    // Maximum 2 examiners with role final defense
    var allFinalDefenseExaminers = thesis.examiners
        .where((e) =>
            e.examinerType == ThesisLectureExaminerType.finalDefenseExaminer)
        .toList();
    if (allFinalDefenseExaminers.length >= 2) return false;

    // Thesis must be final exam ready
    if (!thesis.isFinalExamReady) return false;

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
    if (thesis.status != ThesisStatus.inProgress) return RxBool(false);

    // Lecturer must be a supervisor or examiner
    var isSupervisor = thesis.supervisors.any((e) => e.user.id == lectureId);
    if (!isSupervisor) return RxBool(false);

    // Supervisor or examiner must have at least progress session reviewed
    var progressSessions = thesis.progresses;
    if (progressSessions.isEmpty) return RxBool(false);

    // All progress sessions must be reviewed
    var isReviewed = progressSessions.every((e) =>
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
    if (thesis.status != ThesisStatus.inProgress) return false;

    // Lecturer must be a supervisor or examiner
    var mySupervisor =
        thesis.supervisors.firstWhereOrNull((e) => e.user.id == lectureId);
    if (mySupervisor == null) return false;

    // Check if current lecturer has already approved (either proposal or final)
    if (mySupervisor.proposalDefenseApprovedAt != null ||
        mySupervisor.finalDefenseApprovedAt != null) {
      return false;
    }

    // Supervisor must have at least one progress session reviewed
    var myProgressSessions =
        thesis.progresses.where((e) => e.reviewerId == lectureId).toList();
    if (myProgressSessions.isEmpty) return false;

    var hasReviewedProgress = myProgressSessions
        .any((e) => e.status.value.toLowerCase() == 'reviewed');
    if (!hasReviewedProgress) return false;

    // Thesis must have ready Proposal Defense
    if (!thesis.isProposalReady) return false;

    // Check proposal defense examiner requirements
    var proposalExaminers = thesis.examiners
        .where((e) =>
            e.examinerType == ThesisLectureExaminerType.proposalDefenseExaminer)
        .toList();

    // Must have proposal examiner with reviewed progress
    var proposalExaminerProgressSessions = thesis.progresses
        .where((e) =>
            proposalExaminers.any((p) => p.user.id == e.reviewer.id) &&
            e.status.value.toLowerCase() == 'reviewed')
        .toList();

    if (proposalExaminerProgressSessions.isEmpty) return false;

    // Check for progress sessions after proposal defense examiner review
    var lastProposalExaminerReview = proposalExaminerProgressSessions
        .map((e) => e.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    var progressSessionsAfterExaminerReview = thesis.progresses
        .where((e) => e.createdAt.isAfter(lastProposalExaminerReview))
        .toList();

    // Require at least 2 progress sessions after examiner review
    if (progressSessionsAfterExaminerReview.length < 2) return false;

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

  static bool canApproveThesisForFinalization(Thesis thesis) {
    final user = getCurrentUser();
    if (user == null) return false;
    final role = user.role;

    // Only lecturer assigned as final examiner can approve the thesis
    if (role != UserRole.lecturer) return false;

    // Thesis must be in progress
    if (thesis.status != ThesisStatus.inProgress) return false;

    // Lecturer must be a final examiner
    var myFinalExaminer = thesis.examiners.firstWhereOrNull((e) =>
        e.user.id == user.id &&
        e.examinerType == ThesisLectureExaminerType.finalDefenseExaminer);
    if (myFinalExaminer == null) return false;

    // Thesis must be final exam ready
    if (!thesis.isFinalExamReady) return false;

    // Assigned progress sessions as final examiner must be reviewed
    var myProgressSessions =
        thesis.progresses.where((e) => e.reviewerId == user.id).toList();
    if (myProgressSessions.isEmpty) return false;

    var hasReviewedProgress = myProgressSessions
        .any((e) => e.status.value.toLowerCase() == 'reviewed');
    if (!hasReviewedProgress) return false;

    // Check if has approved the thesis for finalization
    var isApproved = myFinalExaminer.finalizeApprovedAt != null;
    if (isApproved) return false;

    return true;
  }
}
