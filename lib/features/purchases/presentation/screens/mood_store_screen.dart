import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF5F3DC4)),
        title: Text(
          strings.storeTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF5F3DC4),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  strings.storeMoodsSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5F3DC4),
                    side: const BorderSide(color: Color(0xFF5F3DC4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: SvgPicture.asset(mood.assetPath, height: 40, width: 40),
        title: Text(mood.label),
        trailing: isUnlocked
            ? Chip(label: Text(strings.moodUnlockedLabel))
            : SizedBox(
                width: 120,
                height: 40,
                child: GradientPillButton(
                  label: offer.displayPrice,
                  onPressed: () =>
                      showMoodPurchaseSheet(context, moodId: offer.moodId),
                  minHeight: 40,
                  fontSize: 14,
                ),
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
    final packMoods =
        pack.moodIds.map(MoodDefinitionResolver.byId).toList(growable: false);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(pack.label),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final mood in packMoods)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      mood.assetPath,
                      height: 20,
                      width: 20,
                      semanticsLabel: mood.label,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.mood, size: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mood.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
        ),
        trailing: isUnlocked
            ? Chip(label: Text(strings.moodUnlockedLabel))
            : SizedBox(
                width: 120,
                height: 40,
                child: GradientPillButton(
                  label: pack.displayPrice,
                  onPressed: () => showPackPurchaseSheet(context, pack: pack),
                  minHeight: 40,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
