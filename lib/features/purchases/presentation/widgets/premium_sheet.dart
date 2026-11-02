import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/purchases_cubit.dart';
import 'premium_links.dart';
import 'premium_plans_view.dart';

/// Abre la suscripción Premium como hoja, cubriendo el bottom bar. La usan los
/// moods bloqueados del selector; nunca se abre sin que el usuario lo pida.
Future<void> showPremiumSheet(
  BuildContext context, {
  PremiumSource source = PremiumSource.lockedMood,
  PremiumUrlOpener openUrl = openInExternalBrowser,
}) {
  final cubit = context.read<PurchasesCubit>();
  cubit.trackPremiumOpened(source);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: AppStrings.of(sheetContext).closeLabel,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ),
          Flexible(
            child: PremiumPlansView(
              bottomPadding: 24,
              closeOnSuccess: true,
              openUrl: openUrl,
            ),
          ),
        ],
      ),
    ),
  );
}
