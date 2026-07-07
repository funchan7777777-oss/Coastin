import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';

class MyCoastWalletPage extends StatefulWidget {
  const MyCoastWalletPage({super.key});

  @override
  State<MyCoastWalletPage> createState() => _MyCoastWalletPageState();
}

class _MyCoastWalletPageState extends State<MyCoastWalletPage> {
  static const List<_ShellCreditParcel> _shoreCreditRows = [
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
    _ShellCreditParcel(shells: '999,9', price: r'$ 9.99'),
  ];

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
                        const SizedBox(height: 68),
                        Image.asset(
                          CoastinAssetRegistry.myWalletWordmark,
                          width: 158,
                          height: 42,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '258,5',
                          style: TextStyle(
                            color: Color(0xFF2F68D3),
                            fontSize: 34,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'balance',
                          style: TextStyle(
                            color: TidewashPalette.inkBlue.withValues(
                              alpha: 0.55,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 34),
                        GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _shoreCreditRows.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.73,
                              ),
                          itemBuilder: (context, index) {
                            return _ShellCreditCard(
                              parcel: _shoreCreditRows[index],
                              onPurchase: () =>
                                  _showBalanceNotice(_shoreCreditRows[index]),
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

  Future<void> _showBalanceNotice(_ShellCreditParcel parcel) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return Center(
          child: CupertinoPopupSurface(
            isSurfacePainted: false,
            child: Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FFFC),
                borderRadius: BorderRadius.circular(30),
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
                    CoastinAssetRegistry.balanceLowNote,
                    width: 178,
                    height: 36,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    CoastinAssetRegistry.coinShell,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Shell balance is not enough',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add ${parcel.shells} shore shells before unlocking this seaside pack.',
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
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F68D3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Got it',
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

class _ShellCreditCard extends StatelessWidget {
  const _ShellCreditCard({required this.parcel, required this.onPurchase});

  final _ShellCreditParcel parcel;
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
                    parcel.shells,
                    style: const TextStyle(
                      color: Color(0xFF9BAEAA),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
              child: Text(
                parcel.price,
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

class _ShellCreditParcel {
  const _ShellCreditParcel({required this.shells, required this.price});

  final String shells;
  final String price;
}
