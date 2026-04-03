---
date: 2026-04-02
topic: mood-purchases
status: completed
origin: docs/brainstorms/2026-04-02-mood-purchases-requirements.md
---

# Mood Purchases Implementation Plan

## Problem Frame
Add permanent in-app-purchase unlocks for five paid moods in Mood Calendar
without introducing a backend, while preserving the current free mood flow and
making unlocked moods behave identically to free moods everywhere in the app.

This plan implements the product decisions captured in
`docs/brainstorms/2026-04-02-mood-purchases-requirements.md`: standalone paid
moods are the primary v1 offer, locked moods appear in the existing picker, and
restore is store-account-based only (see origin:
`docs/brainstorms/2026-04-02-mood-purchases-requirements.md`).

## Planning Context
The current app is a small Flutter app with a single feature area under
`lib/features/mood/`, local persistence via Hive, and state management via
Cubit. The picker catalog is hardcoded today inside
`lib/features/mood/presentation/screens/mood_screen.dart`, and stored entries
persist only `mood` as a string asset path plus `intensity`. That means the
implementation should avoid a data migration if possible by evolving the app
from a hardcoded `const List<MoodOption>` to a data-driven catalog keyed by
stable mood identifiers or asset paths.

This is a payment flow, so platform purchase lifecycle requirements matter even
without a backend. The official Flutter `in_app_purchase` package expects app
startup subscription to the purchase stream and requires `completePurchase()`
after delivering verified content. Google Play Billing requires granting access
only when the purchase is `PURCHASED`, not `PENDING`, and acknowledging after
that state. Apple requires a restore path for previously purchased
non-consumables.

## Scope Boundaries
- Include only standalone paid moods in the first-release UI.
- Support pack definitions in the internal catalog model, but do not build a
  dedicated store screen yet.
- Do not add subscriptions, consumables, or an app-managed account system.
- Do not add remote config, a backend receipt-validation service, or analytics
  infrastructure in this phase.

## Requirements Trace
- R1-R6: Preserve free moods, add standalone paid moods, and keep pack support
  internal-only for now.
- R7-R10: Show locked moods in the existing picker and unlock immediately after
  successful purchase.
- R11: Provide restore purchases without a backend.
- R12-R15: Purchased moods must behave exactly like free moods in entry,
  calendar, summary, and history flows.

## Technical Approach

### 1. Introduce a Catalog + Entitlement Layer
Replace the hardcoded picker list with a domain-level catalog describing:
- free moods
- paid standalone moods
- future pack membership metadata
- display properties needed by the UI and summaries

Persist ownership locally in a dedicated Hive box as an entitlement cache so
the app can start cleanly offline after a successful purchase or restore. Treat
the cache as a local snapshot of store-owned non-consumables, not as an
independent source of truth.

Decision:
- Use a dedicated premium/catalog feature area rather than expanding
  `MoodEntry`, because purchase state is catalog metadata, not entry data.

Rationale:
- Entries already store mood identity and intensity. Purchased/unpurchased is a
  property of the catalog item, not of each saved journal entry.

### 2. Use `in_app_purchase` for Native Store Flows
Use Flutter’s official `in_app_purchase` package for v1 rather than RevenueCat.

Decision:
- Keep the stack dependency-light and backend-free for the first paid release.

Rationale:
- The app has a narrow set of permanent non-consumables and no account system.
  The extra abstraction of RevenueCat is not needed yet, while `in_app_purchase`
  maps directly onto the current product shape.

### 3. Gate Interaction in the Existing Mood Picker
Keep the current PageView-based picker, but source items from the catalog.
Locked paid moods appear beside free moods. Tapping save with a selected locked
mood should never silently fail; the UI should route the user into the purchase
sheet first, then make the newly purchased mood selectable immediately.

Decision:
- Preserve picker-first discovery and keep the purchase entry point local to
  mood selection rather than adding a separate storefront.

Rationale:
- This matches the origin requirements and minimizes UI churn in a small app.

### 4. Make Purchased Moods First-Class Across Read Paths
Calendar, monthly summaries, and existing history-like views should render
entries for paid moods exactly like free moods. The implementation should stop
deriving display semantics from the hardcoded five-item list in
`mood_screen.dart` and instead centralize mood metadata so all read paths can
resolve a mood consistently.

Decision:
- Introduce a shared mood-definition resolver used by both creation UI and
  read-only summaries.

Rationale:
- The current code already has drift risk: intensity fallback logic is embedded
  in `MoodRepositoryImpl`, while display colors and assets are duplicated in
  screen code.

## Implementation Units

### Unit 1: Catalog and Entitlement Domain
Files:
- `lib/features/premium/domain/entities/purchasable_mood.dart`
- `lib/features/premium/domain/entities/mood_pack.dart`
- `lib/features/premium/domain/entities/mood_entitlement.dart`
- `lib/features/premium/domain/repositories/premium_repository.dart`
- `lib/features/premium/domain/usecases/get_available_moods_usecase.dart`
- `lib/features/premium/domain/usecases/buy_mood_usecase.dart`
- `lib/features/premium/domain/usecases/restore_purchases_usecase.dart`

Responsibilities:
- Represent the five launch paid moods plus the existing free moods.
- Model standalone mood products and optional future pack membership.
- Expose purchased/unpurchased state separately from stored mood entries.

Test files:
- `test/features/premium/domain/usecases/get_available_moods_usecase_test.dart`
- `test/features/premium/domain/usecases/buy_mood_usecase_test.dart`

Test scenarios:
- Free moods are always returned as available.
- Launch paid moods appear with locked state before entitlement is granted.
- A successful purchase marks only the targeted mood as unlocked.
- Pack metadata can exist without changing the standalone-first UI behavior.

### Unit 2: Purchase and Local Cache Infrastructure
Files:
- `lib/features/premium/data/models/mood_entitlement_model.dart`
- `lib/features/premium/data/datasources/premium_local_datasource.dart`
- `lib/features/premium/data/datasources/premium_purchase_datasource.dart`
- `lib/features/premium/data/repositories/premium_repository_impl.dart`
- `lib/features/premium/presentation/services/purchase_listener_service.dart`
- `lib/main.dart`
- `pubspec.yaml`

Responsibilities:
- Add `in_app_purchase` and initialize purchase listening at app startup.
- Query store products for the five standalone mood SKUs.
- Handle purchase updates, pending/completed/error states, and restore flows.
- Persist owned mood IDs locally in Hive after successful delivery.
- Ensure `completePurchase()` is called only after local entitlement delivery is done.

Test files:
- `test/features/premium/data/repositories/premium_repository_impl_test.dart`
- `test/features/premium/presentation/services/purchase_listener_service_test.dart`

Test scenarios:
- Startup attaches exactly one listener to the purchase stream.
- `PURCHASED` updates unlock moods and finish the transaction.
- `PENDING` updates do not unlock moods.
- Restore repopulates local entitlements from store-owned products.
- Repository tolerates offline startup by using the last known entitlement cache.

### Unit 3: Shared Mood Definition Resolution
Files:
- `lib/features/mood/domain/entities/mood_definition.dart`
- `lib/features/mood/domain/services/mood_definition_resolver.dart`
- `lib/features/mood/data/repositories/mood_repository_impl.dart`
- `lib/features/mood/presentation/screens/mood_screen.dart`
- `lib/features/mood/presentation/screens/calendar_screen.dart`
- `lib/features/mood/presentation/widgets/monthly_mood_summary_card.dart`

Responsibilities:
- Move visual and behavioral metadata for moods out of the screen-level
  `const List<MoodOption>`.
- Resolve mood labels, colors, asset paths, and intensities from one shared map.
- Preserve rendering for legacy free moods while enabling the new paid moods to
  appear in summaries and calendar entries.

Test files:
- `test/features/mood/domain/services/mood_definition_resolver_test.dart`
- `test/features/mood/data/repositories/mood_repository_impl_test.dart`

Test scenarios:
- Existing saved free moods still resolve correctly after the catalog refactor.
- New paid moods resolve to the correct display metadata after unlock.
- Legacy intensity fallback still behaves for the original five moods.
- Read paths do not crash when resolving a known paid mood from stored entries.

### Unit 4: Picker and Purchase UX
Files:
- `lib/features/premium/presentation/bloc/premium_cubit.dart`
- `lib/features/premium/presentation/bloc/premium_state.dart`
- `lib/features/premium/presentation/widgets/locked_mood_purchase_sheet.dart`
- `lib/features/mood/presentation/screens/mood_screen.dart`

Responsibilities:
- Provide UI state for available moods, locked moods, loading, restore, and
  purchase errors.
- Show locked paid moods in the existing picker.
- Open a purchase sheet when the user interacts with a locked mood.
- Refresh the picker state immediately after purchase or restore.

Test files:
- `test/features/premium/presentation/bloc/premium_cubit_test.dart`
- `test/features/mood/presentation/screens/mood_screen_test.dart`

Test scenarios:
- Locked moods render visually distinct from free moods.
- Tapping a locked mood opens the purchase sheet for that mood.
- Successful purchase updates the picker to unlocked state without app restart.
- Save flow remains unchanged for free moods and already-owned paid moods.
- Note entry remains available and unchanged once a mood is unlocked.

### Unit 5: Restore Entry Point and Release Readiness
Files:
- `lib/features/mood/presentation/screens/mood_screen.dart`
- `lib/features/mood/presentation/screens/calendar_screen.dart`
- `README.md`
- `test/widget_test.dart`

Responsibilities:
- Add a visible restore action in an appropriate existing screen location.
- Replace the default placeholder widget test with app-relevant coverage.
- Document required store product IDs, sandbox testing, and restore behavior.

Test files:
- `test/features/premium/presentation/widgets/restore_purchases_test.dart`

Test scenarios:
- Restore action is visible and callable without a separate storefront.
- Restore success and failure states are surfaced to the user.
- Base free experience still loads without store availability.

## File and Dependency Notes
- `lib/features/mood/presentation/screens/mood_screen.dart` is currently both
  the picker UI and the source of the mood catalog. It should stop owning the
  canonical mood definitions.
- `lib/features/mood/data/repositories/mood_repository_impl.dart` currently
  hardcodes legacy intensity fallback for only the original five moods. Extend
  this carefully so the new paid moods do not force a brittle chain of
  conditionals.
- `lib/main.dart` already centralizes app bootstrap. Add premium initialization
  there, next to Hive setup and existing Cubit wiring.
- `android/app/build.gradle` already uses `compileSdk 34` and `minSdk 21`,
  which is compatible with current Play Billing integrations via Flutter
  plugins.
- `ios/Podfile` does not currently pin a platform version. During execution,
  confirm the minimum iOS deployment target required by the selected
  `in_app_purchase` plugin version and raise it if needed.

## Sequencing
1. Build the catalog and entitlement domain so UI and repository work can
   target stable types instead of hardcoded constants.
2. Add purchase infrastructure and startup listening so entitlements can be
   delivered and restored.
3. Refactor mood metadata resolution out of the picker and into shared logic.
4. Update the picker UI and purchase sheet flow.
5. Add restore affordance, documentation, and final test coverage.

## Risks and Mitigations
- Store-state drift between device cache and platform account.
  Mitigation: treat cache as a startup convenience and expose restore clearly.
- Purchase flow complexity in a repo with minimal tests.
  Mitigation: add repository and widget coverage before changing the picker UX
  too broadly.
- Hardcoded mood metadata spread across screens and repository logic.
  Mitigation: centralize mood-definition resolution before introducing paid
  moods.
- Pack support accidentally leaking into v1 UI scope.
  Mitigation: keep pack metadata internal and do not add store-surface entry
  points in this phase.

## External References
- Flutter `in_app_purchase` package docs:
  https://pub.dev/packages/in_app_purchase
- Google Play Billing integration guidance:
  https://developer.android.com/google/play/billing/integrate
- Apple StoreKit original API for in-app purchase:
  https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase

## Open Questions Deferred to Execution
- Exact product IDs for the five standalone moods and any hidden pack SKUs.
- Final placement and copy for the restore action within the existing screens.
- Whether mood intensities for paid moods should remain a fixed ordinal scale or
  move to a catalog-owned semantic mapping for all moods.
