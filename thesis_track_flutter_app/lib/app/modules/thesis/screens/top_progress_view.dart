import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as sha;
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/widgets/top_progress_list_view.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/empty_state.dart';

class TopProgressView extends GetView<ThesisController> {
  const TopProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.topProgressTheses.isEmpty &&
          !controller.isLoadingAllTheses) {
        return EmptyStateWidget(
          title: 'No Top Progress Found',
          message:
              'It looks like there are no theses with top progress to display. Try filtering by year or refreshing the list.',
          icon: Iconsax.ranking_1,
          onAction: () => controller.getAllTheses(),
          actionLabel: 'Refresh',
          actionIcon: Iconsax.refresh,
          buttonSize: const Size(140, 48),
        );
      }

      return Column(
        children: [
          // Year Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
            child: Row(
              children: [
                Text('Filter by Academic Year:',
                    style: theme.textTheme.titleSmall),
                const SizedBox(width: 10),
                Obx(() => DropdownButton<String>(
                      value: controller.selectedYear.isEmpty
                          ? null
                          : controller.selectedYear,
                      hint: const Text('All'),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All'),
                        ),
                        ...controller.availableYears.map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year ?? 'All'),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          controller.getTopProgressTheses(value),
                    )),
              ],
            ),
          ),

          // Progress List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAllTheses) {
                return TopProgressListView(theses: mockOtherTheses)
                    .asSkeleton();
              }

              return TopProgressListView(
                theses: controller.topProgressTheses,
              );
            }),
          ),
        ],
      );
    });
  }
}
