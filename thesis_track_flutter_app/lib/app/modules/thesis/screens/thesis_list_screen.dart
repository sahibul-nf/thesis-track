import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/controllers/thesis_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/card.dart';
import 'package:thesis_track_flutter_app/app/widgets/custom_menu_item.dart';
import 'package:thesis_track_flutter_app/app/widgets/popup_menu.dart';

class ThesisListScreen extends GetView<ThesisController> {
  const ThesisListScreen({super.key, required this.theses});

  final List<Thesis> theses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await controller.getMyTheses();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(AppTheme.spaceLG),
        itemCount: theses.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppTheme.spaceXS),
        itemBuilder: (context, index) {
          final thesis = theses[index];
          final progresses = thesis.progresses;

          return ThesisCard(
            onTap: () => context.go(
              RouteLocation.toThesisDetail(thesis.id),
              extra: thesis,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Research Field Icon & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Research Field Icon
                          Container(
                            padding: EdgeInsets.all(AppTheme.spaceSM),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.chipRadius),
                            ),
                            child: Icon(
                              Iconsax.document_text1,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMD),
                          // Title & Research Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                thesis.researchField,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: AppTheme.spaceXS),
                              Text(
                                thesis.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppTheme.spaceSM),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSM,
                        vertical: AppTheme.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: thesis.status.color.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.chipRadius),
                      ),
                      child: Text(
                        thesis.status.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: thesis.status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spaceSM),
                    // Options
                    PopupMenu(
                      builder: (context, menuController, child) {
                        return InkWell(
                          onTap: () {
                            final position = Offset(
                              MediaQuery.of(context).size.width,
                              100,
                            );

                            menuController.open(
                              position: position,
                            );
                          },
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spaceXS),
                            child: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        );
                      },
                      menuChildren: [
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              CustomMenuItem(
                                onTap: () {},
                                title: 'Edit',
                                leading: const Icon(Iconsax.edit, size: 18),
                              ),
                              CustomMenuItem(
                                onTap: () {},
                                title: 'Delete',
                                leading: const Icon(Iconsax.trash, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spaceSM),
                // Progress Info & Created At
                Obx(() {
                  return Row(
                    children: [
                      Text(
                        'Created ${DateFormat('dd MMM yyyy').format(thesis.createdAt)}  •',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Progress Info
                        Padding(
                          padding: EdgeInsets.only(left: AppTheme.spaceSM),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${progresses.length} ',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                text: 'Sessions',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Member Count
                      Padding(
                        padding: EdgeInsets.only(left: AppTheme.spaceSM),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${thesis.members.total} ',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'Members',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: AppTheme.spaceMD),

                // Abstract Preview
                Text(
                  thesis.abstract,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: AppTheme.spaceMD),

                // Created by
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Created by ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: thesis.student.name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
