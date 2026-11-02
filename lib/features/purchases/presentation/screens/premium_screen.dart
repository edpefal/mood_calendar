import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/purchases_cubit.dart';
import '../widgets/premium_links.dart';
import '../widgets/premium_plans_view.dart';

/// Tercera pestaña del bottom bar: la suscripción Premium.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({
    super.key,
    this.isActive = true,
    this.openUrl = openInExternalBrowser,
  });

  /// Si la pestaña es la visible. Al activarse con los planes en error se
  /// reintenta la carga una vez.
  final bool isActive;
  final PremiumUrlOpener openUrl;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _retryIfFailed());
    }
  }

  @override
  void didUpdateWidget(PremiumScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _retryIfFailed();
    }
  }

  void _retryIfFailed() {
    if (!mounted) {
      return;
    }
    final cubit = context.read<PurchasesCubit>();
    if (cubit.state.catalogError != null && !cubit.state.isLoadingCatalog) {
      cubit.loadCatalog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF5F3DC4)),
        title: Text(
          strings.premiumTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF5F3DC4),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PurchasesCubit>().loadCatalog(),
        child: PremiumPlansView(
          bottomPadding: 32 + MediaQuery.paddingOf(context).bottom,
          openUrl: widget.openUrl,
        ),
      ),
    );
  }
}
