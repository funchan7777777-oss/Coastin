import 'package:flutter/widgets.dart';

import '../../shore_guide/data/local/seeded_harbor_board.dart';
import '../../shore_guide/presentation/board/shoreline_board_page.dart';

class CoastinHomeRoute {
  const CoastinHomeRoute._();

  static Widget openingBoard() {
    return ShorelineBoardPage(
      harborBoard: SeededHarborBoard.pacificMorningBoard,
    );
  }
}
