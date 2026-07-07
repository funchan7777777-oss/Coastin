import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../arrival_gate/application/coastin_entry_flow.dart';
import '../../../../arrival_gate/data/local/harbor_passage_store.dart';
import '../../../../arrival_gate/domain/value_objects/harbor_policy_kind.dart';
import '../../../../arrival_gate/presentation/policy/harbor_policy_webview_page.dart';
import '../../../data/local/buddies/sea_buddy_message_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../safety/shore_safety_reef.dart';
import '../network/my_coast_network_page.dart';
import '../widgets/my_coast_top_bar.dart';
import '../widgets/my_coast_wash.dart';
import 'community_guidelines_page.dart';

class MyCoastSettingsPage extends StatelessWidget {
  const MyCoastSettingsPage({super.key});

  static const HarborPassageStore _passageStore = HarborPassageStore();
  static const ShoreSafetyStore _safetyStore = ShoreSafetyStore();
  static const SeaBuddyMessageStore _messageStore = SeaBuddyMessageStore();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: MyCoastWash()),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 54, 22, 28),
              child: Column(
                children: [
                  MyCoastTopBar(
                    title: '',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.blockedPersonGlyph,
                    title: 'Blacklist',
                    onTap: () =>
                        _openNetwork(context, MyCoastNetworkKind.blacklist),
                  ),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.documentGlyph,
                    title: 'Privacy agreement',
                    onTap: () =>
                        _openPolicy(context, HarborPolicyKind.privacyPolicy),
                  ),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.documentGlyph,
                    title: 'User agreement',
                    onTap: () =>
                        _openPolicy(context, HarborPolicyKind.userAgreement),
                  ),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.settingsListGlyph,
                    title: 'Community guidelines',
                    onTap: () => _openGuidelines(context),
                  ),
                  const SizedBox(height: 20),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.redTrashGlyph,
                    title: 'Deletion of account',
                    isWarning: true,
                    hasChevron: false,
                    onTap: () => _confirmClear(context, isDeletion: true),
                  ),
                  _SettingRow(
                    iconAsset: CoastinAssetRegistry.redPowerGlyph,
                    title: 'Log Out',
                    isWarning: true,
                    hasChevron: false,
                    onTap: () => _confirmClear(context, isDeletion: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openNetwork(BuildContext context, MyCoastNetworkKind kind) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => MyCoastNetworkPage(kind: kind)),
    );
  }

  static void _openPolicy(BuildContext context, HarborPolicyKind policyKind) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => HarborPolicyWebviewPage(policyKind: policyKind),
      ),
    );
  }

  static void _openGuidelines(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const CommunityGuidelinesPage()),
    );
  }

  static void _confirmClear(BuildContext context, {required bool isDeletion}) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(isDeletion ? 'Delete local profile?' : 'Log out?'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              isDeletion
                  ? 'This clears your saved Coastin profile on this device.'
                  : 'You will return to the Coastin login screen.',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _showBusyTide(context, isDeletion: isDeletion);
                await Future<void>.delayed(const Duration(milliseconds: 900));
                await _passageStore.clearSettledPassage();
                if (isDeletion) {
                  await _safetyStore.clearLocalLedger();
                  await _messageStore.clearAllThreads();
                }
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context, rootNavigator: true).pop();
                await ShoreSafetyReef.showAccountDone(
                  context: context,
                  title: isDeletion ? 'Account deleted' : 'Logged out',
                  message: isDeletion
                      ? 'Your local Coastin profile has been cleared on this device.'
                      : 'You have signed out of Coastin on this device.',
                );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  CupertinoPageRoute<void>(
                    builder: (_) => const CoastinEntryFlow(),
                  ),
                  (_) => false,
                );
              },
              child: Text(isDeletion ? 'Delete' : 'Log Out'),
            ),
          ],
        );
      },
    );
  }

  static void _showBusyTide(BuildContext context, {required bool isDeletion}) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(isDeletion ? 'Deleting account' : 'Logging out'),
          content: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CupertinoActivityIndicator(radius: 13),
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.onTap,
    required this.iconAsset,
    this.isWarning = false,
    this.hasChevron = true,
  });

  final String iconAsset;
  final String title;
  final bool isWarning;
  final bool hasChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? const Color(0xFFFF284F) : TidewashPalette.inkBlue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Image.asset(iconAsset, width: 21, height: 21),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (hasChevron)
              const Icon(
                CupertinoIcons.chevron_right,
                color: Color(0xFF92A59E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
