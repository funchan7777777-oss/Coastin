import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShoreShellExpense {
  publishVideo(
    cost: 120,
    label: 'Publish video update',
    routeLine: 'Send a video moment into background review.',
  ),
  publishPost(
    cost: 80,
    label: 'Publish image post',
    routeLine: 'Submit a photo post for Coastin review.',
  ),
  sunGuideAccess(
    cost: 35,
    label: 'Open sun guide',
    routeLine: 'Unlock the summer sun protection guide.',
    shorelineUnlockKey: 'summerSunProtectionGuide',
  ),
  coveRoutePlanner(
    cost: 45,
    label: 'Open cove route planner',
    routeLine: 'Unlock a tide, shade, and pause comfort route planner.',
    shorelineUnlockKey: 'coveRoutePlanner',
  );

  const ShoreShellExpense({
    required this.cost,
    required this.label,
    required this.routeLine,
    this.shorelineUnlockKey,
  });

  final int cost;
  final String label;
  final String routeLine;
  final String? shorelineUnlockKey;

  bool get isReusableUnlock => shorelineUnlockKey != null;
}

class ShoreShellParcel {
  const ShoreShellParcel({
    required this.productId,
    required this.shellCount,
    required this.fallbackPrice,
  });

  final String productId;
  final int shellCount;
  final String fallbackPrice;
}

class ShoreShellWelcomeGift {
  const ShoreShellWelcomeGift({required this.shells});

  final int shells;
}

class ShoreShellWalletStore {
  const ShoreShellWalletStore();

  static const int welcomeGiftShells = 600;
  static const String _balanceKey = 'coastin.wallet.shellBalance';
  static const String _welcomeGiftKey = 'coastin.wallet.welcomeGiftClaimed';
  static const String _purchaseLedgerKey = 'coastin.wallet.purchaseLedger';
  static const String _unlockedExpenseKey = 'coastin.wallet.unlockedExpenses';

  static final ValueNotifier<int> balanceSignal = ValueNotifier<int>(0);

  static const List<ShoreShellParcel> parcels = [
    ShoreShellParcel(
      productId: 'oyeidmzhgrognajc',
      shellCount: 20000,
      fallbackPrice: r'$99.99',
    ),
    ShoreShellParcel(
      productId: 'xbjbszfkbdsjubfu',
      shellCount: 16000,
      fallbackPrice: r'$79.99',
    ),
    ShoreShellParcel(
      productId: 'kzncgbweuiiufhbo',
      shellCount: 12000,
      fallbackPrice: r'$59.99',
    ),
    ShoreShellParcel(
      productId: 'mzegguwpltbeaxdm',
      shellCount: 10000,
      fallbackPrice: r'$49.99',
    ),
    ShoreShellParcel(
      productId: 'nlgobfyhpswowyea',
      shellCount: 4000,
      fallbackPrice: r'$19.99',
    ),
    ShoreShellParcel(
      productId: 'snekcrkgpnspvpml',
      shellCount: 2000,
      fallbackPrice: r'$9.99',
    ),
    ShoreShellParcel(
      productId: 'oigoghcshjbkiokf',
      shellCount: 1000,
      fallbackPrice: r'$4.99',
    ),
    ShoreShellParcel(
      productId: 'wsxpflorhtorgoti',
      shellCount: 400,
      fallbackPrice: r'$1.99',
    ),
    ShoreShellParcel(
      productId: 'fphyufnnjghtjcws',
      shellCount: 200,
      fallbackPrice: r'$0.99',
    ),
  ];

  Future<int> restoreBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getInt(_balanceKey) ?? 0;
    balanceSignal.value = balance;
    return balance;
  }

  Future<ShoreShellWelcomeGift?> ensureWelcomeGift() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_welcomeGiftKey) ?? false) {
      await restoreBalance();
      return null;
    }
    final balance = (prefs.getInt(_balanceKey) ?? 0) + welcomeGiftShells;
    await prefs.setInt(_balanceKey, balance);
    await prefs.setBool(_welcomeGiftKey, true);
    balanceSignal.value = balance;
    return const ShoreShellWelcomeGift(shells: welcomeGiftShells);
  }

  Future<int> creditShells(int shells) async {
    final prefs = await SharedPreferences.getInstance();
    final balance = (prefs.getInt(_balanceKey) ?? 0) + shells;
    await prefs.setInt(_balanceKey, balance);
    balanceSignal.value = balance;
    return balance;
  }

  Future<bool> spend(ShoreShellExpense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBalance = prefs.getInt(_balanceKey) ?? 0;
    if (currentBalance < expense.cost) {
      balanceSignal.value = currentBalance;
      return false;
    }
    final nextBalance = currentBalance - expense.cost;
    await prefs.setInt(_balanceKey, nextBalance);
    balanceSignal.value = nextBalance;
    return true;
  }

  Future<bool> isExpenseUnlocked(ShoreShellExpense expense) async {
    final unlockKey = expense.shorelineUnlockKey;
    if (unlockKey == null) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final unlockedExpenses =
        prefs.getStringList(_unlockedExpenseKey)?.toSet() ?? {};
    if (unlockedExpenses.contains(unlockKey)) {
      return true;
    }
    if (!_matchesLegacySunGuideUnlock(expense, prefs)) {
      return false;
    }
    unlockedExpenses.add(unlockKey);
    await prefs.setStringList(
      _unlockedExpenseKey,
      unlockedExpenses.toList()..sort(),
    );
    return true;
  }

  Future<void> rememberExpenseUnlock(ShoreShellExpense expense) async {
    final unlockKey = expense.shorelineUnlockKey;
    if (unlockKey == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final unlockedExpenses =
        prefs.getStringList(_unlockedExpenseKey)?.toSet() ?? {};
    if (!unlockedExpenses.add(unlockKey)) {
      return;
    }
    await prefs.setStringList(
      _unlockedExpenseKey,
      unlockedExpenses.toList()..sort(),
    );
  }

  bool _matchesLegacySunGuideUnlock(
    ShoreShellExpense expense,
    SharedPreferences prefs,
  ) {
    if (expense != ShoreShellExpense.sunGuideAccess) {
      return false;
    }
    if (!(prefs.getBool(_welcomeGiftKey) ?? false)) {
      return false;
    }
    return prefs.getInt(_balanceKey) == welcomeGiftShells - expense.cost;
  }

  Future<bool> markPurchaseIfFresh(String purchaseToken) async {
    final prefs = await SharedPreferences.getInstance();
    final ledger = prefs.getStringList(_purchaseLedgerKey)?.toSet() ?? {};
    if (ledger.contains(purchaseToken)) {
      return false;
    }
    ledger.add(purchaseToken);
    await prefs.setStringList(_purchaseLedgerKey, ledger.toList()..sort());
    return true;
  }

  Future<void> clearWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_balanceKey);
    await prefs.remove(_welcomeGiftKey);
    await prefs.remove(_purchaseLedgerKey);
    await prefs.remove(_unlockedExpenseKey);
    balanceSignal.value = 0;
  }
}
