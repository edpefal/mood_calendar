import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_pack.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/purchases/presentation/screens/mood_store_screen.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

// Título tal como lo devuelve Google Play mientras la app no está revisada.
const _confianza = MoodPack(
  id: 'confianza',
  label: 'Confidence Pack (com.artlab.moodcalendar (unreviewed))',
  moodIds: ['brave', 'confident', 'romantic'],
  displayPrice: r'$1.99',
  productId: 'pack_confianza_unlock',
);

const _anxious = MoodOffer(
  moodId: 'anxious',
  displayPrice: r'$0.99',
  productId: 'mood_anxious_unlock',
);

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));

  Widget buildApp(
    FakeMoodEntitlementsRepository repository, {
    ValueNotifier<bool>? isActive,
    Key? screenKey,
    Locale locale = const Locale('en'),
  }) {
    return BlocProvider(
      create: (_) => PurchasesCubit(repository),
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: isActive == null
            ? MoodStoreScreen(key: screenKey, isActive: false)
            : ValueListenableBuilder<bool>(
                valueListenable: isActive,
                builder: (_, active, __) =>
                    MoodStoreScreen(key: screenKey, isActive: active),
              ),
      ),
    );
  }

  Finder retryButton() => find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == strings.storeRetry,
      );

  testWidgets('shows a retry button next to the load error', (tester) async {
    await tester.pumpWidget(
      buildApp(FakeMoodEntitlementsRepository(failCatalogLoads: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text(strings.storeLoadError), findsOneWidget);
    expect(find.text(strings.storeRetry), findsOneWidget);
    expect(retryButton(), findsOneWidget);
  });

  testWidgets('retrying recovers the catalog', (tester) async {
    final repository = FakeMoodEntitlementsRepository(
      offers: const [_anxious],
      failCatalogLoads: 1,
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(strings.storeRetry));
    await tester.pumpAndSettle();

    expect(find.text(strings.storeLoadError), findsNothing);
    expect(find.text(strings.storeRetry), findsNothing);
    expect(find.text(strings.moodName('anxious')), findsOneWidget);
    expect(repository.catalogLoadCount, 2);
  });

  testWidgets('shows the loading state while retrying', (tester) async {
    final repository = FakeMoodEntitlementsRepository(
      offers: const [_anxious],
      failCatalogLoads: 1,
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    expect(find.text(strings.storeLoadError), findsOneWidget);

    final gate = Completer<void>();
    repository.holdCatalogLoads = gate.future;
    await tester.tap(find.text(strings.storeRetry));
    await tester.pump();

    expect(find.text(strings.storeLoading), findsOneWidget);
    expect(find.text(strings.storeRetry), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text(strings.storeLoading), findsNothing);
    expect(find.text(strings.moodName('anxious')), findsOneWidget);
  });

  testWidgets('a retry that fails again shows the error and the button',
      (tester) async {
    final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 2);
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(strings.storeRetry));
    await tester.pumpAndSettle();

    expect(find.text(strings.storeLoadError), findsOneWidget);
    expect(find.text(strings.storeRetry), findsOneWidget);
    expect(repository.catalogLoadCount, 2);
  });

  testWidgets('becoming active with an error retries once', (tester) async {
    final repository = FakeMoodEntitlementsRepository(
      offers: const [_anxious],
      failCatalogLoads: 1,
    );
    final isActive = ValueNotifier(false);
    await tester.pumpWidget(buildApp(repository, isActive: isActive));
    await tester.pumpAndSettle();
    expect(find.text(strings.storeLoadError), findsOneWidget);
    expect(repository.catalogLoadCount, 1);

    isActive.value = true;
    await tester.pumpAndSettle();

    expect(find.text(strings.moodName('anxious')), findsOneWidget);
    expect(repository.catalogLoadCount, 2);
  });

  testWidgets('a store shown for the first time with a failed catalog retries',
      (tester) async {
    final repository = FakeMoodEntitlementsRepository(
      offers: const [_anxious],
      failCatalogLoads: 1,
    );
    // El cubit pide el catálogo al arrancar la app y falla; la pantalla de la
    // Tienda se construye después, cuando el usuario abre la pestaña.
    await tester.pumpWidget(
      buildApp(repository, screenKey: const ValueKey('hidden')),
    );
    await tester.pumpAndSettle();
    expect(repository.catalogLoadCount, 1);

    await tester.pumpWidget(
      buildApp(
        repository,
        isActive: ValueNotifier(true),
        screenKey: const ValueKey('opened'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(strings.moodName('anxious')), findsOneWidget);
    expect(repository.catalogLoadCount, 2);
  });

  testWidgets('does not reload again once the catalog is loaded',
      (tester) async {
    final repository = FakeMoodEntitlementsRepository(offers: const [_anxious]);
    final isActive = ValueNotifier(false);
    await tester.pumpWidget(buildApp(repository, isActive: isActive));
    await tester.pumpAndSettle();
    expect(repository.catalogLoadCount, 1);

    isActive.value = true;
    await tester.pumpAndSettle();
    isActive.value = false;
    await tester.pumpAndSettle();
    isActive.value = true;
    await tester.pumpAndSettle();

    expect(repository.catalogLoadCount, 1);
    expect(find.text(strings.moodName('anxious')), findsOneWidget);
  });
  group('pack titles', () {
    testWidgets('come from the app strings, not from the store product',
        (tester) async {
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(
          offers: const [_anxious],
          packs: const [_confianza],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Confidence Pack'), findsOneWidget);
      expect(find.textContaining('unreviewed'), findsNothing);
    });

    testWidgets('follow the device language', (tester) async {
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(
          offers: const [_anxious],
          packs: const [_confianza],
        ),
        locale: const Locale('es'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pack de Confianza'), findsOneWidget);
      expect(find.text('Confidence Pack'), findsNothing);
    });

    testWidgets('a pack without its own string keeps the store title',
        (tester) async {
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(
          offers: const [_anxious],
          packs: const [
            MoodPack(
              id: 'nuevo',
              label: 'Pack Nuevo',
              moodIds: ['shy'],
              displayPrice: r'$1.99',
              productId: 'pack_nuevo_unlock',
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pack Nuevo'), findsOneWidget);
    });

    testWidgets('the purchase sheet shows the app title too', (tester) async {
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(
          offers: const [_anxious],
          packs: const [_confianza],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(r'$1.99'));
      await tester.pumpAndSettle();

      // Tile + sheet title.
      expect(find.text('Confidence Pack'), findsNWidgets(2));
      expect(find.textContaining('unreviewed'), findsNothing);
    });
  });
}
