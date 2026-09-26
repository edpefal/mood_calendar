import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../../domain/entities/mood_offer.dart';
import '../../domain/entities/mood_pack.dart';
import '../bloc/purchases_cubit.dart';
import '../widgets/mood_purchase_sheet.dart';
import '../widgets/pack_purchase_sheet.dart';

class MoodStoreScreen extends StatelessWidget {
  const MoodStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.storeTitle)),
      body: BlocConsumer<PurchasesCubit, PurchasesState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == PurchaseActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.restoreSuccessMessage)),
            );
            context.read<PurchasesCubit>().acknowledgeActionStatus();
          }
        },
        builder: (context, state) {
          if (state.isLoadingCatalog && state.offers.isEmpty && state.packs.isEmpty) {
            return Center(child: Text(strings.storeLoading));
          }
          if (state.catalogError != null && state.offers.isEmpty && state.packs.isEmpty) {
            return Center(child: Text(strings.storeLoadError));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<PurchasesCubit>().loadCatalog(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  strings.storeMoodsSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.offers.isEmpty)
                  Text(strings.storeEmptyMoods)
                else
                  ...state.offers.map(
                    (offer) => _MoodOfferTile(
                      offer: offer,
                      isUnlocked: state.isMoodUnlocked(offer.moodId),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  strings.storePacksSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.packs.isEmpty)
                  Text(strings.storeEmptyPacks)
                else
                  ...state.packs.map(
                    (pack) => _MoodPackTile(
                      pack: pack,
                      isUnlocked: pack.moodIds.isNotEmpty &&
                          pack.moodIds.every(state.isMoodUnlocked),
                    ),
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: state.actionStatus == PurchaseActionStatus.inProgress
                      ? null
                      : () => context.read<PurchasesCubit>().restorePurchases(),
                  child: Text(
                    state.actionStatus == PurchaseActionStatus.inProgress
                        ? strings.restoringPurchases
                        : strings.restorePurchasesButtonLabel,
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

class _MoodOfferTile extends StatelessWidget {
  final MoodOffer offer;
  final bool isUnlocked;

  const _MoodOfferTile({required this.offer, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final mood = MoodDefinitionResolver.byId(offer.moodId);

    return Card(
      child: ListTile(
        leading: SvgPicture.asset(mood.assetPath, height: 40, width: 40),
        title: Text(mood.label),
        trailing: isUnlocked
            ? Chip(label: Text(strings.moodUnlockedLabel))
            : FilledButton(
                onPressed: () =>
                    showMoodPurchaseSheet(context, moodId: offer.moodId),
                child: Text(offer.displayPrice),
              ),
      ),
    );
  }
}

class _MoodPackTile extends StatelessWidget {
  final MoodPack pack;
  final bool isUnlocked;

  const _MoodPackTile({required this.pack, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final moodLabels =
        pack.moodIds.map((id) => MoodDefinitionResolver.byId(id).label).join(', ');

    return Card(
      child: ListTile(
        title: Text(pack.label),
        subtitle: Text(strings.packIncludesMoods(moodLabels)),
        trailing: isUnlocked
            ? Chip(label: Text(strings.moodUnlockedLabel))
            : FilledButton(
                onPressed: () => showPackPurchaseSheet(context, pack: pack),
                child: Text(pack.displayPrice),
              ),
      ),
    );
  }
}
