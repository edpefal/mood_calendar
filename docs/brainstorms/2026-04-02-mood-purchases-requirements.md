---
date: 2026-04-02
topic: mood-purchases
---

# Mood Purchases

## Problem Frame
Mood Calendar currently offers a fixed set of moods with no monetization path.
The product opportunity is to sell additional moods without adding a backend,
without weakening the core free experience, and without making paid moods feel
like second-class content.

Because the app is local-first and has no user account system, the first
version should use permanent store-based unlocks that restore through the
platform store account rather than through an app-managed account.

## Requirements

**Catalog and Merchandising**
- R1. The app must keep the existing base mood set free and usable without any purchase.
- R2. The app must support selling additional moods as permanent unlocks.
- R3. The catalog must support both standalone mood purchases and multi-mood packs.
- R4. The first release must launch with a small paid catalog of 3-5 paid moods.
- R4a. The first release catalog must include these five standalone paid moods: Shy, Brave, Confident, Romantic, and Anxious.
- R5. The first release must surface standalone mood purchases in the UI as the primary purchase path.
- R5a. Each standalone paid mood must launch at a price of $0.99, subject to final store-tier mapping per platform.
- R6. Packs may exist in the product catalog for future use, but they are not required to be prominently merchandised in the first release.

**User Experience**
- R7. Locked paid moods must appear in the same mood picker as free moods.
- R8. Tapping a locked mood must open a purchase sheet for that specific mood.
- R9. The first release should prioritize the individual mood offer when a user taps a locked mood, rather than leading with a pack upsell.
- R10. After a successful purchase, the newly unlocked mood must behave like any free mood in the picker.
- R11. The app must provide a restore purchases path so users can recover prior unlocks on reinstall or a new device using the same store account.

**Paid Mood Behavior**
- R12. A purchased mood must be fully integrated into the app, not limited to a cosmetic label or badge.
- R13. Once unlocked, a purchased mood must be selectable when creating or editing a mood entry.
- R14. Once unlocked and used, a purchased mood must appear in calendar rendering, summaries, and history using the same behavioral rules as free moods.
- R15. Paid moods must not degrade or restrict the existing note-taking flow.

## Success Criteria
- Users can discover paid moods directly from the existing picker flow without needing a separate store screen.
- A purchased mood feels native to the app and behaves the same as a free mood across recording and viewing flows.
- The first paid catalog is small enough to ship quickly and validate demand.
- The first release does not require a custom backend or app account system.

## Scope Boundaries
- No subscription model in the first release.
- No consumable purchases in the first release.
- No dedicated store screen in the first release.
- No requirement for packs to be prominently sold in the first release UI.
- No app-managed account-based entitlement system in the first release.

## Key Decisions
- Permanent unlocks only: The product value is ownership of moods, not repeatable consumption.
- Store-account restore only: The first release avoids backend work and accepts store-bound restore behavior.
- Picker-first discovery: Paid moods are discovered where the user already chooses moods.
- Standalone-first merchandising: Individual mood purchase is the primary entry point for the first release.
- Small launch catalog: Validate willingness to pay before expanding the mood catalog.
- Launch catalog: Shy, Brave, Confident, Romantic, and Anxious ship as the first paid moods.
- Launch price: Each standalone mood is priced at $0.99 for the first release.

## Dependencies / Assumptions
- The app already supports iOS and Android distribution and can use the native app-store purchase flows.
- The existing mood model and presentation can be extended to represent locked and unlocked paid moods.
- Store product setup, pricing, and final mood content are handled before release.

## Outstanding Questions

### Resolve Before Planning

### Deferred to Planning
- [Affects R3][Technical] How should pack products be represented internally if packs exist in the catalog but are not prominently surfaced yet?
- [Affects R11][Technical] Where should restored ownership be cached locally so the app starts cleanly offline after a restore?
- [Affects R12][Needs research] What is the simplest product model that lets paid moods participate in summaries and historical views without special-case logic spread across the UI?

## Next Steps
→ `/prompts:ce-plan` for structured implementation planning
