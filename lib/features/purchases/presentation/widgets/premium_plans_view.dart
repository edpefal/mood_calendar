import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';
import '../bloc/purchases_cubit.dart';
import 'premium_links.dart';

const _brand = Color(0xFF5F3DC4);
const _contentMaxWidth = 480.0;

/// Contenido de la suscripción Premium, compartido por la pestaña y por la
/// hoja que se abre al tocar un mood bloqueado.
class PremiumPlansView extends StatelessWidget {
  const PremiumPlansView({
    super.key,
    this.bottomPadding = 32,
    this.closeOnSuccess = false,
    this.openUrl = openInExternalBrowser,
  });

  /// Espacio inferior (en la pestaña, el que reserva el bottom bar).
  final double bottomPadding;

  /// En la hoja, cierra la pantalla cuando la compra termina bien.
  final bool closeOnSuccess;
  final PremiumUrlOpener openUrl;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        if (closeOnSuccess &&
            state.actionStatus == PurchaseActionStatus.success) {
          Navigator.of(context).maybePop();
        }
        context.read<PurchasesCubit>().acknowledgeActionStatus();
      },
      builder: (context, state) {
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: closeOnSuccess ? 1 : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: ListView(
              shrinkWrap: closeOnSuccess,
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              children: [
                Text(
                  strings.premiumHeadline,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(strings.premiumSubheadline),
                const SizedBox(height: 16),
                _MoodShowcase(unlockedMoodIds: state.unlockedMoodIds),
                const SizedBox(height: 16),
                ..._body(context, strings, state),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brand,
                    side: const BorderSide(color: _brand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: state.actionStatus ==
                          PurchaseActionStatus.inProgress
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
          ),
        );
      },
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppStrings strings,
    PurchasesState state,
  ) {
    if (state.subscription.isActive) {
      return [
        _ActiveSubscription(status: state.subscription, openUrl: openUrl)
      ];
    }
    if (state.isLoadingCatalog && state.plans.isEmpty) {
      return [Center(child: Text(strings.storeLoading))];
    }
    if (state.plans.isEmpty) {
      return [
        Text(strings.storeLoadError, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        GradientPillButton(
          label: strings.storeRetry,
          semanticsLabel: strings.storeRetry,
          onPressed: () => context.read<PurchasesCubit>().loadCatalog(),
        ),
        const SizedBox(height: 16),
      ];
    }
    return _plans(context, strings, state);
  }

  List<Widget> _plans(
    BuildContext context,
    AppStrings strings,
    PurchasesState state,
  ) {
    final selected = state.effectiveSelectedPlan!;
    final savings = annualSavingsPercent(state.plans);
    final isPurchasing = state.actionStatus == PurchaseActionStatus.inProgress;
    final unit = _unitLabel(strings, selected.type);
    final store = defaultTargetPlatform == TargetPlatform.android
        ? 'Google Play'
        : 'App Store';

    return [
      for (final plan in state.plans) ...[
        _PlanCard(
          plan: plan,
          isSelected: plan.type == selected.type,
          savingsPercent:
              plan.type == SubscriptionPlanType.annual ? savings : null,
          onTap: () => context.read<PurchasesCubit>().selectPlan(plan.type),
        ),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 6),
      GradientPillButton(
        label: selected.isTrialEligible
            ? strings.startTrialButtonLabel
            : strings.subscribeButtonLabel(selected.displayPrice),
        loading: isPurchasing,
        onPressed: isPurchasing
            ? null
            : () => context.read<PurchasesCubit>().purchaseSelectedPlan(),
      ),
      const SizedBox(height: 12),
      Text(
        selected.isTrialEligible
            ? strings.subscriptionLegalTrial(selected.displayPrice, unit, store)
            : strings.subscriptionLegalPaid(selected.displayPrice, unit, store),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () => openUrl(legalPageUrl(context, 'terms')),
            child: Text(strings.termsLinkLabel),
          ),
          TextButton(
            onPressed: () => openUrl(legalPageUrl(context, 'privacy')),
            child: Text(strings.privacyLinkLabel),
          ),
        ],
      ),
    ];
  }

  String? _messageFor(AppStrings strings, PurchaseActionStatus status) {
    switch (status) {
      case PurchaseActionStatus.success:
        return strings.purchaseSuccessMessage;
      case PurchaseActionStatus.restored:
        return strings.restoreSuccessMessage;
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

String _planLabel(AppStrings strings, SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.weekly:
      return strings.weeklyPlanLabel;
    case SubscriptionPlanType.monthly:
      return strings.monthlyPlanLabel;
    case SubscriptionPlanType.annual:
      return strings.annualPlanLabel;
  }
}

String _unitLabel(AppStrings strings, SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.weekly:
      return strings.weekUnit;
    case SubscriptionPlanType.monthly:
      return strings.monthUnit;
    case SubscriptionPlanType.annual:
      return strings.yearUnit;
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.savingsPercent,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final int? savingsPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final label = _planLabel(strings, plan.type);
    final priceLine = strings.planPriceLine(
        plan.displayPrice, _unitLabel(strings, plan.type));
    final isBest = plan.type == SubscriptionPlanType.annual;

    return Semantics(
      button: true,
      selected: isSelected,
      label: strings.planCardSemanticLabel(label, priceLine),
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _brand : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? _brand : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (isBest)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                savingsPercent == null
                                    ? strings.bestValueLabel
                                    : '${strings.bestValueLabel} · '
                                        '${strings.savePercentLabel(savingsPercent!)}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceLine,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Colores de la máscara del escaparate: el borde donde todavía hay moods por
/// ver se desvanece, para que se note que la fila se desliza. Donde ya no hay
/// más contenido el borde queda opaco.
@visibleForTesting
List<Color> premiumShowcaseFade({
  required bool canScrollLeft,
  required bool canScrollRight,
}) =>
    [
      canScrollLeft ? Colors.transparent : Colors.black,
      Colors.black,
      Colors.black,
      canScrollRight ? Colors.transparent : Colors.black,
    ];

class _MoodShowcase extends StatefulWidget {
  const _MoodShowcase({required this.unlockedMoodIds});

  final Set<String> unlockedMoodIds;

  @override
  State<_MoodShowcase> createState() => _MoodShowcaseState();
}

class _MoodShowcaseState extends State<_MoodShowcase> {
  static const _iconSize = 40.0;
  static const _separator = 4.0;

  /// Cuántas celdas se ven a la vez: tres y media, así la cuarta queda cortada
  /// en el borde y se nota que hay más a la derecha.
  static const _visibleItems = 3.6;

  /// Ancho mínimo de una celda con el texto a tamaño normal; sin él, nombres
  /// largos como "Affectionate" se parten a mitad de palabra.
  static const _minItemWidth = 88.0;

  bool _canScrollLeft = false;

  // Siempre hay más moods de los que caben, así que al empezar se puede
  // deslizar a la derecha.
  bool _canScrollRight = true;

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    final left = metrics.pixels > 1;
    final right = metrics.pixels < metrics.maxScrollExtent - 1;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // La altura y el ancho mínimo siguen al tamaño de texto del sistema.
    final textHeight = MediaQuery.textScalerOf(context).scale(34);
    final minWidth = _minItemWidth * textScale.clamp(1.0, 2.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.premiumMoodsTitle,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final fitted =
                (constraints.maxWidth - _separator * 3) / _visibleItems;
            final itemWidth = fitted < minWidth ? minWidth : fitted;
            return SizedBox(
              height: _iconSize + 8 + textHeight + 8,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: premiumShowcaseFade(
                      canScrollLeft: _canScrollLeft,
                      canScrollRight: _canScrollRight,
                    ),
                    stops: const [0, 0.08, 0.88, 1],
                  ).createShader(bounds),
                  child: ListView.separated(
                    key: const Key('premium-moods-row'),
                    scrollDirection: Axis.horizontal,
                    itemCount: premiumMoodDefinitions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: _separator),
                    itemBuilder: (context, index) => _MoodShowcaseItem(
                      key: Key('premium-mood-$index'),
                      mood: premiumMoodDefinitions[index],
                      width: itemWidth,
                      isUnlocked: widget.unlockedMoodIds
                          .contains(premiumMoodDefinitions[index].id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MoodShowcaseItem extends StatelessWidget {
  const _MoodShowcaseItem({
    super.key,
    required this.mood,
    required this.width,
    required this.isUnlocked,
  });

  final MoodDefinition mood;
  final double width;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                mood.assetPath,
                height: _MoodShowcaseState._iconSize,
                width: _MoodShowcaseState._iconSize,
                semanticsLabel: strings.moodName(mood.id),
              ),
              if (isUnlocked)
                const Positioned(
                  right: -6,
                  bottom: -4,
                  child: Icon(Icons.check_circle, size: 16, color: _brand),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            strings.moodName(mood.id),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActiveSubscription extends StatelessWidget {
  const _ActiveSubscription({required this.status, required this.openUrl});

  final SubscriptionStatus status;
  final PremiumUrlOpener openUrl;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final plan = status.plan;
    final expiresAt = status.expiresAt;
    String? dateLine;
    if (expiresAt != null) {
      final date = strings.formatFullDate(expiresAt);
      dateLine = status.isInTrial
          ? strings.premiumTrialEndsOn(date)
          : status.willRenew
              ? strings.premiumRenewsOn(date)
              : strings.premiumEndsOn(date);
    }
    final managementUrl = status.managementUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.premiumActiveTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (plan != null) ...[
              const SizedBox(height: 4),
              Text(strings.premiumPlanLine(_planLabel(strings, plan))),
            ],
            if (dateLine != null) ...[
              const SizedBox(height: 4),
              Text(dateLine),
            ],
            if (managementUrl != null) ...[
              const SizedBox(height: 16),
              GradientPillButton(
                label: strings.manageSubscriptionButtonLabel,
                onPressed: () => openUrl(Uri.parse(managementUrl)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
