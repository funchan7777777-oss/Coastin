import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../arrival_gate/data/local/harbor_passage_store.dart';
import '../../../../arrival_gate/domain/entities/harbor_passage_record.dart';
import '../../../../arrival_gate/domain/value_objects/profile_wake_choice.dart';
import '../widgets/my_coast_top_bar.dart';
import '../widgets/my_coast_wash.dart';

class MyCoastEditPage extends StatefulWidget {
  const MyCoastEditPage({super.key, required this.initialRecord});

  final HarborPassageRecord? initialRecord;

  @override
  State<MyCoastEditPage> createState() => _MyCoastEditPageState();
}

class _MyCoastEditPageState extends State<MyCoastEditPage> {
  final HarborPassageStore _passageStore = const HarborPassageStore();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _signatureController;
  String _avatarPath = '';
  String _birthLine = '2000  00  00';
  String _countryLine = 'United States';
  ProfileWakeChoice _wakeChoice = ProfileWakeChoice.male;

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    _nameController = TextEditingController(
      text: record?.displayName ?? 'Emilie',
    );
    _signatureController = TextEditingController(
      text: record?.signatureLine ?? '',
    );
    _avatarPath = record?.avatarImagePath ?? '';
    if (record?.profileWake == ProfileWakeChoice.female.storageValue) {
      _wakeChoice = ProfileWakeChoice.female;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

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
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 54, 26, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyCoastTopBar(
                          title: 'Edit Profile',
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: _EditAvatarBox(
                            avatarPath: _avatarPath,
                            onPick: _pickAvatar,
                            onClear: () => setState(() => _avatarPath = ''),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _EditField(
                          label: 'Nickname',
                          controller: _nameController,
                          trailingAsset: CoastinAssetRegistry.clearEntryBadge,
                          onTrailingTap: () => _nameController.clear(),
                        ),
                        const SizedBox(height: 22),
                        _SelectorField(
                          label: 'Date of Birth',
                          value: _birthLine,
                          onTap: _chooseBirthday,
                        ),
                        const SizedBox(height: 22),
                        _SelectorField(
                          label: 'Select country',
                          value: _countryLine,
                          onTap: _chooseCountry,
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Gender selection',
                          style: TextStyle(
                            color: TidewashPalette.harborSlate,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _WakeChoiceTile(
                                label: 'Male',
                                asset: CoastinAssetRegistry.surferProfileTile,
                                isSelected:
                                    _wakeChoice == ProfileWakeChoice.male,
                                onTap: () {
                                  setState(() {
                                    _wakeChoice = ProfileWakeChoice.male;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _WakeChoiceTile(
                                label: 'Female',
                                asset: CoastinAssetRegistry.sundanceProfileTile,
                                isSelected:
                                    _wakeChoice == ProfileWakeChoice.female,
                                onTap: () {
                                  setState(() {
                                    _wakeChoice = ProfileWakeChoice.female;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _SignatureField(controller: _signatureController),
                        const SizedBox(height: 44),
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _saveProfile,
                            child: SizedBox(
                              width: 280,
                              height: 58,
                              child: Image.asset(
                                CoastinAssetRegistry.saveProfilePlate,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Profile photo'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text('Choose from Library'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
    if (source == null) {
      return;
    }
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 84,
      maxWidth: 1400,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _avatarPath = picked.path);
  }

  void _chooseBirthday() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Date of Birth'),
          actions: [
            for (final value in [
              '1998  05  12',
              '2000  00  00',
              '2002  08  21',
            ])
              CupertinoActionSheetAction(
                onPressed: () {
                  setState(() => _birthLine = value);
                  Navigator.of(context).pop();
                },
                child: Text(value),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void _chooseCountry() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Select country'),
          actions: [
            for (final value in ['United States', 'Australia', 'Canada'])
              CupertinoActionSheetAction(
                onPressed: () {
                  setState(() => _countryLine = value);
                  Navigator.of(context).pop();
                },
                child: Text(value),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Nickname needed'),
            content: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Please enter a Coastin nickname before saving.'),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    final existing = widget.initialRecord;
    await _passageStore.settlePassage(
      HarborPassageRecord(
        passageMarker:
            existing?.passageMarker ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        displayName: name,
        mailCurrent: existing?.mailCurrent ?? 'coastin@local',
        entryChannel: existing?.entryChannel ?? 'profile',
        settledAtIso:
            existing?.settledAtIso ?? DateTime.now().toIso8601String(),
        avatarImagePath: _avatarPath,
        profileWake: _wakeChoice.storageValue,
        signatureLine: _signatureController.text.trim(),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _EditAvatarBox extends StatelessWidget {
  const _EditAvatarBox({
    required this.avatarPath,
    required this.onPick,
    required this.onClear,
  });

  final String avatarPath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPick,
          child: Container(
            width: 230,
            height: 230,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF56E4DD).withValues(alpha: 0.66),
                width: 1.4,
              ),
            ),
            child: hasAvatar
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.file(
                      File(avatarPath),
                      width: 212,
                      height: 212,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    CoastinAssetRegistry.beachClubPlus,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClear,
            child: Image.asset(
              CoastinAssetRegistry.clearEntryBadge,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.trailingAsset,
    this.onTrailingTap,
  });

  final String label;
  final TextEditingController controller;
  final String? trailingAsset;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Please enter...',
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          suffix: trailingAsset == null
              ? null
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTrailingTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Image.asset(trailingAsset!, width: 24, height: 24),
                  ),
                ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(26),
          ),
          style: const TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SelectorField extends StatelessWidget {
  const _SelectorField({
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
        _FieldLabel(label),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(27),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFFB8C7C6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFB8C7C6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignatureField extends StatelessWidget {
  const _SignatureField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Signature'),
        const SizedBox(height: 10),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Please enter...',
          minLines: 4,
          maxLines: 5,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(25),
          ),
          style: const TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WakeChoiceTile extends StatelessWidget {
  const _WakeChoiceTile({
    required this.label,
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFBFF6F0).withValues(alpha: 0.86)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F68D3)
                : const Color(0x00FFFFFF),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Image.asset(asset, height: 84, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF2F68D3)
                    : TidewashPalette.harborSlate.withValues(alpha: 0.58),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: TidewashPalette.harborSlate,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
