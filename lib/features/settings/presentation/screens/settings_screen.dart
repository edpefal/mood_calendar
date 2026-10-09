import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/settings/domain/repositories/app_settings_repository.dart';
import '../../../mood/data/services/rating_prompt_service.dart';
import '../../../mood/domain/usecases/export_mood_history_usecase.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

const privacyPolicyUrl =
    'https://www.termsfeed.com/live/c7cd2907-6d6c-46d2-9e1a-a715b74979c8';

const _brandColor = Color(0xFF5F3DC4);

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

  /// Route that builds the [SettingsCubit] from the app-wide services.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) {
        final notificationService = context.read<LocalNotificationService>();
        return BlocProvider(
          create: (context) => SettingsCubit(
            settingsRepository: context.read<AppSettingsRepository>(),
            scheduleReminder: notificationService.scheduleDailyReminder,
            cancelReminder: notificationService.cancelDailyReminder,
            loadAppVersion: _loadPackageVersion,
            logger: context.read<AppLogger>(),
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

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppStrings.of(context).privacyLinkFailed;
    var opened = false;
    try {
      opened = await _openUrl(Uri.parse(privacyPolicyUrl));
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: _brandColor),
        title: Text(
          strings.settingsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _brandColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.saveFailureCount != current.saveFailureCount,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.settingsSaveFailed)),
          );
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _SectionHeader(strings.reminderSheetTitle),
                const SizedBox(height: 8),
                Text(
                  strings.reminderSheetDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.remindersEnabled,
                  title: Text(strings.reminderEnabledTitle),
                  subtitle: Text(strings.reminderEnabledSubtitle),
                  onChanged: (value) => unawaited(
                    context.read<SettingsCubit>().setRemindersEnabled(value),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.reminderTimeTitle),
                  subtitle: Text(state.reminderTime.format(context)),
                  trailing: const Icon(Icons.access_time_rounded),
                  enabled: state.remindersEnabled,
                  onTap: state.remindersEnabled
                      ? () => unawaited(_pickTime(context))
                      : null,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _SectionHeader(strings.settingsDataSection),
                _ExportHistoryRow(shareFile: _shareFile),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _SectionHeader(strings.settingsAboutSection),
                _LinkRow(
                  icon: Icons.star_rounded,
                  title: strings.rateAppTitle,
                  semanticLabel: strings.rateAppSemanticLabel,
                  onTap: () => unawaited(
                    context.read<RatingPromptService>().openStoreListing(),
                  ),
                ),
                _LinkRow(
                  icon: Icons.privacy_tip_outlined,
                  title: strings.privacyPolicyTitle,
                  semanticLabel: strings.privacyPolicySemanticLabel,
                  onTap: () => unawaited(_openPrivacyPolicy(context)),
                ),
                if (state.appVersion.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: _brandColor,
                    ),
                    title: Text(strings.appVersionTitle),
                    trailing: Text(
                      state.appVersion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
    return Semantics(
      button: true,
      enabled: !_isExporting,
      label: _isExporting
          ? strings.exportingHistory
          : strings.exportHistorySemanticLabel,
      onTap: _isExporting ? null : () => unawaited(_export()),
      excludeSemantics: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.ios_share_rounded, color: _brandColor),
        title: Text(
          _isExporting ? strings.exportingHistory : strings.exportHistoryTitle,
        ),
        trailing: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        enabled: !_isExporting,
        onTap: _isExporting ? null : () => unawaited(_export()),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: _brandColor),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
