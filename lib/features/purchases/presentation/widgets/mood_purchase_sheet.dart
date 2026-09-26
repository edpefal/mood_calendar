import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../bloc/purchases_cubit.dart';

Future<void> showMoodPurchaseSheet(
  BuildContext context, {
  required String moodId,
}) {
  final cubit = context.read<PurchasesCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _MoodPurchaseSheetContent(moodId: moodId),
    ),
  );
}

class _MoodPurchaseSheetContent extends StatelessWidget {
  final String moodId;

  const _MoodPurchaseSheetContent({required this.moodId});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final mood = MoodDefinitionResolver.byId(moodId);

    return BlocConsumer<PurchasesCubit, PurchasesState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        final message = _messageFor(strings, state.actionStatus);
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (state.actionStatus == PurchaseActionStatus.success) {
          Navigator.of(context).pop();
        }
        context.read<PurchasesCubit>().acknowledgeActionStatus();
      },
      builder: (context, state) {
        final offer = state.offers.where((o) => o.moodId == moodId).firstOrNull;
        final isPurchasing = state.actionStatus == PurchaseActionStatus.inProgress;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(mood.assetPath, height: 96, width: 96),
                const SizedBox(height: 12),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                if (offer == null)
                  Text(strings.storeEmptyMoods)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isPurchasing
                          ? null
                          : () => context.read<PurchasesCubit>().purchaseMood(moodId),
                      child: isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              strings.buyMoodButtonLabel(
                                mood.label,
                                offer.displayPrice,
                              ),
                            ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancelLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _messageFor(AppStrings strings, PurchaseActionStatus status) {
    switch (status) {
      case PurchaseActionStatus.success:
        return strings.purchaseSuccessMessage;
      case PurchaseActionStatus.cancelled:
        return strings.purchaseCancelledMessage;
      case PurchaseActionStatus.networkError:
        return strings.purchaseNetworkErrorMessage;
      case PurchaseActionStatus.productUnavailable:
        return strings.purchaseProductUnavailableMessage;
      case PurchaseActionStatus.unknownError:
        return strings.purchaseUnknownErrorMessage;
      case PurchaseActionStatus.idle:
      case PurchaseActionStatus.inProgress:
        return null;
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
