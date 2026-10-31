import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';

part 'purchases_state.dart';

/// Desde dónde se abrió la pantalla Premium, para las analíticas (sin ids de
/// moods): la pestaña o el toque en un mood bloqueado.
enum PremiumSource {
  tab('tab'),
  lockedMood('locked_mood');

  const PremiumSource(this.analyticsValue);
  final String analyticsValue;
}

class PurchasesCubit extends Cubit<PurchasesState> {
  final MoodEntitlementsRepository repository;
  final AppTelemetry? telemetry;
  StreamSubscription<Set<String>>? _unlockedSubscription;
  StreamSubscription<SubscriptionStatus>? _statusSubscription;

  PurchasesCubit(this.repository, {this.telemetry})
      : super(const PurchasesState()) {
    _unlockedSubscription = repository.unlockedPremiumMoodIds().listen((ids) {
      emit(state.copyWith(unlockedMoodIds: ids));
    });
    _statusSubscription = repository.subscriptionStatus().listen((status) {
      emit(state.copyWith(subscription: status));
    });
    loadCatalog();
  }

  @override
  Future<void> close() {
    _unlockedSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }

  bool isMoodUnlocked(String moodId) => state.isMoodUnlocked(moodId);

  /// Lectura síncrona del repositorio. A diferencia de [isMoodUnlocked], no
  /// depende de que el stream ya haya emitido al estado, por lo que sirve
  /// justo después de crear el cubit.
  bool isMoodUnlockedNow(String moodId) => repository.isUnlocked(moodId);

  Future<void> loadCatalog() async {
    emit(state.copyWith(isLoadingCatalog: true, catalogError: null));
    try {
      final plans = await repository.availablePlans();
      emit(state.copyWith(plans: plans, isLoadingCatalog: false));
    } catch (e, stackTrace) {
      telemetry?.recordError(
        'load_store_catalog_failed',
        reason: 'get_offerings',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(isLoadingCatalog: false, catalogError: e));
    }
  }

  void selectPlan(SubscriptionPlanType plan) {
    emit(state.copyWith(selectedPlan: plan));
  }

  /// La pantalla Premium se abrió (pestaña u hoja). Sin ids de moods.
  void trackPremiumOpened(PremiumSource source) {
    telemetry?.trackEvent(
      AppTelemetryEvents.storeOpened,
      properties: {'source': source.analyticsValue},
    );
  }

  /// Compra el plan elegido (o el anual por defecto).
  Future<void> purchaseSelectedPlan() {
    final plan = state.effectiveSelectedPlan;
    if (plan == null) {
      return Future.value();
    }
    return purchasePlan(plan.type);
  }

  Future<void> purchasePlan(SubscriptionPlanType plan) => _runPurchaseAction(
        () => repository.purchasePlan(plan),
        plan: plan,
      );

  Future<void> restorePurchases() => _runPurchaseAction(
        () => repository.restorePurchases(),
        isRestore: true,
      );

  // Los eventos de compras nunca llevan el id de un mood. Solo `purchase_started`
  // y `purchase_completed` llevan el plan (semanal, mensual o anual).
  Future<void> _runPurchaseAction(
    Future<void> Function() action, {
    bool isRestore = false,
    SubscriptionPlanType? plan,
  }) async {
    emit(state.copyWith(actionStatus: PurchaseActionStatus.inProgress));
    final planProperties = <String, Object?>{
      if (plan != null) 'plan': plan.name,
    };
    if (!isRestore) {
      telemetry?.trackEvent(
        AppTelemetryEvents.purchaseStarted,
        properties: planProperties,
      );
    }
    try {
      await action();
      if (isRestore) {
        telemetry?.trackEvent(AppTelemetryEvents.purchasesRestored);
      } else {
        telemetry?.trackEvent(
          AppTelemetryEvents.purchaseCompleted,
          properties: planProperties,
        );
      }
      emit(
        state.copyWith(
          actionStatus: isRestore
              ? PurchaseActionStatus.restored
              : PurchaseActionStatus.success,
        ),
      );
    } on PurchaseException catch (e) {
      final status = _statusForReason(e.reason);
      if (!isRestore) {
        telemetry?.trackEvent(
          status == PurchaseActionStatus.cancelled
              ? AppTelemetryEvents.purchaseCancelled
              : AppTelemetryEvents.purchaseFailed,
        );
      }
      emit(state.copyWith(actionStatus: status));
    } catch (_) {
      if (!isRestore) {
        telemetry?.trackEvent(AppTelemetryEvents.purchaseFailed);
      }
      emit(state.copyWith(actionStatus: PurchaseActionStatus.unknownError));
    }
  }

  PurchaseActionStatus _statusForReason(PurchaseFailureReason reason) {
    switch (reason) {
      case PurchaseFailureReason.cancelled:
        return PurchaseActionStatus.cancelled;
      case PurchaseFailureReason.network:
        return PurchaseActionStatus.networkError;
      case PurchaseFailureReason.productUnavailable:
        return PurchaseActionStatus.productUnavailable;
      case PurchaseFailureReason.unknown:
        return PurchaseActionStatus.unknownError;
    }
  }

  void acknowledgeActionStatus() {
    emit(state.copyWith(actionStatus: PurchaseActionStatus.idle));
  }
}
