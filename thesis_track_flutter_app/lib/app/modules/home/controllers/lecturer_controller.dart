import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';

class LecturerController extends GetxController {
  static LecturerController get to => Get.find();

  late final ThesisController _thesisController;
  LecturerController({ThesisController? thesisController}) {
    _thesisController = thesisController ?? ThesisController.to;
  }

  List<Thesis> get recentSupervisions => _thesisController.myTheses
      .where((thesis) => thesis.mainSupervisor.id == AuthController.to.user?.id)
      .toList();

  List<Thesis> get recentCoSupervisions => _thesisController.myTheses
      .where((thesis) =>
          thesis.supervisors.any((s) => s.user.id == AuthController.to.user?.id) &&
          thesis.mainSupervisor.id != AuthController.to.user?.id)
      .toList();

  List<Thesis> get recentExaminations => _thesisController.myTheses
      .where((thesis) =>
          thesis.examiners.any((e) => e.user.id == AuthController.to.user?.id))
      .toList();

  List<Thesis> get recentProgressReviews => _thesisController.myTheses
      .where((thesis) => thesis.progresses
          .any((p) => p.reviewer.id == AuthController.to.user?.id))
      .toList();
}
