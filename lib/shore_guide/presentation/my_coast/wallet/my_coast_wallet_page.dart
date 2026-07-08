import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/wallet/shore_shell_purchase_broker.dart';
import '../../../data/local/wallet/shore_shell_wallet_store.dart';

class MyCoastWalletPage extends StatefulWidget {
  const MyCoastWalletPage({super.key});

  @override
  State<MyCoastWalletPage> createState() => _MyCoastWalletPageState();
}

class _MyCoastWalletPageState extends State<MyCoastWalletPage> {
  final ShoreShellWalletStore _walletStore = const ShoreShellWalletStore();
  final ShoreShellPurchaseBroker _purchaseBroker = ShoreShellPurchaseBroker();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool _isPurchasing = false;
  String? _activeProductId;

  @override
  void initState() {
    super.initState();
    _walletStore.restoreBalance();
    _purchaseSub = _purchaseBroker.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isPurchasing = false;
          _activeProductId = null;
        });
        _showWalletNotice(
          title: 'Store tide failed',
          message: 'Apple purchase updates are unavailable. Please try again.',
        );
      },
    );
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFB9F6F3),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                CoastinAssetRegistry.walletBackdrop,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 38),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WalletBackLine(
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 52),
                        _BalanceHarborCard(
                          balanceListenable:
                              ShoreShellWalletStore.balanceSignal,
                        ),
                        const SizedBox(height: 22),
                        _ShellUseChart(expenses: ShoreShellExpense.values),
                        const SizedBox(height: 22),
                        const Text(
                          'Shell top-up',
                          style: TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ShoreShellWalletStore.parcels.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (context, index) {
                            final parcel = ShoreShellWalletStore.parcels[index];
                            return _ShellCreditCard(
                              parcel: parcel,
                              isPurchasing:
                                  _isPurchasing &&
                                  _activeProductId == parcel.productId,
                              onPurchase: () => _buyParcel(parcel),
                            );
                          },
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

  Future<void> _buyParcel(ShoreShellParcel parcel) async {
    if (_isPurchasing) {
      return;
    }
    setState(() {
      _isPurchasing = true;
      _activeProductId = parcel.productId;
    });

    final startResult = await _purchaseBroker.startPurchase(parcel);
    if (!mounted) {
      return;
    }
    if (startResult.status != ShoreShellPurchaseStartStatus.started) {
      setState(() {
        _isPurchasing = false;
        _activeProductId = null;
      });
      await _showWalletNotice(
        title: 'Top-up unavailable',
        message: startResult.message,
      );
      return;
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final receipt = await _purchaseBroker.handlePurchase(purchase);
      if (!mounted || receipt == null) {
        continue;
      }
      setState(() {
        _isPurchasing = false;
        _activeProductId = null;
      });
      if (receipt.status == ShoreShellPurchaseReceiptStatus.completed) {
        if (receipt.shells > 0) {
          await _showWalletNotice(
            title: 'Shell tide topped up',
            message:
                '${receipt.shells} shells have landed in your Coastin wallet.',
          );
        }
      } else if (receipt.status == ShoreShellPurchaseReceiptStatus.failed) {
        await _showWalletNotice(
          title: 'Purchase did not finish',
          message: receipt.message,
        );
      }
    }
  }

  Future<void> _showWalletNotice({
    required String title,
    required String message,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Center(
          child: CupertinoPopupSurface(
            isSurfacePainted: false,
            child: Container(
              width: 310,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FFFC),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFB9F4EC)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2069A5).withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    CoastinAssetRegistry.coinShell,
                    width: 66,
                    height: 66,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TidewashPalette.harborSlate.withValues(
                        alpha: 0.72,
                      ),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F68D3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalletBackLine extends StatelessWidget {
  const _WalletBackLine({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBack,
      child: const SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          CupertinoIcons.chevron_left,
          color: TidewashPalette.inkBlue,
          size: 28,
        ),
      ),
    );
  }
}

class _BalanceHarborCard extends StatelessWidget {
  const _BalanceHarborCard({required this.balanceListenable});

  final ValueNotifier<int> balanceListenable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7FFF9)),
      ),
      child: Row(
        children: [
          Image.asset(
            CoastinAssetRegistry.myWalletWordmark,
            width: 138,
            height: 40,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const Spacer(),
          Image.asset(
            CoastinAssetRegistry.coinShell,
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<int>(
            valueListenable: balanceListenable,
            builder: (context, balance, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$balance',
                    style: const TextStyle(
                      color: Color(0xFF2F68D3),
                      fontSize: 32,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'live balance',
                    style: TextStyle(
                      color: TidewashPalette.inkBlue.withValues(alpha: 0.56),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShellUseChart extends StatelessWidget {
  const _ShellUseChart({required this.expenses});

  final List<ShoreShellExpense> expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6F9EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shell use map',
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final expense in expenses) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF35D5DC),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    expense.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${expense.cost}',
                  style: const TextStyle(
                    color: Color(0xFF2F68D3),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Chat and video chat are free after mutual follow.',
            style: TextStyle(
              color: TidewashPalette.harborSlate.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellCreditCard extends StatelessWidget {
  const _ShellCreditCard({
    required this.parcel,
    required this.isPurchasing,
    required this.onPurchase,
  });

  final ShoreShellParcel parcel;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD8FFFB).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    CoastinAssetRegistry.coinShell,
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${parcel.shellCount}',
                    style: const TextStyle(
                      color: Color(0xFF7D9692),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPurchase,
            child: Container(
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F68D3),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F68D3).withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isPurchasing
                  ? const CupertinoActivityIndicator(
                      color: Color(0xFFFFFFFF),
                      radius: 7,
                    )
                  : Text(
                      parcel.fallbackPrice,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
