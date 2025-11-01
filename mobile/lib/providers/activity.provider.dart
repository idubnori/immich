import 'package:immich_mobile/models/activities/activity.model.dart';
import 'package:immich_mobile/providers/activity_service.provider.dart';
import 'package:immich_mobile/providers/activity_statistics.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity.provider.g.dart';

// ignore: unintended_html_in_doc_comment
/// Maintains the current list of all activities for <share-album-id, asset>
@riverpod
class AlbumActivity extends _$AlbumActivity {
  @override
  Future<List<Activity>> build(String albumId, [String? assetId]) async {
    return ref.watch(activityServiceProvider).getAllActivities(albumId, assetId: assetId);
  }

  Future<void> removeActivity(String id) async {
    if (await ref.watch(activityServiceProvider).removeActivity(id)) {
      final removedActivity = _removeFromState(id);
      if (removedActivity == null) {
        return;
      }

      if (assetId != null) {
        ref.read(albumActivityProvider(albumId).notifier)._removeFromState(id);
      }

      if (removedActivity.type == ActivityType.comment) {
        ref.watch(activityStatisticsProvider(albumId, assetId).notifier).removeActivity();
        if (assetId != null) {
          ref.watch(activityStatisticsProvider(albumId).notifier).removeActivity();
        }
      }
    }
  }

  Future<void> addLike() async {
    final activity = await ref.watch(activityServiceProvider).addActivity(albumId, ActivityType.like, assetId: assetId);
    if (activity.hasValue) {
      _addToState(activity.requireValue);
      if (assetId != null) {
        ref.read(albumActivityProvider(albumId).notifier)._addToState(activity.requireValue);
      }
    }
  }

  Future<void> addComment(String comment) async {
    final activity = await ref
        .watch(activityServiceProvider)
        .addActivity(albumId, ActivityType.comment, assetId: assetId, comment: comment);

    if (activity.hasValue) {
      _addToState(activity.requireValue);
      if (assetId != null) {
        ref.read(albumActivityProvider(albumId).notifier)._addToState(activity.requireValue);
      }
      ref.watch(activityStatisticsProvider(albumId, assetId).notifier).addActivity();
      // The previous addActivity call would increase the count of an asset if assetId != null
      // To also increase the activity count of the album, calling it once again with assetId set to null
      if (assetId != null) {
        ref.watch(activityStatisticsProvider(albumId).notifier).addActivity();
      }
    }
  }

  void _addToState(Activity activity) {
    final activities = state.valueOrNull ?? [];
    if (activities.any((a) => a.id == activity.id)) {
      return;
    }
    state = AsyncData([...activities, activity]);
  }

  Activity? _removeFromState(String id) {
    final activities = state.valueOrNull;
    if (activities == null) {
      return null;
    }
    final index = activities.indexWhere((a) => a.id == id);
    if (index == -1) {
      return null;
    }
    final updated = [...activities]..removeAt(index);
    final removed = activities[index];
    state = AsyncData(updated);
    return removed;
  }
}

/// Mock class for testing
abstract class AlbumActivityInternal extends _$AlbumActivity {}
