import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../domain/repositories/premium_repository.dart';
import 'premium_state.dart';

class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit({required PremiumRepository repository})
      : _repository = repository,
        super(
          PremiumState(
            ownedMoodIds: repository.currentSnapshot.ownedMoodIds,
            productsByMoodId: repository.currentSnapshot.productsByMoodId,
            isStoreAvailable: repository.currentSnapshot.isStoreAvailable,
            isLoading: repository.currentSnapshot.isLoading,
            errorMessage: repository.currentSnapshot.errorMessage,
          ),
        ) {
    unawaited(_repository.initialize());
    _subscription = _repository.watchSnapshot().listen((snapshot) {
      emit(
        state.copyWith(
          ownedMoodIds: snapshot.ownedMoodIds,
          productsByMoodId: snapshot.productsByMoodId,
          isStoreAvailable: snapshot.isStoreAvailable,
          isLoading: snapshot.isLoading,
          errorMessage: snapshot.errorMessage,
        ),
      );
    });
  }

  final PremiumRepository _repository;
  StreamSubscription? _subscription;

  Future<void> buyMood(String moodId) => _repository.buyMood(moodId);

  Future<void> restorePurchases() => _repository.restorePurchases();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
