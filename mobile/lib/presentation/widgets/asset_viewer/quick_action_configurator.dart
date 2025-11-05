import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:immich_mobile/utils/action_button.utils.dart';
import 'package:immich_mobile/utils/action_button_visuals.dart';

class ViewerQuickActionConfigurator extends StatefulWidget {
  final List<ActionButtonType> initialSelection;

  const ViewerQuickActionConfigurator({super.key, required this.initialSelection});

  @override
  State<ViewerQuickActionConfigurator> createState() => _ViewerQuickActionConfiguratorState();
}

class _ViewerQuickActionConfiguratorState extends State<ViewerQuickActionConfigurator> {
  late List<ActionButtonType> _order;

  @override
  void initState() {
    super.initState();
    _order = _mergeWithDefaults(widget.initialSelection);
  }

  List<ActionButtonType> _mergeWithDefaults(List<ActionButtonType> initial) {
    final merged = <ActionButtonType>[];
    final seen = <ActionButtonType>{};

    void add(ActionButtonType type) {
      if (!ActionButtonBuilder.viewerQuickActionOptions.contains(type)) {
        return;
      }
      if (seen.add(type)) {
        merged.add(type);
      }
    }

    for (final type in ActionButtonBuilder.normalizeQuickActionOrder(initial)) {
      add(type);
    }

    for (final type in ActionButtonBuilder.defaultQuickActionOrder) {
      add(type);
    }

    return merged;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  void _resetToDefault() {
    setState(() {
      _order = List<ActionButtonType>.from(ActionButtonBuilder.defaultQuickActionOrder);
    });
  }

  void _cancel() => Navigator.of(context).pop();

  void _save() => Navigator.of(context).pop(_order);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('quick_actions_settings_title'.tr(), style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'quick_actions_settings_description'.tr(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 132,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onReorder: _onReorder,
                itemCount: _order.length,
                itemBuilder: (context, index) {
                  final type = _order[index];
                  final isQuickAction = index < ActionButtonBuilder.defaultQuickActionLimit;
                  return _QuickActionReorderItem(
                    key: ValueKey(type),
                    index: index,
                    type: type,
                    isQuickAction: isQuickAction,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: _resetToDefault, child: const Text('reset').tr()),
                Row(
                  children: [
                    TextButton(onPressed: _cancel, child: const Text('cancel').tr()),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _save, child: const Text('done').tr()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionReorderItem extends StatelessWidget {
  final int index;
  final ActionButtonType type;
  final bool isQuickAction;

  const _QuickActionReorderItem({super.key, required this.index, required this.type, required this.isQuickAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isQuickAction ? theme.colorScheme.primary : theme.dividerColor;
    final backgroundColor = isQuickAction
        ? theme.colorScheme.primary.withOpacity(0.12)
        : theme.colorScheme.surfaceVariant.withOpacity(0.2);
    final indicatorColor = isQuickAction ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ReorderableDragStartListener(
        index: index,
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            color: backgroundColor,
          ),
          child: Stack(
            children: [
              Positioned(top: 0, right: 0, child: Icon(Icons.drag_indicator_rounded, size: 18, color: indicatorColor)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: indicatorColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: indicatorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(type.iconData, size: 28, color: theme.colorScheme.onSurface),
                    const SizedBox(height: 8),
                    Text(
                      type.localizedLabel(context),
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
