import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../../domain/entities/subscription_plan.dart';
import '../bloc/purchases_cubit.dart';
import 'premium_links.dart';

/// Length of the free trial the annual plan offers.
const Duration premiumTrialLength = Duration(days: 3);

/// Contents of the subscription sheet: title, three benefits, the mood that
/// was tapped (if any), the plan cards, the button and the legal text.
class PremiumPlansView extends StatefulWidget {
  const PremiumPlansView({
    super.key,
    this.mood,
    this.bottomPadding = 24,
    this.closeOnSuccess = false,
    this.openUrl = openInExternalBrowser,
    this.clock,
  });

  /// The locked mood that opened the sheet, shown as context. `null` when the
  /// sheet comes from Settings.
  final MoodDefinition? mood;
  final double bottomPadding;

  /// Closes the sheet when a purchase finishes well.
  final bool closeOnSuccess;
  final PremiumUrlOpener openUrl;

  /// Current time, for the date of the first charge after the trial.
  final DateTime Function()? clock;

  @override
  State<PremiumPlansView> createState() => _PremiumPlansViewState();
}

class _PremiumPlansViewState extends State<PremiumPlansView> {
  @override
  void initState() {
    super.initState();
    // Opening the sheet with the plans in error retries once; when they are
    // already loaded they are kept.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<PurchasesCubit>();
      final state = cubit.state;
      if (state.plans.isEmpty && !state.isLoadingCatalog) {
        unawaited(cubit.loadCatalog());
      }
    });
  }

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
        if (widget.closeOnSuccess &&
            state.actionStatus == PurchaseActionStatus.success) {
          Navigator.of(context).maybePop();
        }
        context.read<PurchasesCubit>().acknowledgeActionStatus();
      },
      builder: (context, state) {
        final palette = BrandPalette.of(context);
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(20, 4, 20, widget.bottomPadding),
          children: [
            Text(
              strings.paywallTitle,
              style: const TextStyle(
                fontSize: 26,
                height: 32 / 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.mood != null) ...[
              const SizedBox(height: 12),
              _MoodCapsule(mood: widget.mood!),
            ],
            const SizedBox(height: 16),
            _Benefit(
              icon: Icons.bar_chart_rounded,
              tone: MoodTone.peaceful,
              text: strings.paywallBenefitInsights,
            ),
            _Benefit(
              icon: Icons.fingerprint_rounded,
              tone: MoodTone.hard,
              text: strings.paywallBenefitNotes,
            ),
            _Benefit(
              icon: Icons.emoji_emotions_outlined,
              tone: MoodTone.positive,
              text: strings.paywallBenefitMoods(
                strings.moodName('laughing'),
                strings.moodName('confident'),
                strings.moodName('brave'),
              ),
            ),
            const SizedBox(height: 16),
            ..._body(context, strings, state, palette),
            const SizedBox(height: 4),
            _RestoreButton(
              inProgress: state.actionStatus == PurchaseActionStatus.inProgress,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppStrings strings,
    PurchasesState state,
    BrandPalette palette,
  ) {
    if (state.isLoadingCatalog && state.plans.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: palette.ink),
                const SizedBox(height: 12),
                Text(strings.storeLoading),
              ],
            ),
          ),
        ),
      ];
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
    // The trial belongs to the annual plan only, and only when the store
    // confirms the user can still use it.
    final showTrial = selected.type == SubscriptionPlanType.annual &&
        selected.isTrialEligible;
    final firstCharge =
        (widget.clock ?? DateTime.now)().add(premiumTrialLength);

    return [
      for (final plan in state.plans) ...[
        _PlanCard(
          plan: plan,
          isSelected: plan.type == selected.type,
          savingsPercent:
              plan.type == SubscriptionPlanType.annual ? savings : null,
          showTrialTag:
              plan.type == SubscriptionPlanType.annual && plan.isTrialEligible,
          onTap: () => context.read<PurchasesCubit>().selectPlan(plan.type),
        ),
        const SizedBox(height: 10),
      ],
      if (showTrial) ...[
        _TrialTimeline(
          firstChargeDate: strings.formatFullDate(firstCharge),
          price: selected.displayPrice,
        ),
        const SizedBox(height: 12),
      ],
      GradientPillButton(
        label: showTrial
            ? strings.startTrialButtonLabel
            : strings.subscribeButtonLabel(selected.displayPrice),
        loading: isPurchasing,
        onPressed: isPurchasing
            ? null
            : () => context.read<PurchasesCubit>().purchaseSelectedPlan(),
      ),
      const SizedBox(height: 12),
      Text(
        showTrial
            ? strings.subscriptionLegalTrial(selected.displayPrice, unit, store)
            : strings.subscriptionLegalPaid(selected.displayPrice, unit, store),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BrandPalette.of(context).textSecondary,
            ),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () => widget.openUrl(legalPageUrl(context, 'terms')),
            child: Text(strings.termsLinkLabel),
          ),
          TextButton(
            onPressed: () => widget.openUrl(legalPageUrl(context, 'privacy')),
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

class _MoodCapsule extends StatelessWidget {
  const _MoodCapsule({required this.mood});

  final MoodDefinition mood;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final tint = MoodDefinitionResolver.tintFor(context, mood);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
        decoration: BoxDecoration(
          color: tint.fill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(mood.assetPath, width: 28, height: 28),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                strings.moodName(mood.id),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: palette.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.tone,
    required this.text,
  });

  final IconData icon;
  final MoodTone tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final tint = palette.tint(tone);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.fill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: tint.ring),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 22 / 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.showTrialTag,
    this.savingsPercent,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final bool showTrialTag;
  final int? savingsPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final label = _planLabel(strings, plan.type);
    final priceLine = strings.planPriceLine(
      plan.displayPrice,
      _unitLabel(strings, plan.type),
    );
    final isBest = plan.type == SubscriptionPlanType.annual;

    return Semantics(
      button: true,
      selected: isSelected,
      label: strings.planCardSemanticLabel(label, priceLine),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? palette.ink : palette.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? palette.ink : palette.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isBest)
                          _Tag(
                            text: savingsPercent == null
                                ? strings.bestValueLabel
                                : '${strings.bestValueLabel} · '
                                    '${strings.savePercentLabel(savingsPercent!)}',
                          ),
                        if (showTrialTag && isSelected)
                          _Tag(text: strings.trialFreeLabel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceLine,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w600,
                      ),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w600,
          color: palette.onInk,
        ),
      ),
    );
  }
}

/// "Today · Full Premium access" and the date of the first charge. It makes
/// no promise of a reminder before the trial ends.
class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline({required this.firstChargeDate, required this.price});

  final String firstChargeDate;
  final String price;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineLine(
            icon: Icons.lock_open_rounded,
            text: strings.trialTimelineToday,
            color: palette.text,
          ),
          const SizedBox(height: 8),
          _TimelineLine(
            icon: Icons.event_outlined,
            text: strings.trialTimelineCharge(firstChargeDate, price),
            color: palette.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, height: 20 / 14, color: color),
          ),
        ),
      ],
    );
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.inProgress});

  final bool inProgress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: palette.text,
          minimumSize: const Size(44, 44),
        ),
        onPressed: inProgress
            ? null
            : () => context.read<PurchasesCubit>().restorePurchases(),
        child: Text(
          inProgress
              ? strings.restoringPurchases
              : strings.restorePurchasesButtonLabel,
        ),
      ),
    );
  }
}
