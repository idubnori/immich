import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/domain/models/asset/base_asset.model.dart';
import 'package:immich_mobile/extensions/asyncvalue_extensions.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/widgets/activities/comment_bubble.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/like_activity_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/album/drift_activity_text_field.dart';
import 'package:immich_mobile/providers/activity.provider.dart';
import 'package:immich_mobile/providers/infrastructure/asset_viewer/current_asset.provider.dart';
import 'package:immich_mobile/providers/infrastructure/current_album.provider.dart';

@RoutePage()
class DriftActivitiesPage extends HookConsumerWidget {
  const DriftActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(currentRemoteAlbumProvider)!;
    final asset = ref.read(currentAssetNotifier) as RemoteAsset?;

    final activityNotifier = ref.read(albumActivityProvider(album.id, asset?.id).notifier);
    final activities = ref.watch(albumActivityProvider(album.id, asset?.id));
    final listViewScrollController = useScrollController();

    void scrollToBottom() {
      listViewScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
    }

    Future<void> onAddComment(String comment) async {
      await activityNotifier.addComment(comment);
      scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: asset == null ? Text(album.name) : null,
        actions: [const LikeActivityActionButton(menuItem: true)],
        actionsPadding: const EdgeInsets.only(right: 8),
      ),
      body: activities.widgetWhen(
        onData: (data) {
          final List<Widget> activityWidgets = [];
          for (final activity in data.reversed) {
            activityWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: CommentBubble(activity: activity),
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                ListView(
                  controller: listViewScrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  reverse: true,
                  children: activityWidgets,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.scaffoldBackgroundColor,
                      border: Border(top: BorderSide(color: context.colorScheme.secondaryContainer, width: 1)),
                    ),
                    child: DriftActivityTextField(isEnabled: album.isActivityEnabled, onSubmit: onAddComment),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
