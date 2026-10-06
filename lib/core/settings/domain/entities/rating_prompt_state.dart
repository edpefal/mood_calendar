class RatingPromptState {
  const RatingPromptState({
    required this.attempts,
    required this.lastAttemptAt,
  });

  final int attempts;
  final DateTime? lastAttemptAt;
}
