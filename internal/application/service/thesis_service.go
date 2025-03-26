package service

import (
	"context"
	"errors"
	"log"
	"math"
	"slices"
	"time"

	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
)

type thesisService struct {
	thesisRepo       repository.ThesisRepository
	thesisLectureRepo repository.ThesisLectureRepository
	studentRepo      repository.StudentRepository
	lectureRepo      repository.LectureRepository
	progressRepo     repository.ProgressRepository
	emailService     service.EmailService
}

func NewThesisService(
	thesisRepo repository.ThesisRepository,
	thesisLectureRepo repository.ThesisLectureRepository,
	studentRepo repository.StudentRepository,
	lectureRepo repository.LectureRepository,
	progressRepo repository.ProgressRepository,
	emailService service.EmailService,
) service.ThesisService {
	return &thesisService{
		thesisRepo:       thesisRepo,
		thesisLectureRepo: thesisLectureRepo,
		progressRepo:     progressRepo,
		studentRepo:      studentRepo,
		lectureRepo:      lectureRepo,
		emailService:     emailService,
	}
}

func (s *thesisService) SubmitProposalThesis(ctx context.Context, req *dto.ThesisRequest, studentID uuid.UUID, supervisorID uuid.UUID) (*entity.Thesis, error) {
	// Check if student exists
	student, err := s.studentRepo.FindByID(ctx, studentID)
	if err != nil {
		return nil, err
	}
	if student == nil {
		return nil, errors.New("student not found")
	}

	// Check if supervisor exists
	supervisor, err := s.lectureRepo.FindByID(ctx, supervisorID)
	if err != nil {
		return nil, err
	}
	if supervisor == nil {
		return nil, errors.New("supervisor not found")
	}

	// Create thesis entity
	thesis := &entity.Thesis{
		StudentID:      studentID,
		SupervisorID:   supervisorID,
		Title:          req.Title,
		Abstract:       req.Abstract,
		ResearchField:  req.ResearchField,
		SubmissionDate: time.Now(),
		Status:         entity.ThesisPending,
	}

	thesis, err = s.thesisRepo.Create(ctx, thesis)
	if err != nil {
		return nil, err
	}

	// Send email notifications
	// To Student
	err = s.emailService.SendThesisProposalNotification(
		ctx,
		student.Email,
		thesis,
	)
	if err != nil {
		// Log error but don't fail the request
		log.Printf("Failed to send email to student: %v", err)
	}

	// To Supervisor
	err = s.emailService.SendThesisProposalNotification(
		ctx,
		supervisor.Email,
		thesis,
	)
	if err != nil {
		// Log error but don't fail the request
		log.Printf("Failed to send email to supervisor: %v", err)
	}

	return thesis, nil
}

func (s *thesisService) UpdateThesis(ctx context.Context, thesis *entity.Thesis) (*entity.Thesis, error) {
	// Check if thesis exists
	existingThesis, err := s.thesisRepo.FindByID(ctx, thesis.ID)
	if err != nil {
		return nil, err
	}
	if existingThesis == nil {
		return nil, errors.New("thesis not found")
	}

	updatedThesis, err := s.thesisRepo.Update(ctx, thesis)
	if err != nil {
		return nil, err
	}

	// Calculate thesis progress
	progresses, err := s.progressRepo.FindAllByThesisID(ctx, thesis.ID)
	if err != nil {
		return nil, err
	}

	thesisProgress, err := s.CalculateThesisProgress(ctx, thesis, progresses)
	if err != nil {
		return nil, err
	}

	// Assign thesis progress to thesis
	updatedThesis.ThesisProgress = thesisProgress

	return updatedThesis, nil
}

func (s *thesisService) DeleteThesis(ctx context.Context, id uuid.UUID) error {
	// Check if thesis exists
	existingThesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if existingThesis == nil {
		return errors.New("thesis not found")
	}

	return s.thesisRepo.Delete(ctx, id)
}

func (s *thesisService) GetThesisByID(ctx context.Context, id uuid.UUID) (*entity.Thesis, error) {
	thesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if thesis == nil {
		return nil, errors.New("thesis not found")
	}

	// Calculate thesis progress
	progresses, err := s.progressRepo.FindAllByThesisID(ctx, id)
	if err != nil {
		return nil, err
	}

	thesisProgress, err := s.CalculateThesisProgress(ctx, thesis, progresses)
	if err != nil {
		return nil, err
	}
	
	// Assign thesis progress to thesis
	thesis.ThesisProgress = thesisProgress

	return thesis, nil
}

func (s *thesisService) GetThesesByStudentID(ctx context.Context, studentID uuid.UUID) ([]entity.Thesis, error) {
	theses, err := s.thesisRepo.FindByStudentID(ctx, studentID)
	if err != nil {
		return nil, err
	}	

	// Calculate thesis progress
	for i := range theses {
		progresses, err := s.progressRepo.FindAllByThesisID(ctx, theses[i].ID)
		if err != nil {
			return nil, err
		}

		thesisProgress, err := s.CalculateThesisProgress(ctx, &theses[i], progresses)
		if err != nil {
			return nil, err
		}

		// Assign thesis progress to thesis
		theses[i].ThesisProgress = thesisProgress
	}

	return theses, nil
}

func (s *thesisService) GetAllTheses(ctx context.Context) ([]entity.Thesis, error) {
	theses, err := s.thesisRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}

	// Calculate thesis progress
	for i := range theses {
		progresses, err := s.progressRepo.FindAllByThesisID(ctx, theses[i].ID)
		if err != nil {
			return nil, err
		}

		thesisProgress, err := s.CalculateThesisProgress(ctx, &theses[i], progresses)
		if err != nil {
			return nil, err
		}

		// Assign thesis progress to thesis
		theses[i].ThesisProgress = thesisProgress
	}
	
	return theses, nil
}

func (s *thesisService) GetThesesByLectureID(ctx context.Context, lectureID uuid.UUID, lectureRole string) ([]entity.Thesis, error) {
	theses, err := s.thesisRepo.FindByLectureID(ctx, lectureID, lectureRole)
	if err != nil {
		return nil, err
	}

	// Calculate thesis progress
	for i := range theses {
		progresses, err := s.progressRepo.FindAllByThesisID(ctx, theses[i].ID)
		if err != nil {
			return nil, err
		}

		thesisProgress, err := s.CalculateThesisProgress(ctx, &theses[i], progresses)
		if err != nil {
			return nil, err
		}

		// Assign thesis progress to thesis
		theses[i].ThesisProgress = thesisProgress
	}

	return theses, nil	
}

func (s *thesisService) UpdateThesisStatus(ctx context.Context, id uuid.UUID, status string) error {
	// Validate status
	validStatuses := entity.ThesisStatuses

	if !slices.Contains(validStatuses, entity.ThesisStatus(status)) {
		return errors.New("invalid thesis status")
	}

	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if thesis == nil {
		return errors.New("thesis not found")
	}

	// Update completion date if status is Completed
	if status == string(entity.ThesisCompleted) && thesis.Status != entity.ThesisCompleted {
		completedDate := time.Now()
		thesis.CompletedDate = &completedDate
		_, err := s.thesisRepo.Update(ctx, thesis)
		if err != nil {
			return err
		}

		// Send email thesis completed notification
		// To Student
		err = s.emailService.SendThesisCompletedNotification(
			ctx,
			thesis.Student.Email,
			"Student",
			thesis,
		)
		if err != nil {
			// Log error but don't fail the request
			log.Printf("Failed to send email to student: %v", err)
		}

		// To Supervisor's and Examiner's email
		for _, thesisLecture := range thesis.ThesisLectures {
			err = s.emailService.SendThesisCompletedNotification(
				ctx,
				thesisLecture.Lecture.Email,
				string(thesisLecture.Role),
				thesis,
			)
			if err != nil {
				// Log error but don't fail the request
				log.Printf("Failed to send email to supervisor: %v", err)
			}
		}
	}

	// Update thesis status
	return s.thesisRepo.UpdateStatus(ctx, id, status)
}

func (s *thesisService) AssignSupervisor(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error) {
	return s.assignLectureToThesis(ctx, thesisID, lectureID, entity.SupervisorRole)
}

func (s *thesisService) AssignExaminer(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error) {
	return s.assignLectureToThesis(ctx, thesisID, lectureID, entity.ExaminerRole)
}

func (s *thesisService) assignLectureToThesis(ctx context.Context, thesisID, lectureID uuid.UUID, role entity.LectureRole) (*entity.ThesisLecture, error) {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return nil, err
	}
	if thesis == nil {
		return nil, errors.New("thesis not found")
	}

	// Check if lecture exists
	lecture, err := s.lectureRepo.FindByID(ctx, lectureID)
	if err != nil {
		return nil, err
	}
	if lecture == nil {
		return nil, errors.New("lecture not found")
	}

	// Check if the lecture is already assigned to this thesis
	thesisLectures, err := s.thesisLectureRepo.FindByThesisID(ctx, thesisID)
	if err != nil {
		return nil, err
	}

	for _, tl := range thesisLectures {
		if tl.LectureID == lectureID {
			if tl.Role != role {
				return nil, errors.New("lecture is already assigned a different role for this thesis")
			}
			
			// TODO: implement examiner can be assigned to both proposal defense and final defense
			// return nil, errors.New("lecture is already assigned this role for this thesis")
		}
	}

	var examinerType *entity.ExaminerType
	if role == "Examiner" {
		// Check if thesis is ready for proposal defense
		if !thesis.IsProposalReady {
			return nil, errors.New("thesis status must be Proposal Ready before assigning proposal defense examiner")
		}

		// if !thesis.IsFinalExamReady {
		// 	return nil, errors.New("thesis status must be Final Exam Ready before assigning final defense examiner")
		// }

		// Check if thesis is ready for final defense
		if thesis.IsFinalExamReady {
			finalDefenseExaminer := entity.FinalDefenseExaminer
			examinerType = &finalDefenseExaminer
		} else {
			// Assign proposal defense examiner		
			proposalDefenseExaminer := entity.ProposalDefenseExaminer
			examinerType = &proposalDefenseExaminer
		}
	}

	// Create new thesis-lecture relationship
	thesisLecture := &entity.ThesisLecture{
		ThesisID:  thesisID,
		LectureID: lectureID,
		Role:      role,
		ExaminerType: examinerType,
	}

	thesisLecture, err = s.thesisLectureRepo.Create(ctx, thesisLecture)
	if err != nil {
		return nil, err
	}

	// Update thesis status to In Progress if assigned supervisor same as the main supervisor
	if role == entity.SupervisorRole && thesis.SupervisorID == lectureID {
		err = s.UpdateThesisStatus(ctx, thesisID, string(entity.ThesisInProgress))
		if err != nil {
			return nil, err
		}
	}

	// Send email notifications
	// To Lecturer
	err = s.emailService.SendThesisLectureAssignedNotification(
		ctx,
		lecture.Email,
		string(role),
		thesis,
	)
	if err != nil {
		// Log error but don't fail the request
		log.Printf("Failed to send email to lecturer: %v", err)
	}

	return thesisLecture, nil
}

// Approve Thesis Proposal For Defense By Supervisor
func (s *thesisService) ApproveThesisForDefense(ctx context.Context, thesisID, lectureID uuid.UUID) error {
	// Get and validate thesis and its lectures
	thesis, thesisLectures, err := s.validateThesisAndGetLectures(ctx, thesisID)
	if err != nil {
		return err
	}

	// Get and validate thesis lecture
	thesisLecture, err := s.validateThesisLecture(thesisLectures, lectureID, entity.SupervisorRole)
	if err != nil {
		return err
	}

	// Check if all progress assigned to this supervisor has been reviewed
	if err := s.validateProgressReviews(ctx, thesisID, lectureID); err != nil {
		return err
	}

	// Update approval date
	now := time.Now()
	if thesisLecture.ProposalDefenseApprovedAt != nil {
		thesisLecture.FinalDefenseApprovedAt = &now
	} else {
		thesisLecture.ProposalDefenseApprovedAt = &now
	}
	
	allSupervisorApprovedProposal, allSupervisorApprovedFinal := s.checkAllSupervisorsApproved(thesisLectures, thesisLecture)
	
	// Check if all supervisors have approved proposal thesis and update thesis status to Proposal Ready
	if allSupervisorApprovedProposal && !thesis.IsProposalReady {
		thesis.IsProposalReady = true

		// Send email notification
		err = s.emailService.SendThesisReadyForExamNotification(ctx, thesis.Student.Email, thesis, "Proposal Defense")
		if err != nil {
			log.Printf("Failed to send email: %v", err)
		}
	}

	// Check if all supervisors have approved final thesis and update thesis status to Final Exam Ready
	if allSupervisorApprovedFinal && allSupervisorApprovedProposal && thesis.IsProposalReady {
		thesis.IsFinalExamReady = true

		// Send email notification
		err = s.emailService.SendThesisReadyForExamNotification(ctx, thesis.Student.Email, thesis, "Final Thesis Defense")
		if err != nil {
			log.Printf("Failed to send email: %v", err)
		}
	}

	// Update thesis-lecture relationship
	err = s.thesisLectureRepo.Update(ctx, thesisLecture)
	if err != nil {
		return err
	}

	// Update thesis
	_, err = s.thesisRepo.Update(ctx, thesis)
	if err != nil {
		return err
	}

	return nil
}

// Approve Thesis to be Finalized By Examiner
func (s *thesisService) ApproveThesisForFinalize(ctx context.Context, thesisID, lectureID uuid.UUID) error {
	// Get and validate thesis and its lectures
	thesis, thesisLectures, err := s.validateThesisAndGetLectures(ctx, thesisID)
	if err != nil {
		return err
	}
	
	// Get and validate thesis lecture for final defense examiner
	var thesisLecture *entity.ThesisLecture
	var isFinalDefenseExaminer bool
	for _, tl := range thesisLectures {
		if tl.LectureID == lectureID {
			isFinalDefenseExaminer = tl.Role == entity.ExaminerRole && *tl.ExaminerType == entity.FinalDefenseExaminer
			if isFinalDefenseExaminer {
				thesisLecture = &tl
				break
			}
		}
	}
	
	if thesisLecture == nil {
		return errors.New("lecture not assigned as final defense examiner")
	}

	if !isFinalDefenseExaminer {
		return errors.New("only lecture assigned as final defense examiner can approve thesis to be finalized")
	}
	
	// Check if all progress assigned to this examiner has been reviewed
	if err := s.validateProgressReviews(ctx, thesisID, lectureID); err != nil {
		return err
	}

	if !thesis.IsFinalExamReady {
		return errors.New("thesis is not ready for finalization")  
	}

	now := time.Now()
	thesisLecture.FinalizeApprovedAt = &now
	
	// Check if all examiners have approved thesis to be finalized and update thesis status to Under Review
	allExaminersApprovedToFinalize := s.checkAllExaminersApprovedForFinalize(thesisLectures, thesisLecture)
	if allExaminersApprovedToFinalize {
		// Update thesis status to Under Review
		thesis.Status = entity.ThesisUnderReview

		// Send email notification
		err = s.emailService.SendThesisReadyForFinalSubmissionNotification(ctx, thesis.Student.Email, thesis)
		if err != nil {
			log.Printf("Failed to send email: %v", err)
		}
	}

	// Update thesis-lecture relationship
	err = s.thesisLectureRepo.Update(ctx, thesisLecture)
	if err != nil {
		return err
	}

	// Update thesis
	_, err = s.thesisRepo.Update(ctx, thesis)
	if err != nil {
		return err
	}

	return nil
}

func (s *thesisService) checkAllSupervisorsApproved(thesisLectures []entity.ThesisLecture, updatedThesisLecture *entity.ThesisLecture) (bool, bool) {
	supervisors := 0
	approvedProposal := 0
	approvedFinal := 0

	for _, tl := range thesisLectures {
		if tl.Role != "Supervisor" {
			continue
		}

		supervisors++

		// assign updated thesis lecture to thesis lectures list
		if tl.LectureID == updatedThesisLecture.LectureID {
			tl = *updatedThesisLecture
		}

		// check if all supervisors have approved proposal thesis
		if tl.ProposalDefenseApprovedAt != nil {
			approvedProposal++
		}

		// check if all supervisors have approved final thesis
		if tl.FinalDefenseApprovedAt != nil {
			approvedFinal++
		}
	}

	return approvedProposal == supervisors, approvedFinal == supervisors
}

// check if all examiners have approved thesis to be finalized
func (s *thesisService) checkAllExaminersApprovedForFinalize(thesisLectures []entity.ThesisLecture, updatedThesisLecture *entity.ThesisLecture) bool {
	examiners := 0
	approved := 0

	for _, tl := range thesisLectures {
		if tl.Role != "Examiner" {
			continue
		}

		if tl.ExaminerType != nil && *tl.ExaminerType != entity.FinalDefenseExaminer {
			continue
		}

		examiners++

		// assign updated thesis lecture to thesis lectures list
		if tl.LectureID == updatedThesisLecture.LectureID {
			tl = *updatedThesisLecture
		}

		// check if all examiners have approved thesis to be finalized
		if tl.FinalizeApprovedAt != nil {
			approved++
		}
	}

	return approved == examiners
}


// validateThesisAndGetLectures checks if thesis exists and gets its lectures
func (s *thesisService) validateThesisAndGetLectures(ctx context.Context, thesisID uuid.UUID) (*entity.Thesis, []entity.ThesisLecture, error) {
    thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
    if err != nil {
        return nil, nil, err
    }
    if thesis == nil {
        return nil, nil, errors.New("thesis not found")
    }

    thesisLectures, err := s.thesisLectureRepo.FindByThesisID(ctx, thesisID)
    if err != nil {
        return nil, nil, err
    }
    if len(thesisLectures) == 0 {
        return nil, nil, errors.New("no lecture assigned to this thesis")
    }

    return thesis, thesisLectures, nil
}

// validateProgressReviews checks if all progress has been reviewed
func (s *thesisService) validateProgressReviews(ctx context.Context, thesisID, lectureID uuid.UUID) error {
    progresses, err := s.progressRepo.FindAllByThesisIDAndLectureID(ctx, thesisID, lectureID)
    if err != nil {
        return err
    }

    if len(progresses) == 0 {
        return errors.New("lecture must have at least one progress assigned to them")
    }

    for _, progress := range progresses {
        if progress.Status == "Pending" {
            return errors.New("all progress must be reviewed before thesis can be approved")
        }
    }

    return nil
}

// validateThesisLecture checks if the lecture is assigned and has the correct role
func (s *thesisService) validateThesisLecture(thesisLectures []entity.ThesisLecture, lectureID uuid.UUID, role entity.LectureRole) (*entity.ThesisLecture, error) {
    var thesisLecture *entity.ThesisLecture
    for _, tl := range thesisLectures {
        if tl.LectureID == lectureID {
            thesisLecture = &tl
            break
        }
    }
    if thesisLecture == nil {
        return nil, errors.New("lecture not assigned to this thesis")
    }

    if thesisLecture.Role != role {
		var errorMessage string
		if role == entity.SupervisorRole {
			errorMessage = "only lecture assigned as supervisor can approve thesis for defense"
		} else if role == entity.ExaminerRole {
			if *thesisLecture.ExaminerType != entity.FinalDefenseExaminer {
				errorMessage = "only lecture assigned as final defense examiner can approve thesis to be finalized"
			}
		}
        return nil, errors.New(errorMessage)
    }

    return thesisLecture, nil
}

func (s *thesisService) CalculateThesisProgress(ctx context.Context, thesis *entity.Thesis, progresses []entity.Progress) (*entity.ThesisProgress, error) {
	percentageProgress := &entity.ThesisProgress{
		TotalProgress: 0,
		Details: entity.ProgressDetails{
			InitialPhase:   0,
			ProposalPhase:  0,
			ResearchPhase:  0,
			FinalPhase:     0,
		},
	}

	// if thesis is completed, set the progress to 100%
	if thesis.Status == entity.ThesisCompleted {
		percentageProgress.TotalProgress = 100
		percentageProgress.Details.InitialPhase = 10
		percentageProgress.Details.ProposalPhase = 25
		percentageProgress.Details.ResearchPhase = 35
		percentageProgress.Details.FinalPhase = 30
		return percentageProgress, nil
	}

	// 1. Initial Phase (10%)
	percentageProgress.Details.InitialPhase = s.calculateInitialPhase(thesis)
	
	// 2. Proposal Phase (25%)
	percentageProgress.Details.ProposalPhase = s.calculateProposalPhase(thesis, progresses)
	
	// 3. Research Phase (35%)
	percentageProgress.Details.ResearchPhase = s.calculateResearchPhase(thesis, progresses)
	
	// 4. Final Phase (30%)
	percentageProgress.Details.FinalPhase = s.calculateFinalPhase(thesis, progresses)

	// Calculate total progress
	percentageProgress.TotalProgress = percentageProgress.Details.InitialPhase +
		percentageProgress.Details.ProposalPhase +
		percentageProgress.Details.ResearchPhase +
		percentageProgress.Details.FinalPhase

	return percentageProgress, nil
}

// calculateInitialPhase calculates the initial phase progress
// maximum progress is 10
func (s *thesisService) calculateInitialPhase(thesis *entity.Thesis) float64 {
	var progress float64 = 0

	// Initial submission
	if thesis.Status != "" {
		progress += entity.InitialSubmissionWeight
	}

	var index = thesis.Status.Index()

	// Admin approval to start
	if index >= entity.ThesisInProgress.Index() {
		progress += entity.InProgressWeight
	}

	return progress
}

// calculateProposalPhase calculates the proposal phase progress
// maximum progress is 25
func (s *thesisService) calculateProposalPhase(thesis *entity.Thesis, progresses []entity.Progress) float64 {
	var progress float64 = 0

	if thesis.IsProposalReady {
		return entity.ProposalProgressWeight + entity.ProposalApprovalWeight
	}

	// Calculate progress submissions for proposal
	proposalProgress := s.calculateProgressSubmissions(thesis, "proposal", progresses)
	progress += (proposalProgress * entity.ProposalProgressWeight)

	// Calculate supervisor approvals for proposal
	proposalApproval := s.calculateApprovalForProposal(thesis)
	progress += (proposalApproval * entity.ProposalApprovalWeight)

	return progress
}

func (s *thesisService) calculateResearchPhase(thesis *entity.Thesis, progresses []entity.Progress) float64 {
	var progress float64 = 0

	if !thesis.IsProposalReady {
		return 0
	}

	if thesis.IsFinalExamReady {
		return entity.ResearchProgressWeight + entity.ResearchApprovalWeight
	}

	// Calculate progress during research phase
	researchProgress := s.calculateProgressSubmissions(thesis, "research", progresses)
	progress += (researchProgress * entity.ResearchProgressWeight)

	// Calculate approval for research
	researchApproval := s.calculateApprovalForResearch(thesis)
	progress += (researchApproval * entity.ResearchApprovalWeight)

	return progress
}

func (s *thesisService) calculateFinalPhase(thesis *entity.Thesis, progresses []entity.Progress) float64 {
	var progress float64 = 0

	// Calculate progress submissions for final
	finalProgress := s.calculateProgressSubmissions(thesis, "final", progresses)
	progress += (finalProgress * entity.FinalProgressWeight)

	// Calculate approvals for finalization
	progress += s.calculateApprovalForFinalization(thesis) * entity.FinalizationApprovalWeight

	// Calculate upload final document
	if thesis.FinalDocumentURL != "" {
		progress += entity.UploadFinalDocumentWeight
	}

	// Final completion by admin
	if thesis.Status == entity.ThesisCompleted {
		progress += entity.CompletionWeight
	}

	return progress
}

func (s *thesisService) calculateProgressSubmissions(thesis *entity.Thesis, phase string, progresses []entity.Progress) float64 {
    var completedCount float64 = 0
    var totalExpected float64 = 0
    var assignedLectures []entity.ThesisLecture

    // Dapatkan waktu approval dari thesis lectures untuk timeline
    var proposalApprovalTimes []time.Time
    var finalDefenseApprovalTimes []time.Time
    var finalizeApprovalTimes []time.Time

    for _, tl := range thesis.ThesisLectures {
        if tl.ProposalDefenseApprovedAt != nil {
            proposalApprovalTimes = append(proposalApprovalTimes, *tl.ProposalDefenseApprovedAt)
        }
        if tl.FinalDefenseApprovedAt != nil {
            finalDefenseApprovalTimes = append(finalDefenseApprovalTimes, *tl.FinalDefenseApprovedAt)
        }
        if tl.FinalizeApprovedAt != nil {
            finalizeApprovalTimes = append(finalizeApprovalTimes, *tl.FinalizeApprovedAt)
        }
    }

    // Tentukan batas waktu untuk setiap phase
    var proposalReadyTime, finalExamReadyTime *time.Time
    if len(proposalApprovalTimes) > 0 {
        latest := proposalApprovalTimes[0]
        for _, t := range proposalApprovalTimes {
            if t.After(latest) {
                latest = t
            }
        }
        proposalReadyTime = &latest
    }
    if len(finalDefenseApprovalTimes) > 0 {
        latest := finalDefenseApprovalTimes[0]
        for _, t := range finalDefenseApprovalTimes {
            if t.After(latest) {
                latest = t
            }
        }
        finalExamReadyTime = &latest
    }

    // Filter progress berdasarkan timeline dan role
    var relevantProgresses []entity.Progress
    switch phase {
    case "proposal":
        // Progress sebelum proposal ready
        for _, progress := range progresses {
            if proposalReadyTime == nil || progress.CreatedAt.Before(*proposalReadyTime) {
                relevantProgresses = append(relevantProgresses, progress)
            }
        }
        // Hitung expected dari supervisor yang belum approve
        for _, thesisLecture := range thesis.ThesisLectures {
            if thesisLecture.Role == entity.SupervisorRole && 
               thesisLecture.ProposalDefenseApprovedAt == nil {
                totalExpected++
                assignedLectures = append(assignedLectures, thesisLecture)
            }
        }

    case "research":
        // Progress antara proposal ready dan final exam ready
        if thesis.IsProposalReady && !thesis.IsFinalExamReady {
            for _, progress := range progresses {
                if (proposalReadyTime != nil && progress.CreatedAt.After(*proposalReadyTime)) &&
                   (finalExamReadyTime == nil || progress.CreatedAt.Before(*finalExamReadyTime)) {
                    relevantProgresses = append(relevantProgresses, progress)
                }
            }
            // Hitung expected dari supervisor dan proposal examiner
            for _, thesisLecture := range thesis.ThesisLectures {
                if thesisLecture.Role == entity.SupervisorRole {
                    totalExpected++
                    assignedLectures = append(assignedLectures, thesisLecture)
                } else if thesisLecture.Role == entity.ExaminerRole && 
                          thesisLecture.ExaminerType != nil && 
                          *thesisLecture.ExaminerType == entity.ProposalDefenseExaminer {
                    totalExpected++
                    assignedLectures = append(assignedLectures, thesisLecture)
                }
            }
        }

    case "final":
        // Progress setelah final exam ready
        if thesis.IsFinalExamReady {
            for _, progress := range progresses {
                if finalExamReadyTime != nil && progress.CreatedAt.After(*finalExamReadyTime) {
                    relevantProgresses = append(relevantProgresses, progress)
                }
            }
            for _, thesisLecture := range thesis.ThesisLectures {
				// Hitung expected dari final examiner
                if thesisLecture.Role == entity.ExaminerRole && 
                   thesisLecture.ExaminerType != nil && 
                   *thesisLecture.ExaminerType == entity.FinalDefenseExaminer {
                    totalExpected++
                    assignedLectures = append(assignedLectures, thesisLecture)
                }

				// Hitung expected dari supervisor
				if thesisLecture.Role == entity.SupervisorRole {
					totalExpected++
					assignedLectures = append(assignedLectures, thesisLecture)
				}
            }
        }
    }

    if totalExpected == 0 {
        return 0
    }

    // Hitung completed submissions
    for _, lecture := range assignedLectures {
        for _, progress := range relevantProgresses {
            if progress.ReviewerID == lecture.LectureID && 
               progress.Status == entity.ProgressReviewed {
                completedCount++
                break // Hanya hitung satu progress reviewed per lecturer
            }
        }
    }

    progressRatio := completedCount / totalExpected
    if progressRatio > 1 {
        progressRatio = 1
    }

    return progressRatio
}

// Calculate approval for finalization (Final Defense)
func (s *thesisService) calculateApprovalForFinalization(thesis *entity.Thesis) float64 {
    var approvedCount float64 = 0
    var totalExpected float64 = 0

    // Hanya hitung jika thesis sudah Final Exam Ready
    if !thesis.IsFinalExamReady {
        return 0
    }

    for _, thesisLecture := range thesis.ThesisLectures {
        if thesisLecture.Role == entity.ExaminerRole && 
           thesisLecture.ExaminerType != nil && 
           *thesisLecture.ExaminerType == entity.FinalDefenseExaminer {
            totalExpected++
            if thesisLecture.FinalizeApprovedAt != nil {
                approvedCount++
            }
        }
    }

    if totalExpected == 0 {
        return 0
    }

    return math.Min(approvedCount/totalExpected, 1)
}

// Calculate approval for proposal
func (s *thesisService) calculateApprovalForProposal(thesis *entity.Thesis) float64 {
    var approvedCount float64 = 0
    var totalExpected float64 = 0

    // // Jika sudah Proposal Ready, return 1 (100%)
    // if thesis.IsProposalReady {
    //     return 1
    // }

    for _, thesisLecture := range thesis.ThesisLectures {
        if thesisLecture.Role == entity.SupervisorRole {
            totalExpected++
            if thesisLecture.ProposalDefenseApprovedAt != nil {
                approvedCount++
            }
        }
    }

    if totalExpected == 0 {
        return 0
    }

    return math.Min(approvedCount/totalExpected, 1)
}

// Calculate approval for research
func (s *thesisService) calculateApprovalForResearch(thesis *entity.Thesis) float64 {
    var approvedCount float64 = 0
    var totalExpected float64 = 0

    // Hitung supervisor approvals
    for _, thesisLecture := range thesis.ThesisLectures {
        if thesisLecture.Role == entity.SupervisorRole {
            totalExpected++
            if thesisLecture.FinalDefenseApprovedAt != nil {
                approvedCount++
            }
        }
    }

    // Hitung proposal examiner approvals
    // var proposalExaminersCount float64 = 0
    // var proposalExaminersApproved float64 = 0
    
    // for _, thesisLecture := range thesis.ThesisLectures {
    //     if thesisLecture.Role == entity.ExaminerRole && 
    //        thesisLecture.ExaminerType != nil && 
    //        *thesisLecture.ExaminerType == entity.ProposalDefenseExaminer {
    //         proposalExaminersCount++
    //         // Untuk examiner proposal, cukup memastikan mereka sudah memberikan review
    //         if len(thesis.Progresses) > 0 {
    //             hasReviewed := false
    //             for _, progress := range thesisLecture.Progresses {
    //                 if progress.Phase == "research" && progress.Status == entity.ProgressReviewed {
    //                     hasReviewed = true
    //                     break
    //                 }
    //             }
    //             if hasReviewed {
    //                 proposalExaminersApproved++
    //             }
    //         }
    //     }
    // }

    // Tambahkan examiner counts ke total
    // if proposalExaminersCount > 0 {
    //     totalExpected += proposalExaminersCount
    //     approvedCount += proposalExaminersApproved
    // }

    if totalExpected == 0 {
        return 0
    }

    return math.Min(approvedCount/totalExpected, 1)
}