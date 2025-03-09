import 'package:flutter/material.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class AvatarGroup extends StatelessWidget {
  final List<User> users;
  final int maxDisplayed;
  final double avatarSize;
  final double spacing;

  const AvatarGroup({
    super.key,
    required this.users,
    this.maxDisplayed = 4,
    this.avatarSize = 32,
    this.spacing = -16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedUsers = users.take(maxDisplayed).toList();
    final remainingCount = users.length - maxDisplayed;

    return SizedBox(
      height: avatarSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayedUsers.map((user) => Container(
                margin: EdgeInsets.only(right: spacing),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
          if (remainingCount > 0)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: theme.colorScheme.surfaceVariant,
                child: Text(
                  '+$remainingCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
