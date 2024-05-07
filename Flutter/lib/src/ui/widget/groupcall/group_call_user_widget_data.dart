class GroupCallUserWidgetData {
  static Map<int, bool> blockBigger = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
    9: false
  };

  static int blockCount = 0;

  static List<List<bool>> canPlaceSquare = [
    [true, true, true],
    [true, true, true],
    [true, true, true],
    [true, true, true]
  ];

  static initBlockBigger() {
    blockBigger = {
      1: false,
      2: false,
      3: false,
      4: false,
      5: false,
      6: false,
      7: false,
      8: false,
      9: false
    };
  }

  static updateBlockBigger(int blockCount) {
    // Settings for the exit of the big picture
    blockBigger.forEach((key, value) {
      if (value == true && key > blockCount) {
        blockBigger = {
          1: false,
          2: false,
          3: false,
          4: false,
          5: false,
          6: false,
          7: false,
          8: false,
          9: false
        };
      }
    });
  }

  static initBlockCounter() {
    blockCount = 0;
  }

  static bool hasBiggerSquare() {
    bool has = false;
    blockBigger.forEach((key, value) {
      if (value == true) {
        has = true;
      }
    });
    return has;
  }

// Mark the large position. False is placed, small pieces cannot be placed directly on it, and large pieces can be placed directly on it.
// Be initialized by BlockBigger and BlockCount Canplacesquare
  static initCanPlaceSquare(Map<int, bool> blockBigger, int blockCount) {
    canPlaceSquare = [
      [true, true, true],
      [true, true, true],
      [true, true, true],
      [true, true, true]
    ];

    bool has = false;
    int biggerSquareIndex = 0;
    blockBigger.forEach((key, value) {
      if (value == true) {
        has = true;
        biggerSquareIndex = key;
      }
    });

    if (!has) return;

    if (blockCount <= 4) {
      canPlaceSquare = [
        [false, false, false],
        [false, false, false],
        [false, false, false],
        [true, true, true]
      ];
      return;
    }
    int i = (biggerSquareIndex - 1) ~/ 3;
    int j = (biggerSquareIndex - 1) % 3;

    j = (j > 1) ? 1 : j;

    canPlaceSquare[i][j] = false;
    canPlaceSquare[i][j + 1] = false;
    canPlaceSquare[i + 1][j] = false;
    canPlaceSquare[i + 1][j + 1] = false;
  }
}
