import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/providers/app_settings.provider.dart';
import 'package:immich_mobile/utils/action_button.utils.dart';

final viewerQuickActionOrderProvider = StreamProvider<List<ActionButtonType>>((ref) {
  final settings = ref.watch(appSettingsServiceProvider);

  return settings.watchViewerQuickActionOrder();
});
