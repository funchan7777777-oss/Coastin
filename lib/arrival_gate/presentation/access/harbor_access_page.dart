import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../domain/entities/harbor_passage_record.dart';
import '../../data/local/harbor_passage_store.dart';
import '../../domain/value_objects/harbor_entry_channel.dart';
import '../../domain/value_objects/harbor_policy_channel.dart';
import '../enrollment/surfside_enrollment_page.dart';
import '../policy/harbor_policy_webview_page.dart';
import 'widgets/access_agreement_line.dart';
import 'widgets/apple_current_button.dart';
import 'widgets/brine_primary_button.dart';
import 'widgets/harbor_notice_dialog.dart';
import 'widgets/wave_art_button.dart';

class HarborAccessPage extends StatefulWidget {
  const HarborAccessPage({
    super.key,
    required this.passageStore,
    required this.onHarborCleared,
  });

  final HarborPassageStore passageStore;
  final VoidCallback onHarborCleared;

  @override
  State<HarborAccessPage> createState() => _HarborAccessPageState();
}

class _HarborAccessPageState extends State<HarborAccessPage> {
  bool _agreementAnchored = false;
  bool _appleCurrentWorking = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0x00000000),
      ),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0x00000000),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Image(
                image: AssetImage(CoastinAssetRegistry.voyageLogBackdrop),
                fit: BoxFit.fill,
              ),
              LayoutBuilder(
                builder: (context, viewport) {
                  final harborPanelWidth = (viewport.maxWidth * 0.78)
                      .clamp(294.0, 340.0)
                      .toDouble();
                  final panelTop = (viewport.maxHeight * 0.58)
                      .clamp(486.0, 515.0)
                      .toDouble();
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: viewport.maxWidth,
                      height: viewport.maxHeight < 720
                          ? 720
                          : viewport.maxHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            left: (viewport.maxWidth - harborPanelWidth) / 2,
                            top: panelTop,
                            width: harborPanelWidth,
                            child: _HarborAccessDock(
                              agreementAnchored: _agreementAnchored,
                              appleCurrentWorking: _appleCurrentWorking,
                              onAgreementChanged: (value) {
                                setState(() => _agreementAnchored = value);
                              },
                              onPolicyOpened: _openPolicyPage,
                              onAccountEntryRequested: _openAccountEntry,
                              onEnrollmentRequested: _openEnrollment,
                              onAppleCurrentRequested: _beginAppleCurrent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountEntry() async {
    if (!await _guardAgreement()) {
      return;
    }
    await _enterHarborHome(
      entryChannel: HarborEntryChannel.localAccount,
      displayName: 'Emilie',
    );
  }

  Future<void> _openEnrollment() async {
    if (!await _guardAgreement()) {
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SurfsideEnrollmentPage(
          passageStore: widget.passageStore,
          onHarborCleared: widget.onHarborCleared,
          agreementAlreadyAnchored: _agreementAnchored,
        ),
      ),
    );
  }

  Future<void> _beginAppleCurrent() async {
    if (!await _guardAgreement()) {
      return;
    }
    if (_appleCurrentWorking) {
      return;
    }

    setState(() => _appleCurrentWorking = true);
    try {
      await _enterHarborHome(
        entryChannel: HarborEntryChannel.appleCurrent,
        displayName: 'Emilie',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      await showHarborNotice(
        context: context,
        title: 'Entry needs attention',
        message:
            'Coastin could not open your home page right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _appleCurrentWorking = false);
      }
    }
  }

  Future<void> _enterHarborHome({
    required String entryChannel,
    required String displayName,
  }) async {
    await widget.passageStore.settlePassage(
      HarborPassageRecord(
        passageMarker: DateTime.now().microsecondsSinceEpoch.toString(),
        displayName: displayName,
        mailCurrent: '',
        entryChannel: entryChannel,
        settledAtIso: DateTime.now().toIso8601String(),
      ),
    );
    if (!mounted) {
      return;
    }
    widget.onHarborCleared();
  }

  Future<bool> _guardAgreement() async {
    if (_agreementAnchored) {
      return true;
    }
    await showAgreementRequiredNotice(context);
    return false;
  }

  void _openPolicyPage(HarborPolicyChannel policyChannel) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => HarborPolicyWebviewPage(policyChannel: policyChannel),
      ),
    );
  }
}

class _HarborAccessDock extends StatelessWidget {
  const _HarborAccessDock({
    required this.agreementAnchored,
    required this.appleCurrentWorking,
    required this.onAgreementChanged,
    required this.onPolicyOpened,
    required this.onAccountEntryRequested,
    required this.onEnrollmentRequested,
    required this.onAppleCurrentRequested,
  });

  final bool agreementAnchored;
  final bool appleCurrentWorking;
  final ValueChanged<bool> onAgreementChanged;
  final ValueChanged<HarborPolicyChannel> onPolicyOpened;
  final VoidCallback onAccountEntryRequested;
  final VoidCallback onEnrollmentRequested;
  final VoidCallback onAppleCurrentRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: WaveArtButton(
            buttonAsset: CoastinAssetRegistry.docksideLoginButton,
            semanticCurrent: 'Log in',
            buttonWidth: 236,
            buttonHeight: 49,
            onPressed: onAccountEntryRequested,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: BrinePrimaryButton(
            buttonLabel: 'Create coast profile',
            buttonWidth: 236,
            buttonHeight: 49,
            fontSize: 14,
            onPressed: onEnrollmentRequested,
          ),
        ),
        const SizedBox(height: 19),
        const _HarborSeparator(),
        const SizedBox(height: 14),
        AppleCurrentButton(
          isWorking: appleCurrentWorking,
          onAppleCurrentPressed: onAppleCurrentRequested,
        ),
        const SizedBox(height: 18),
        AccessAgreementLine(
          agreementAnchored: agreementAnchored,
          onAgreementChanged: onAgreementChanged,
          onPolicyOpened: onPolicyOpened,
        ),
      ],
    );
  }
}

class _HarborSeparator extends StatelessWidget {
  const _HarborSeparator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SeparatorWake()),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: Color(0x663A727F),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(child: _SeparatorWake()),
      ],
    );
  }
}

class _SeparatorWake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x223A727F));
  }
}
