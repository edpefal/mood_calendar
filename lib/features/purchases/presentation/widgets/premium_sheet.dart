import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../bloc/purchases_cubit.dart';
import 'premium_links.dart';
import 'premium_plans_view.dart';

/// Opens the subscription as a sheet that covers the bottom bar. It opens only
/// when the user asks: tapping a locked mood ([mood] is then shown as context)
/// or "Get Premium" in Settings. A user who already subscribed never sees it.
Future<void> showPremiumSheet(
  BuildContext context, {
  PremiumSource source = PremiumSource.lockedMood,
  MoodDefinition? mood,
  PremiumUrlOpener openUrl = openInExternalBrowser,
}) {
  final cubit = context.read<PurchasesCubit>();
  if (cubit.state.subscription.isActive) {
    return Future.value();
  }
  cubit.trackPremiumOpened(source);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final palette = BrandPalette.of(sheetContext);
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: MeshBackground(
          child: BlocProvider.value(
            value: cubit,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: IconButton(
                      tooltip: AppStrings.of(sheetContext).closeLabel,
                      icon: Icon(Icons.close, color: palette.text),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ),
                ),
                Flexible(
                  child: PremiumPlansView(
                    mood: mood,
                    closeOnSuccess: true,
                    openUrl: openUrl,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
