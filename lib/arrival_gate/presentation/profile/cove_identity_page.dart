import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../shared/ui/coastin_profile_pickers.dart';
import '../../data/local/harbor_passage_store.dart';
import '../../domain/entities/harbor_passage_record.dart';
import '../../domain/value_objects/profile_wake_choice.dart';
import '../../../shore_guide/domain/value_objects/shore_content_safety_gate.dart';
import '../access/widgets/brine_primary_button.dart';
import '../access/widgets/harbor_back_button.dart';
import '../access/widgets/harbor_credential_field.dart';
import '../access/widgets/harbor_notice_dialog.dart';
import '../access/widgets/passage_loading_dialog.dart';

class CoveIdentityPage extends StatefulWidget {
  const CoveIdentityPage({
    super.key,
    required this.passageStore,
    required this.onHarborCleared,
    required this.initialDocksideName,
    required this.initialMailCurrent,
    required this.entryChannel,
    required this.completionButtonLabel,
  });

  final HarborPassageStore passageStore;
  final VoidCallback onHarborCleared;
  final String initialDocksideName;
  final String initialMailCurrent;
  final String entryChannel;
  final String completionButtonLabel;

  @override
  State<CoveIdentityPage> createState() => _CoveIdentityPageState();
}

class _CoveIdentityPageState extends State<CoveIdentityPage> {
  final ImagePicker _shoreImagePicker = ImagePicker();
  late final TextEditingController _docksideNameController;
  final TextEditingController _signatureController = TextEditingController();
  ProfileWakeChoice? _chosenWake;
  String _avatarImagePath = '';
  String _birthLine = '';
  String _countryLine = '';
  bool _finishingProfile = false;

  @override
  void initState() {
    super.initState();
    _docksideNameController = TextEditingController(
      text: widget.initialDocksideName,
    );
  }

  @override
  void dispose() {
    _docksideNameController.dispose();
    _signatureController.dispose();
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
                  image: AssetImage(CoastinAssetRegistry.saltyRoamBackdrop),
                  fit: BoxFit.fill,
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 86, 28, 34),
                      child: _IdentityPanel(
                        avatarImagePath: _avatarImagePath,
                        docksideNameController: _docksideNameController,
                        signatureController: _signatureController,
                        birthLine: _birthLine,
                        countryLine: _countryLine,
                        chosenWake: _chosenWake,
                        finishingProfile: _finishingProfile,
                        completionButtonLabel: widget.completionButtonLabel,
                        onAvatarRequested: _chooseAvatarCurrent,
                        onAvatarRemoved: () {
                          setState(() => _avatarImagePath = '');
                        },
                        onNameCleared: () {
                          _docksideNameController.clear();
                          setState(() {});
                        },
                        onWakeChosen: (wake) {
                          setState(() => _chosenWake = wake);
                        },
                        onBirthRequested: _chooseBirthday,
                        onCountryRequested: _chooseCountry,
                        onProfileFinished: _finishIdentityPassage,
                      ),
                    ),
                  ),
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

  Future<void> _chooseAvatarCurrent() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Profile photo'),
          message: const Text('Choose a clear coastal profile image.'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
              child: const Text('Choose from Library'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final picked = await _shoreImagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1400,
      );
      if (picked == null || !mounted) {
        return;
      }
      setState(() => _avatarImagePath = picked.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      await showHarborNotice(
        context: context,
        title: 'Photo was not added',
        message:
            'Please allow camera or photo library access, then choose a profile image again.',
      );
    }
  }

  Future<void> _chooseBirthday() async {
    final selectedBirthLine = await showCoastinBirthDatePicker(
      context: context,
      selectedBirthLine: _birthLine,
    );
    if (!mounted || selectedBirthLine == null) {
      return;
    }
    setState(() => _birthLine = selectedBirthLine);
  }

  Future<void> _chooseCountry() async {
    final selectedCountry = await showCoastinCountryPicker(
      context: context,
      selectedCountry: _countryLine,
    );
    if (!mounted || selectedCountry == null) {
      return;
    }
    setState(() => _countryLine = selectedCountry);
  }

  Future<void> _finishIdentityPassage() async {
    if (_finishingProfile) {
      return;
    }
    final docksideName = _docksideNameController.text.trim();
    if (docksideName.isEmpty) {
      await showHarborNotice(
        context: context,
        title: 'Name needed',
        message: 'Please add the name you want to use inside Coastin.',
      );
      return;
    }
    final nameSafetyDecision = ShoreContentSafetyGate.inspect(
      docksideName,
      surface: ShoreContentSurface.profileName,
    );
    if (!nameSafetyDecision.isAllowed) {
      await showHarborNotice(
        context: context,
        title: nameSafetyDecision.title,
        message: nameSafetyDecision.message,
      );
      return;
    }
    final signatureLine = _signatureController.text.trim();
    final signatureSafetyDecision = ShoreContentSafetyGate.inspect(
      signatureLine,
      surface: ShoreContentSurface.profileNote,
    );
    if (!signatureSafetyDecision.isAllowed) {
      await showHarborNotice(
        context: context,
        title: signatureSafetyDecision.title,
        message: signatureSafetyDecision.message,
      );
      return;
    }
    final chosenWake = _chosenWake;
    if (chosenWake == null) {
      await showHarborNotice(
        context: context,
        title: 'Profile choice needed',
        message:
            'Please choose the profile style that fits you before entering.',
      );
      return;
    }

    setState(() => _finishingProfile = true);
    await showPassageLoadingDialog(
      context: context,
      duration: const Duration(milliseconds: 3600),
      message: 'Setting your Coastin profile...',
    );
    await widget.passageStore.settlePassage(
      HarborPassageRecord(
        passageMarker: DateTime.now().microsecondsSinceEpoch.toString(),
        displayName: docksideName,
        mailCurrent: widget.initialMailCurrent,
        entryChannel: widget.entryChannel,
        settledAtIso: DateTime.now().toIso8601String(),
        avatarImagePath: _avatarImagePath,
        profileWake: chosenWake.storageValue,
        signatureLine: signatureLine,
        countryLine: _countryLine.trim(),
        birthLine: _birthLine.trim(),
      ),
    );
    if (!mounted) {
      return;
    }
    widget.onHarborCleared();
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({
    required this.avatarImagePath,
    required this.docksideNameController,
    required this.signatureController,
    required this.birthLine,
    required this.countryLine,
    required this.chosenWake,
    required this.finishingProfile,
    required this.completionButtonLabel,
    required this.onAvatarRequested,
    required this.onAvatarRemoved,
    required this.onNameCleared,
    required this.onWakeChosen,
    required this.onBirthRequested,
    required this.onCountryRequested,
    required this.onProfileFinished,
  });

  final String avatarImagePath;
  final TextEditingController docksideNameController;
  final TextEditingController signatureController;
  final String birthLine;
  final String countryLine;
  final ProfileWakeChoice? chosenWake;
  final bool finishingProfile;
  final String completionButtonLabel;
  final VoidCallback onAvatarRequested;
  final VoidCallback onAvatarRemoved;
  final VoidCallback onNameCleared;
  final ValueChanged<ProfileWakeChoice> onWakeChosen;
  final VoidCallback onBirthRequested;
  final VoidCallback onCountryRequested;
  final VoidCallback onProfileFinished;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Profile Harbor',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF2360C9),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Finish the small details before the first route opens.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0x9951767C),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: _AvatarHarborTile(
            avatarImagePath: avatarImagePath,
            onAvatarRequested: onAvatarRequested,
            onAvatarRemoved: onAvatarRemoved,
          ),
        ),
        const SizedBox(height: 24),
        HarborCredentialField(
          berthLabel: 'Nickname',
          hintCurrent: 'Please enter...',
          tideController: docksideNameController,
          keyboardTrail: TextInputType.name,
          textInputAction: TextInputAction.next,
          trailingAsset: CoastinAssetRegistry.clearEntryBadge,
          onTrailingTap: onNameCleared,
        ),
        const SizedBox(height: 17),
        _IdentitySelectorField(
          label: 'Date of Birth',
          value: birthLine.isEmpty ? 'Not selected' : birthLine,
          onTap: onBirthRequested,
        ),
        const SizedBox(height: 17),
        _IdentitySelectorField(
          label: 'Select country',
          value: countryLine.isEmpty ? 'Not selected' : countryLine,
          onTap: onCountryRequested,
        ),
        const SizedBox(height: 17),
        _SignatureBerth(signatureController: signatureController),
        const SizedBox(height: 22),
        const Text(
          'Profile style',
          style: TextStyle(
            color: Color(0x8A5B767D),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _ProfileWakeTile(
                profileWake: ProfileWakeChoice.male,
                chosenWake: chosenWake,
                assetPath: CoastinAssetRegistry.surferProfileTile,
                onWakeChosen: onWakeChosen,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ProfileWakeTile(
                profileWake: ProfileWakeChoice.female,
                chosenWake: chosenWake,
                assetPath: CoastinAssetRegistry.sundanceProfileTile,
                onWakeChosen: onWakeChosen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        BrinePrimaryButton(
          buttonLabel: completionButtonLabel,
          isWorking: finishingProfile,
          onPressed: onProfileFinished,
        ),
      ],
    );
  }
}

class _AvatarHarborTile extends StatelessWidget {
  const _AvatarHarborTile({
    required this.avatarImagePath,
    required this.onAvatarRequested,
    required this.onAvatarRemoved,
  });

  final String avatarImagePath;
  final VoidCallback onAvatarRequested;
  final VoidCallback onAvatarRemoved;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarImagePath.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAvatarRequested,
          child: Container(
            width: 176,
            height: 156,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF71E6DD), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1FAAB1).withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: hasAvatar
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(avatarImagePath),
                      width: 160,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    CoastinAssetRegistry.beachClubPlus,
                    width: 78,
                    height: 78,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        if (hasAvatar)
          Positioned(
            right: -10,
            top: -10,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAvatarRemoved,
              child: const Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Color(0xFFFF7D82),
                size: 28,
              ),
            ),
          ),
      ],
    );
  }
}

class _IdentitySelectorField extends StatelessWidget {
  const _IdentitySelectorField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x8A5B767D),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xF7FFFFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0x8A5B767D),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0x805B767D),
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignatureBerth extends StatelessWidget {
  const _SignatureBerth({required this.signatureController});

  final TextEditingController signatureController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signature',
          style: TextStyle(
            color: Color(0x8A5B767D),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        CupertinoTextField(
          controller: signatureController,
          maxLines: 3,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
          placeholder: 'Please enter...',
          placeholderStyle: const TextStyle(
            color: Color(0x4D859BA2),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          style: const TextStyle(
            color: Color(0xFF224554),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.32,
            letterSpacing: 0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ],
    );
  }
}

class _ProfileWakeTile extends StatelessWidget {
  const _ProfileWakeTile({
    required this.profileWake,
    required this.chosenWake,
    required this.assetPath,
    required this.onWakeChosen,
  });

  final ProfileWakeChoice profileWake;
  final ProfileWakeChoice? chosenWake;
  final String assetPath;
  final ValueChanged<ProfileWakeChoice> onWakeChosen;

  @override
  Widget build(BuildContext context) {
    final isChosen = chosenWake == profileWake;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onWakeChosen(profileWake),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: isChosen ? const Color(0x332FCAEA) : const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isChosen ? const Color(0xFF2F93D5) : const Color(0x00FFFFFF),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, width: 86, height: 82, fit: BoxFit.contain),
            const SizedBox(height: 7),
            Text(
              profileWake.label,
              style: TextStyle(
                color: isChosen
                    ? const Color(0xFF2360C9)
                    : const Color(0x9951767C),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
