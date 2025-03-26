import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/thesis_detail_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/thesis_list_view.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class MyThesisScreen extends GetView<ThesisController> {
  const MyThesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var isStudent = AuthController.to.user?.role == UserRole.student;

      if (controller.myTheses.isEmpty && !controller.isLoadingMyThesis) {
        var title = isStudent ? 'Start Your Thesis Journey' : 'No Theses Found';
        var message = isStudent
            ? 'Ready to begin? Submit your thesis proposal and take the first step towards your academic achievement.'
            : 'No theses found';
        var actionLabel = isStudent ? 'Submit Thesis' : 'Refresh';

        return EmptyStateWidget(
          title: title,
          message: message,
          icon: Iconsax.document_text,
          actionLabel: actionLabel,
          onAction: () {
            if (isStudent) {
              context.go(RouteLocation.toCreateThesis);
            } else {
              controller.getMyTheses();
            }
          },
          buttonSize: const Size(120, 48),
          actionIcon: isStudent ? null : Iconsax.refresh,
        );
      }

      if (!isStudent) {
        if (controller.isLoadingMyThesis) {
          return ThesisListView(theses: mockOtherTheses).asSkeleton();
        }

        final theses = controller.myTheses;
        return ThesisListView(theses: theses);
      }

      // if (controller.myTheses.length > 1) {
      //   return const Center(
      //     child: Text('You have multiple theses, please select one'),
      //   );
      // }

      if (controller.isLoadingMyThesis) {
        return ThesisDetailScreen(
          thesis: mockOtherTheses.first,
          isEmbedded: true,
        ).asSkeleton();
      }

      final thesis = controller.myTheses.firstOrNull;

      return ThesisDetailScreen(
        thesis: thesis ?? mockOtherTheses.first,
        isEmbedded: true,
      );
    });
  }
}
