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
    // 针对大画面退出后的设置
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

// 把大的位置标记出来。置为false， 小块不能直接放在上面， 大块直接放在上面。
// 根据blockBigger 和 blockCount 初始化 canPlaceSquare
  static initCanPlaceSquare(Map<int, bool> blockBigger, int blockCount) {
    canPlaceSquare = [
      [true, true, true],
      [true, true, true],
      [true, true, true],
      [true, true, true]
    ];

    // Step 1 先判断有没有大块
    bool has = false;
    int biggerSquareIndex = 0;
    blockBigger.forEach((key, value) {
      if (value == true) {
        has = true;
        biggerSquareIndex = key;
      }
    });

    // Step 2 没有大块不做标记
    if (!has) return;

    // Step 3 有大块，做标记
    // Step 3.1 小于等于4个
    if (blockCount <= 4) {
      canPlaceSquare = [
        [false, false, false],
        [false, false, false],
        [false, false, false],
        [true, true, true]
      ];
      return;
    }
    //Step 3.2 5～9
    // 计算将大widget放置的起始行、列
    int i = (biggerSquareIndex - 1) ~/ 3;
    int j = (biggerSquareIndex - 1) % 3;
    // 如果被放大的widget在被方大之前在第2列，那么放大的起始列变为第一列。 （若为第0列，则保持不变）
    j = (j > 1) ? 1 : j;

    canPlaceSquare[i][j] = false;
    canPlaceSquare[i][j + 1] = false;
    canPlaceSquare[i + 1][j] = false;
    canPlaceSquare[i + 1][j + 1] = false;
  }
}
