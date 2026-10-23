import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_offer.dart';
import '../../domain/entities/mood_pack.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';

part 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final MoodEntitlementsRepository repository;
  final AppTelemetry? telemetry;
  StreamSubscription<Set<String>>? _unlockedSubscription;

  PurchasesCubit(this.repository, {this.telemetry})
      : super(const PurchasesState()) {
    _unlockedSubscription = repository.unlockedPremiumMoodIds().listen((ids) {
      emit(state.copyWith(unlockedMoodIds: ids));
    });
    loadCatalog();
  }

  @override
  Future<void> close() {
    _unlockedSubscription?.cancel();
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
      final offers = await repository.availableMoodOffers();
      final packs = await repository.availablePacks();
      emit(
        state.copyWith(
          offers: offers,
          packs: packs,
          isLoadingCatalog: false,
        ),
      );
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

  /// Moods de [packId] que el usuario ya tiene `unlocked`, para el aviso de
  /// solape antes de confirmar la compra del pack.
  List<String> overlappingMoodIdsForPack(String packId) {
    final pack = state.packs.where((p) => p.id == packId).firstOrNull;
    if (pack == null) {
      return const [];
    }
    return pack.moodIds.where(isMoodUnlocked).toList();
  }

  /// La pestaña de la tienda se abrió. Sin ids de moods ni de Packs.
  void trackStoreOpened() {
    telemetry?.trackEvent(AppTelemetryEvents.storeOpened);
  }

  Future<void> purchaseMood(String moodId) =>
      _runPurchaseAction(() => repository.purchaseMood(moodId));

  Future<void> purchasePack(String packId) =>
      _runPurchaseAction(() => repository.purchasePack(packId));

  Future<void> restorePurchases() => _runPurchaseAction(
        () => repository.restorePurchases(),
        isRestore: true,
      );

  // Los eventos de compras nunca llevan el id del mood ni del Pack.
  Future<void> _runPurchaseAction(
    Future<void> Function() action, {
    bool isRestore = false,
  }) async {
    emit(state.copyWith(actionStatus: PurchaseActionStatus.inProgress));
    if (!isRestore) {
      telemetry?.trackEvent(AppTelemetryEvents.purchaseStarted);
    }
    try {
      await action();
      telemetry?.trackEvent(
        isRestore
            ? AppTelemetryEvents.purchasesRestored
            : AppTelemetryEvents.purchaseCompleted,
      );
      emit(state.copyWith(actionStatus: PurchaseActionStatus.success));
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
