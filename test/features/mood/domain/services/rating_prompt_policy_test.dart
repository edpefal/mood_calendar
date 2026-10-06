import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/services/rating_prompt_policy.dart';

void main() {
  final now = DateTime(2026, 10, 5, 12);

  bool decide({
    required int days,
    required int attempts,
    DateTime? lastAttemptAt,
  }) {
    return RatingPromptPolicy.shouldRequest(
      totalEntryDays: days,
      attempts: attempts,
      lastAttemptAt: lastAttemptAt,
      now: now,
    );
  }

  group('RatingPromptPolicy.shouldRequest', () {
    group('first attempt', () {
      test('does not request with fewer than 3 entry days', () {
        expect(decide(days: 0, attempts: 0), isFalse);
        expect(decide(days: 2, attempts: 0), isFalse);
      });

      test('requests on the 3rd entry day', () {
        expect(decide(days: 3, attempts: 0), isTrue);
      });

      test('still requests when the total is already past the milestone', () {
        expect(decide(days: 40, attempts: 0), isTrue);
      });
    });

    group('second attempt', () {
      test('requests with 7+ days and 30+ days since the first attempt', () {
        expect(
          decide(
            days: 7,
            attempts: 1,
            lastAttemptAt: now.subtract(const Duration(days: 31)),
          ),
          isTrue,
        );
      });

      test('requests exactly 30 days after the first attempt', () {
        expect(
          decide(
            days: 7,
            attempts: 1,
            lastAttemptAt: now.subtract(const Duration(days: 30)),
          ),
          isTrue,
        );
      });

      test('does not request 29 days after the first attempt', () {
        expect(
          decide(
            days: 20,
            attempts: 1,
            lastAttemptAt: now.subtract(const Duration(days: 29)),
          ),
          isFalse,
        );
      });

      test('does not request below 7 entry days even after 30 days', () {
        expect(
          decide(
            days: 6,
            attempts: 1,
            lastAttemptAt: now.subtract(const Duration(days: 60)),
          ),
          isFalse,
        );
      });

      test('does not request when the first attempt date is missing', () {
        expect(decide(days: 10, attempts: 1), isFalse);
      });

      test('does not request when the clock moved before the last attempt', () {
        expect(
          decide(
            days: 10,
            attempts: 1,
            lastAttemptAt: now.add(const Duration(days: 5)),
          ),
          isFalse,
        );
      });
    });

    test('never requests after 2 attempts', () {
      expect(
        decide(
          days: 500,
          attempts: 2,
          lastAttemptAt: now.subtract(const Duration(days: 400)),
        ),
        isFalse,
      );
    });

    test('does not request again at 3 days once the first attempt was made', () {
      expect(
        decide(
          days: 3,
          attempts: 1,
          lastAttemptAt: now.subtract(const Duration(days: 40)),
        ),
        isFalse,
      );
    });
  });
}
