import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../../domain/entities/mood_pack.dart';
import '../bloc/purchases_cubit.dart';

Future<void> showPackPurchaseSheet(
  BuildContext context, {
  required MoodPack pack,
}) {
  final cubit = context.read<PurchasesCubit>();
  final overlappingMoodIds = cubit.overlappingMoodIdsForPack(pack.id);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _PackPurchaseSheetContent(
        pack: pack,
        overlappingMoodIds: overlappingMoodIds,
      ),
    ),
  );
}

class _PackPurchaseSheetContent extends StatelessWidget {
  final MoodPack pack;
  final List<String> overlappingMoodIds;

  const _PackPurchaseSheetContent({
    required this.pack,
    required this.overlappingMoodIds,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

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
        final isPurchasing = state.actionStatus == PurchaseActionStatus.inProgress;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(pack.label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(strings.packIncludesMoods(_moodLabels(pack.moodIds))),
                if (overlappingMoodIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.packOverlapWarningTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.packOverlapWarningMessage(
                            _moodLabels(overlappingMoodIds),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isPurchasing
                      ? null
                      : () => context.read<PurchasesCubit>().purchasePack(pack.id),
                  child: isPurchasing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          strings.buyPackButtonLabel(pack.label, pack.displayPrice),
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

  String _moodLabels(List<String> moodIds) => moodIds
      .map((id) => MoodDefinitionResolver.byId(id).label)
      .join(', ');

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
