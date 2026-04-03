import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../bloc/premium_cubit.dart';
import '../bloc/premium_state.dart';

class LockedMoodPurchaseSheet extends StatelessWidget {
  const LockedMoodPurchaseSheet({
    super.key,
    required this.mood,
  });

  final MoodDefinition mood;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, state) {
        final product = state.productForMood(mood.id);
        final price = product?.price ?? '\$0.99';

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Unlock ${mood.label}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Buy this mood once and use it everywhere in Mood Calendar.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_open, color: mood.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$price permanent unlock',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            try {
                              await context.read<PremiumCubit>().buyMood(
                                    mood.id,
                                  );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (_) {
                              // The parent listener surfaces errors via snackbar.
                            }
                          },
                    child: Text(
                      state.isLoading ? 'Processing...' : 'Buy ${mood.label}',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context.read<PremiumCubit>().restorePurchases(),
                    child: const Text('Restore purchases'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
