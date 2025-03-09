import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/home/screens/home_admin_view.dart';
import 'package:thesis_track_flutter_app/app/modules/home/screens/home_lecturer_view.dart';
import 'package:thesis_track_flutter_app/app/modules/home/screens/home_student_view.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final thesisC = ThesisController.to;
    final authC = AuthController.to;

    /// Content View based on user role
    return Obx(() {
      var role = authC.user?.role;

      switch (role) {
        case UserRole.student:
          return const HomeStudentView();
        case UserRole.lecturer:
          return const HomeLecturerView();
        case UserRole.admin:
          return const HomeAdminView();
        default:
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.9,
            width: MediaQuery.sizeOf(context).width,
            child: const Center(
              child: Text('Coming soon'),
            ),
          );
      }
    });
  }
}
