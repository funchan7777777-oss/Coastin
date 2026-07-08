import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/wallet/shore_shell_wallet_store.dart';
import 'my_coast_wallet_page.dart';

class ShoreShellReef {
  const ShoreShellReef._();

  static const ShoreShellWalletStore _walletStore = ShoreShellWalletStore();

  static Future<bool> confirmAndSpend({
    required BuildContext context,
    required ShoreShellExpense expense,
  }) async {
    final balance = await _walletStore.restoreBalance();
    if (!context.mounted) {
      return false;
    }
    if (balance < expense.cost) {
      await showInsufficient(context: context, expense: expense);
      return false;
    }

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _ShellNoticeDialog(
          title: 'Shell tide check',
          message:
              '${expense.routeLine}\n\nThis action will consume ${expense.cost} shells. Current balance: $balance.',
          actionLabel: 'Spend shells',
          iconAsset: CoastinAssetRegistry.coinShell,
          onAction: () => Navigator.of(dialogContext).pop(true),
        );
      },
    );
    if (confirmed != true) {
      return false;
    }

    final spent = await _walletStore.spend(expense);
    if (!context.mounted) {
      return false;
    }
    if (!spent) {
      await showInsufficient(context: context, expense: expense);
      return false;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _ShellNoticeDialog(
          title: 'Shells released',
          message:
              '${expense.cost} shells were used for ${expense.label.toLowerCase()}.',
          actionLabel: 'Continue',
          iconAsset: CoastinAssetRegistry.coinShell,
          showsCancel: false,
          onAction: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
    return true;
  }

  static Future<void> showInsufficient({
    required BuildContext context,
    required ShoreShellExpense expense,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _ShellNoticeDialog(
          title: 'Shell balance is low',
          message:
              '${expense.label} needs ${expense.cost} shells. Top up before continuing.',
          actionLabel: 'Top up now',
          iconAsset: CoastinAssetRegistry.balanceLowNote,
          onAction: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => const MyCoastWalletPage(),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShellNoticeDialog extends StatelessWidget {
  const _ShellNoticeDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.iconAsset,
    required this.onAction,
    this.showsCancel = true,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String iconAsset;
  final VoidCallback onAction;
  final bool showsCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoPopupSurface(
        isSurfacePainted: false,
        child: Container(
          width: 318,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FFFC),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFB8F4EC), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF176EA2).withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFFFFF),
                      const Color(0xFFBFFBF6).withValues(alpha: 0.82),
                      const Color(0xFF2F68D3).withValues(alpha: 0.16),
                    ],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    iconAsset,
                    width: iconAsset == CoastinAssetRegistry.balanceLowNote
                        ? 68
                        : 54,
                    height: iconAsset == CoastinAssetRegistry.balanceLowNote
                        ? 34
                        : 54,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TidewashPalette.harborSlate.withValues(alpha: 0.78),
                  fontSize: 14,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAction,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35D5DC), Color(0xFF2F68D3)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (showsCancel) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text(
                      'Not now',
                      style: TextStyle(
                        color: Color(0xFF82A19E),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
