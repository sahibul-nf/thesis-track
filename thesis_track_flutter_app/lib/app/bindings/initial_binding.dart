import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/file/controllers/file_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ThesisController());
    Get.put(ProgressController());
    Get.put(FileController());
  }
}
