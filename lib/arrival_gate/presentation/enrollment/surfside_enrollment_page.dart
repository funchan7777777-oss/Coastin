import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../application/harbor_credential_checks.dart';
import '../../data/local/harbor_passage_store.dart';
import '../../domain/value_objects/harbor_entry_channel.dart';
import '../../domain/value_objects/harbor_policy_kind.dart';
import '../access/widgets/access_agreement_line.dart';
import '../access/widgets/brine_primary_button.dart';
import '../access/widgets/harbor_back_button.dart';
import '../access/widgets/harbor_credential_field.dart';
import '../access/widgets/harbor_notice_dialog.dart';
import '../policy/harbor_policy_webview_page.dart';
import '../profile/cove_identity_page.dart';

class SurfsideEnrollmentPage extends StatefulWidget {
  const SurfsideEnrollmentPage({
    super.key,
    required this.passageStore,
    required this.onHarborCleared,
    this.agreementAlreadyAnchored = false,
  });

  final HarborPassageStore passageStore;
  final VoidCallback onHarborCleared;
  final bool agreementAlreadyAnchored;

  @override
  State<SurfsideEnrollmentPage> createState() => _SurfsideEnrollmentPageState();
}

class _SurfsideEnrollmentPageState extends State<SurfsideEnrollmentPage> {
  final TextEditingController _mailCurrentController = TextEditingController();
  final TextEditingController _dockKeyController = TextEditingController();
  bool _agreementAnchored = false;
  bool _dockKeyVisible = false;

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
                              child: _EnrollmentPanel(
                                mailCurrentController: _mailCurrentController,
                                dockKeyController: _dockKeyController,
                                agreementAnchored: _agreementAnchored,
                                dockKeyVisible: _dockKeyVisible,
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
                                onSignupRequested: _openProfileTide,
                                onLoginRequested: _openAccountEntry,
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

  Future<void> _openProfileTide() async {
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
        title: 'Registration details needed',
        message: mailIssue ?? dockKeyIssue!,
      );
      return;
    }

    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CoveIdentityPage(
          passageStore: widget.passageStore,
          onHarborCleared: widget.onHarborCleared,
          initialDocksideName: HarborCredentialChecks.readableNameFromMail(
            _mailCurrentController.text,
          ),
          initialMailCurrent: _mailCurrentController.text.trim(),
          entryChannel: HarborEntryChannel.localRegistration,
          completionButtonLabel: 'Next',
        ),
      ),
    );
  }

  Future<void> _openAccountEntry() async {
    Navigator.of(context).pop();
  }

  void _openPolicyPage(HarborPolicyKind policyKind) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => HarborPolicyWebviewPage(policyKind: policyKind),
      ),
    );
  }
}

class _EnrollmentPanel extends StatelessWidget {
  const _EnrollmentPanel({
    required this.mailCurrentController,
    required this.dockKeyController,
    required this.agreementAnchored,
    required this.dockKeyVisible,
    required this.onAgreementChanged,
    required this.onPolicyOpened,
    required this.onDockKeyVisibilityChanged,
    required this.onMailCleared,
    required this.onSignupRequested,
    required this.onLoginRequested,
  });

  final TextEditingController mailCurrentController;
  final TextEditingController dockKeyController;
  final bool agreementAnchored;
  final bool dockKeyVisible;
  final ValueChanged<bool> onAgreementChanged;
  final ValueChanged<HarborPolicyKind> onPolicyOpened;
  final VoidCallback onDockKeyVisibilityChanged;
  final VoidCallback onMailCleared;
  final VoidCallback onSignupRequested;
  final VoidCallback onLoginRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            CoastinAssetRegistry.activePierSignup,
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
              ? CoastinAssetRegistry.visibleSecretBadge
              : CoastinAssetRegistry.shadedSecretBadge,
          onTrailingTap: onDockKeyVisibilityChanged,
        ),
        const SizedBox(height: 24),
        BrinePrimaryButton(
          buttonLabel: 'Sign up',
          onPressed: onSignupRequested,
        ),
        const SizedBox(height: 14),
        CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          onPressed: onLoginRequested,
          child: const Text(
            'Already drifting with us? Back to log in',
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
