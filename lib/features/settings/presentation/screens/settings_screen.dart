import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/settings/domain/entities/app_theme_preference.dart';
import '../../../../core/settings/domain/repositories/app_settings_repository.dart';
import '../../../../core/telemetry/analytics_reporter.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/phone_column.dart';
import '../../../mood/data/services/rating_prompt_service.dart';
import '../../../mood/domain/usecases/export_mood_history_usecase.dart';
import '../../../purchases/domain/entities/subscription_plan.dart';
import '../../../purchases/domain/entities/subscription_status.dart';
import '../../../purchases/presentation/bloc/purchases_cubit.dart';
import '../../../purchases/presentation/widgets/premium_links.dart';
import '../../../purchases/presentation/widgets/premium_sheet.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

const privacyPolicyUrl = 'https://moodcalendar.app/privacy/';
const feedbackEmail = 'support@moodcalendar.app';

/// Opens [url] outside the app; returns whether it could be opened.
typedef UrlOpener = Future<bool> Function(Uri url);

/// Opens the system share sheet with the file at [filePath]. [origin] is where
/// the sheet is anchored; iPad shows it as a popover and needs it.
typedef FileSharer = Future<void> Function(String filePath, Rect origin);

Future<void> _shareWithSystemSheet(String filePath, Rect origin) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(filePath, mimeType: 'application/json')],
      sharePositionOrigin: origin,
    ),
  );
}

Future<bool> _openInBrowser(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

Future<String> _loadPackageVersion() async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, UrlOpener? openUrl, FileSharer? shareFile})
      : _openUrl = openUrl ?? _openInBrowser,
        _shareFile = shareFile ?? _shareWithSystemSheet;

  final UrlOpener _openUrl;
  final FileSharer _shareFile;

  /// Builds the screen with a [SettingsCubit] wired to the app-wide services.
  static Widget forApp() {
    return Builder(
      builder: (context) {
        final notificationService = context.read<LocalNotificationService>();
        final themeCubit = context.read<ThemeCubit>();
        return BlocProvider(
          create: (context) => SettingsCubit(
            settingsRepository: context.read<AppSettingsRepository>(),
            scheduleReminder: notificationService.scheduleDailyReminder,
            cancelReminder: notificationService.cancelDailyReminder,
            loadAppVersion: _loadPackageVersion,
            logger: context.read<AppLogger>(),
            setUsageAnalyticsCollection:
                context.read<AnalyticsReporter>().setCollectionEnabled,
            onThemeChanged: themeCubit.apply,
          )..load(),
          child: const SettingsScreen(),
        );
      },
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: cubit.state.reminderTime,
    );
    if (picked == null) return;
    unawaited(cubit.setReminderTime(picked));
  }

  /// Opens [url]; shows the "could not open" message when it cannot.
  Future<void> _open(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppStrings.of(context).privacyLinkFailed;
    var opened = false;
    try {
      opened = await _openUrl(url);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  Future<void> _pickTheme(BuildContext context, SettingsState state) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await showModalBottomSheet<AppThemePreference>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _ThemePickerSheet(current: state.themePreference),
    );
    if (picked == null || picked == state.themePreference) return;
    unawaited(cubit.setThemePreference(picked));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            strings.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<SettingsCubit, SettingsState>(
              listenWhen: (previous, current) =>
                  previous.saveFailureCount != current.saveFailureCount,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.settingsSaveFailed)),
                );
              },
            ),
            BlocListener<PurchasesCubit, PurchasesState>(
              listenWhen: (previous, current) =>
                  previous.actionStatus != current.actionStatus,
              listener: _onPurchaseAction,
            ),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: palette.ink),
                );
              }
              return SafeArea(
                child: PhoneColumn(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      _SettingsGroup(
                        title: strings.sectionPremium,
                        children: [
                          _premiumRow(context, strings),
                          _restoreRow()
                        ],
                      ),
                      _SettingsGroup(
                        title: strings.sectionReminders,
                        children: [
                          _SettingsRow(
                            icon: Icons.notifications_none_rounded,
                            tone: MoodTone.peaceful,
                            title: strings.reminderEnabledTitle,
                            detail: strings.reminderEnabledSubtitle,
                            toggled: state.remindersEnabled,
                            onToggle: (value) => unawaited(
                              context
                                  .read<SettingsCubit>()
                                  .setRemindersEnabled(value),
                            ),
                          ),
                          _SettingsRow(
                            icon: Icons.access_time_rounded,
                            tone: MoodTone.peaceful,
                            title: strings.reminderTimeTitle,
                            value: state.reminderTime.format(context),
                            enabled: state.remindersEnabled,
                            onTap: () => unawaited(_pickTime(context)),
                          ),
                        ],
                      ),
                      _SettingsGroup(
                        title: strings.sectionPrivacyData,
                        children: [
                          _ExportHistoryRow(shareFile: _shareFile),
                          _SettingsRow(
                            icon: Icons.analytics_outlined,
                            tone: MoodTone.neutral,
                            title: strings.usageAnalyticsTitle,
                            detail: strings.usageAnalyticsSubtitle,
                            toggled: state.usageAnalyticsEnabled,
                            onToggle: (value) => unawaited(
                              context
                                  .read<SettingsCubit>()
                                  .setUsageAnalyticsEnabled(value),
                            ),
                          ),
                        ],
                      ),
                      _SettingsGroup(
                        title: strings.sectionAppearance,
                        children: [
                          _SettingsRow(
                            icon: Icons.contrast_rounded,
                            tone: MoodTone.hard,
                            title: strings.themeTitle,
                            value: _themeName(strings, state.themePreference),
                            semanticLabel: strings.themeRowSemantics(
                              _themeName(strings, state.themePreference),
                            ),
                            onTap: () => unawaited(_pickTheme(context, state)),
                          ),
                        ],
                      ),
                      _SettingsGroup(
                        title: strings.sectionHelp,
                        children: [
                          _SettingsRow(
                            icon: Icons.star_rounded,
                            tone: MoodTone.positive,
                            title: strings.rateAppTitle,
                            semanticLabel: strings.rateAppSemanticLabel,
                            onTap: () => unawaited(
                              context
                                  .read<RatingPromptService>()
                                  .openStoreListing(),
                            ),
                          ),
                          _SettingsRow(
                            icon: Icons.mail_outline_rounded,
                            tone: MoodTone.peaceful,
                            title: strings.sendFeedbackTitle,
                            semanticLabel: strings.sendFeedbackSemanticLabel,
                            onTap: () => unawaited(
                              _open(
                                context,
                                Uri(
                                  scheme: 'mailto',
                                  path: feedbackEmail,
                                  queryParameters: {
                                    'subject': strings.appTitle,
                                  },
                                ),
                              ),
                            ),
                          ),
                          _SettingsRow(
                            icon: Icons.privacy_tip_outlined,
                            tone: MoodTone.neutral,
                            title: strings.privacyPolicyTitle,
                            semanticLabel: strings.privacyPolicySemanticLabel,
                            onTap: () => unawaited(
                              _open(context, Uri.parse(privacyPolicyUrl)),
                            ),
                          ),
                          _SettingsRow(
                            icon: Icons.description_outlined,
                            tone: MoodTone.neutral,
                            title: strings.termsTitle,
                            semanticLabel: strings.termsSemanticLabel,
                            onTap: () => unawaited(
                              _open(context, legalPageUrl(context, 'terms')),
                            ),
                          ),
                          if (state.appVersion.isNotEmpty)
                            _SettingsRow(
                              icon: Icons.info_outline_rounded,
                              tone: MoodTone.neutral,
                              title: strings.appVersionTitle,
                              value: state.appVersion,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Result of a restore started here. Skipped while the subscription sheet
  /// covers the screen: it shows the same message itself.
  void _onPurchaseAction(BuildContext context, PurchasesState state) {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final strings = AppStrings.of(context);
    final message = switch (state.actionStatus) {
      PurchaseActionStatus.restored => strings.restoreSuccessMessage,
      PurchaseActionStatus.networkError => strings.purchaseNetworkErrorMessage,
      PurchaseActionStatus.productUnavailable =>
        strings.purchaseProductUnavailableMessage,
      PurchaseActionStatus.unknownError => strings.purchaseUnknownErrorMessage,
      _ => null,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    context.read<PurchasesCubit>().acknowledgeActionStatus();
  }

  Widget _premiumRow(BuildContext context, AppStrings strings) {
    return BlocBuilder<PurchasesCubit, PurchasesState>(
      buildWhen: (previous, current) =>
          previous.subscription != current.subscription,
      builder: (context, purchases) {
        final status = purchases.subscription;
        if (status.isActive) {
          final managementUrl = status.managementUrl;
          return _SettingsRow(
            icon: Icons.diamond_outlined,
            tone: MoodTone.positive,
            title: strings.premiumActiveRowTitle,
            detail: _activeDetail(strings, status),
            onTap: managementUrl == null
                ? null
                : () => unawaited(_open(context, Uri.parse(managementUrl))),
          );
        }
        return _SettingsRow(
          icon: Icons.diamond_outlined,
          tone: MoodTone.positive,
          title: strings.getPremiumTitle,
          detail: strings.getPremiumDetail,
          semanticLabel:
              '${strings.getPremiumTitle}. ${strings.getPremiumDetail}',
          onTap: () => unawaited(
            showPremiumSheet(context, source: PremiumSource.settings),
          ),
        );
      },
    );
  }

  Widget _restoreRow() {
    return BlocBuilder<PurchasesCubit, PurchasesState>(
      buildWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      builder: (context, purchases) {
        final strings = AppStrings.of(context);
        final busy = purchases.actionStatus == PurchaseActionStatus.inProgress;
        return _SettingsRow(
          icon: Icons.restore_rounded,
          tone: MoodTone.neutral,
          title: busy
              ? strings.restoringPurchases
              : strings.restorePurchasesButtonLabel,
          semanticLabel: strings.restorePurchasesRowSemantics,
          enabled: !busy,
          onTap: () =>
              unawaited(context.read<PurchasesCubit>().restorePurchases()),
        );
      },
    );
  }

  String _activeDetail(AppStrings strings, SubscriptionStatus status) {
    final parts = <String>[];
    final plan = status.plan;
    if (plan != null) parts.add(planLabel(strings, plan));
    final expiresAt = status.expiresAt;
    if (expiresAt != null) {
      final date = strings.formatFullDate(expiresAt);
      parts.add(
        status.isInTrial
            ? strings.premiumTrialEndsOn(date)
            : status.willRenew
                ? strings.premiumRenewsOn(date)
                : strings.premiumEndsOn(date),
      );
    }
    return parts.join(' · ');
  }
}

/// Name of a subscription plan in the device language.
String planLabel(AppStrings strings, SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.weekly:
      return strings.weeklyPlanLabel;
    case SubscriptionPlanType.monthly:
      return strings.monthlyPlanLabel;
    case SubscriptionPlanType.annual:
      return strings.annualPlanLabel;
  }
}

String _themeName(AppStrings strings, AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return strings.themeSystem;
    case AppThemePreference.light:
      return strings.themeLight;
    case AppThemePreference.dark:
      return strings.themeDark;
  }
}

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet({required this.current});

  final AppThemePreference current;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in AppThemePreference.values)
              Semantics(
                button: true,
                selected: option == current,
                label: _themeName(strings, option),
                onTap: () => Navigator.of(context).pop(option),
                excludeSemantics: true,
                child: ListTile(
                  minVerticalPadding: 12,
                  title: Text(_themeName(strings, option)),
                  trailing: option == current
                      ? Icon(Icons.check_rounded, color: palette.ink)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A titled group of rows on one glass card.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            child: Semantics(
              container: true,
              header: true,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: palette.glassBorder,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row: an icon in a tinted tile, a title, an optional detail and a
/// control (a switch, a value, a chevron or a spinner). At least 52 pt tall.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.tone,
    required this.title,
    this.detail,
    this.value,
    this.toggled,
    this.onToggle,
    this.onTap,
    this.semanticLabel,
    this.enabled = true,
    this.busy = false,
  });

  final IconData icon;
  final MoodTone tone;
  final String title;
  final String? detail;

  /// Current value shown on the right (time, theme, version).
  final String? value;

  /// Switch rows: the state and its change handler.
  final bool? toggled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final tint = palette.tint(tone);
    final isSwitch = toggled != null;
    final tappable = enabled && (isSwitch || onTap != null);
    final action = isSwitch ? () => onToggle?.call(!toggled!) : onTap;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint.fill,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: tint.ring),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    height: 22 / 15,
                    color: enabled ? palette.text : palette.textSecondary,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: palette.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 8),
            Text(
              value!,
              style: TextStyle(
                fontSize: 15,
                color: palette.textSecondary,
              ),
            ),
          ],
          if (busy) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ] else if (isSwitch) ...[
            const SizedBox(width: 8),
            ExcludeSemantics(
              child: Switch(
                value: toggled!,
                onChanged: enabled ? onToggle : null,
              ),
            ),
          ] else if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textSecondary,
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      button: !isSwitch && onTap != null,
      toggled: isSwitch ? toggled : null,
      enabled: enabled,
      label: semanticLabel ?? title,
      hint: isSwitch ? detail : null,
      // A custom label already says the value.
      value: semanticLabel == null ? value : null,
      onTap: tappable ? action : null,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tappable ? action : null,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _ExportHistoryRow extends StatefulWidget {
  const _ExportHistoryRow({required this.shareFile});

  final FileSharer shareFile;

  @override
  State<_ExportHistoryRow> createState() => _ExportHistoryRowState();
}

class _ExportHistoryRowState extends State<_ExportHistoryRow> {
  bool _isExporting = false;

  Rect _anchorRect() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _export() async {
    if (_isExporting) return;
    final strings = AppStrings.of(context);
    final exportHistory = context.read<ExportMoodHistoryUseCase>();
    final messenger = ScaffoldMessenger.of(context);
    final anchor = _anchorRect();
    setState(() => _isExporting = true);
    try {
      final result = await exportHistory();
      if (result.entryCount == 0) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.exportHistoryEmpty)),
        );
        return;
      }
      await widget.shareFile(result.filePath, anchor);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.historyExportFailed)),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return _SettingsRow(
      icon: Icons.ios_share_rounded,
      tone: MoodTone.neutral,
      title:
          _isExporting ? strings.exportingHistory : strings.exportHistoryTitle,
      semanticLabel: _isExporting
          ? strings.exportingHistory
          : strings.exportHistorySemanticLabel,
      enabled: !_isExporting,
      busy: _isExporting,
      onTap: () => unawaited(_export()),
    );
  }
}
