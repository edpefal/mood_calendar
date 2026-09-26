import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_offer.dart';
import '../../domain/entities/mood_pack.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';

part 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final MoodEntitlementsRepository repository;
  StreamSubscription<Set<String>>? _unlockedSubscription;

  PurchasesCubit(this.repository) : super(const PurchasesState()) {
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
    } catch (e) {
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

  Future<void> purchaseMood(String moodId) =>
      _runPurchaseAction(() => repository.purchaseMood(moodId));

  Future<void> purchasePack(String packId) =>
      _runPurchaseAction(() => repository.purchasePack(packId));

  Future<void> restorePurchases() =>
      _runPurchaseAction(() => repository.restorePurchases());

  Future<void> _runPurchaseAction(Future<void> Function() action) async {
    emit(state.copyWith(actionStatus: PurchaseActionStatus.inProgress));
    try {
      await action();
      emit(state.copyWith(actionStatus: PurchaseActionStatus.success));
    } on PurchaseException catch (e) {
      emit(state.copyWith(actionStatus: _statusForReason(e.reason)));
    } catch (_) {
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
