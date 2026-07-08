import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../application/harbor_credential_checks.dart';
import '../../data/local/harbor_passage_store.dart';
import '../../domain/entities/harbor_passage_record.dart';
import '../../domain/value_objects/harbor_entry_channel.dart';
import '../../domain/value_objects/harbor_policy_kind.dart';
import '../access/widgets/access_agreement_line.dart';
import '../access/widgets/harbor_back_button.dart';
import '../access/widgets/harbor_credential_field.dart';
import '../access/widgets/harbor_notice_dialog.dart';
import '../access/widgets/passage_loading_dialog.dart';
import '../access/widgets/wave_art_button.dart';
import '../enrollment/surfside_enrollment_page.dart';
import '../policy/harbor_policy_webview_page.dart';

class DocksideAccountEntryPage extends StatefulWidget {
  const DocksideAccountEntryPage({
    super.key,
    required this.passageStore,
    required this.onHarborCleared,
    this.agreementAlreadyAnchored = false,
  });

  final HarborPassageStore passageStore;
  final VoidCallback onHarborCleared;
  final bool agreementAlreadyAnchored;

  @override
  State<DocksideAccountEntryPage> createState() =>
      _DocksideAccountEntryPageState();
}

class _DocksideAccountEntryPageState extends State<DocksideAccountEntryPage> {
  final TextEditingController _mailCurrentController = TextEditingController();
  final TextEditingController _dockKeyController = TextEditingController();
  bool _agreementAnchored = false;
  bool _dockKeyVisible = false;
  bool _startingPassage = false;

  @override
  void initState() {
    super.initState();
    _agreementAnchored = widget.agreementAlreadyAnchored;
  }

  @override
  void dispose() {
    _mailCurrentController.dispose();
    _dockKeyController.dispose();
    super.dispose();
  }

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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Image(
                  image: AssetImage(CoastinAssetRegistry.voyageLogBackdrop),
                  fit: BoxFit.fill,
                ),
                LayoutBuilder(
                  builder: (context, viewport) {
                    final panelWidth = (viewport.maxWidth * 0.78)
                        .clamp(294.0, 340.0)
                        .toDouble();
                    final formTop = (viewport.maxHeight * 0.47)
                        .clamp(392.0, 438.0)
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
                              left: (viewport.maxWidth - panelWidth) / 2,
                              top: formTop,
                              width: panelWidth,
                              child: _AccountEntryPanel(
                                mailCurrentController: _mailCurrentController,
                                dockKeyController: _dockKeyController,
                                agreementAnchored: _agreementAnchored,
                                dockKeyVisible: _dockKeyVisible,
                                startingPassage: _startingPassage,
                                onAgreementChanged: (value) {
                                  setState(() => _agreementAnchored = value);
                                },
                                onPolicyOpened: _openPolicyPage,
                                onDockKeyVisibilityChanged: () {
                                  setState(
                                    () => _dockKeyVisible = !_dockKeyVisible,
                                  );
                                },
                                onMailCleared: () {
                                  _mailCurrentController.clear();
                                  setState(() {});
                                },
                                onStartRequested: _startAccountPassage,
                                onEnrollmentRequested: _openEnrollment,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 12,
                  top: 62,
                  child: HarborBackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startAccountPassage() async {
    if (_startingPassage) {
      return;
    }
    if (!_agreementAnchored) {
      await showAgreementRequiredNotice(context);
      return;
    }

    final mailIssue = HarborCredentialChecks.mailCurrentIssue(
      _mailCurrentController.text,
    );
    final dockKeyIssue = HarborCredentialChecks.dockKeyIssue(
      _dockKeyController.text,
    );
    if (mailIssue != null || dockKeyIssue != null) {
      await showHarborNotice(
        context: context,
        title: 'Check email or password',
        message: mailIssue ?? dockKeyIssue!,
      );
      return;
    }

    setState(() => _startingPassage = true);
    await showPassageLoadingDialog(
      context: context,
      duration: const Duration(milliseconds: 3400),
      message: 'Opening your Coastin harbor...',
    );
    await widget.passageStore.settlePassage(
      HarborPassageRecord(
        passageMarker: DateTime.now().microsecondsSinceEpoch.toString(),
        displayName: HarborCredentialChecks.readableNameFromMail(
          _mailCurrentController.text,
        ),
        mailCurrent: _mailCurrentController.text.trim(),
        entryChannel: HarborEntryChannel.localAccount,
        settledAtIso: DateTime.now().toIso8601String(),
      ),
    );
    if (!mounted) {
      return;
    }
    widget.onHarborCleared();
  }

  Future<void> _openEnrollment() async {
    await Navigator.of(context).pushReplacement(
      CupertinoPageRoute<void>(
        builder: (_) => SurfsideEnrollmentPage(
          passageStore: widget.passageStore,
          onHarborCleared: widget.onHarborCleared,
          agreementAlreadyAnchored: _agreementAnchored,
        ),
      ),
    );
  }

  void _openPolicyPage(HarborPolicyKind policyKind) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => HarborPolicyWebviewPage(policyKind: policyKind),
      ),
    );
  }
}

class _AccountEntryPanel extends StatelessWidget {
  const _AccountEntryPanel({
    required this.mailCurrentController,
    required this.dockKeyController,
    required this.agreementAnchored,
    required this.dockKeyVisible,
    required this.startingPassage,
    required this.onAgreementChanged,
    required this.onPolicyOpened,
    required this.onDockKeyVisibilityChanged,
    required this.onMailCleared,
    required this.onStartRequested,
    required this.onEnrollmentRequested,
  });

  final TextEditingController mailCurrentController;
  final TextEditingController dockKeyController;
  final bool agreementAnchored;
  final bool dockKeyVisible;
  final bool startingPassage;
  final ValueChanged<bool> onAgreementChanged;
  final ValueChanged<HarborPolicyKind> onPolicyOpened;
  final VoidCallback onDockKeyVisibilityChanged;
  final VoidCallback onMailCleared;
  final VoidCallback onStartRequested;
  final VoidCallback onEnrollmentRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            CoastinAssetRegistry.activePierLogin,
            width: 132,
            height: 46,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        HarborCredentialField(
          berthLabel: 'Email Address',
          hintCurrent: 'Please enter...',
          tideController: mailCurrentController,
          keyboardTrail: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          trailingAsset: CoastinAssetRegistry.clearEntryBadge,
          onTrailingTap: onMailCleared,
        ),
        const SizedBox(height: 17),
        HarborCredentialField(
          berthLabel: 'Password',
          hintCurrent: 'Please enter...',
          tideController: dockKeyController,
          isHiddenCurrent: !dockKeyVisible,
          keyboardTrail: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          trailingAsset: dockKeyVisible
              ? CoastinAssetRegistry.passwordVisibleBadge
              : CoastinAssetRegistry.passwordHiddenBadge,
          onTrailingTap: onDockKeyVisibilityChanged,
        ),
        const SizedBox(height: 24),
        Opacity(
          opacity: startingPassage ? 0.72 : 1,
          child: WaveArtButton(
            buttonAsset: CoastinAssetRegistry.sundeckStartButton,
            semanticCurrent: 'Start',
            onPressed: startingPassage ? () {} : onStartRequested,
          ),
        ),
        const SizedBox(height: 14),
        CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          onPressed: onEnrollmentRequested,
          child: const Text(
            'Prefer a fresh profile? Sign up',
            style: TextStyle(
              color: Color(0xFF2F6ACE),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 15),
        AccessAgreementLine(
          agreementAnchored: agreementAnchored,
          onAgreementChanged: onAgreementChanged,
          onPolicyOpened: onPolicyOpened,
        ),
      ],
    );
  }
}
