import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/file/controllers/file_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/admin_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/controllers/lecturer_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => ProgressController(), fenix: true);
    Get.lazyPut(() => ThesisController(), fenix: true);
    Get.lazyPut(() => FileController(), fenix: true);
    Get.lazyPut(() => AdminController(), fenix: true);
    Get.lazyPut(() => LecturerController(), fenix: true);
  }
}
