import 'package:flutter/widgets.dart';

import '../../shore_guide/data/local/seeded_harbor_board.dart';
import '../../shore_guide/presentation/harbor_tabs/cerulean_dock_shell.dart';

class CoastinHomeRoute {
  const CoastinHomeRoute._();

  static Widget openingBoard() {
    return CeruleanDockShell(
      harborBoard: SeededHarborBoard.pacificMorningBoard,
    );
  }
}
