import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'app/launch/coastin_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: const Color(0x00000000),
      systemNavigationBarColor: const Color(0x00000000),
    ),
  );
  runApp(const CoastinBootstrap());
}
