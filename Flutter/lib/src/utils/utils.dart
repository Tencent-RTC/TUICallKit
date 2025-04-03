
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static FileSystem fileSystem = const LocalFileSystem();

  static Future<String> getAssetsFilePath(String assetName) async {
    if (assetName.isEmpty) {
      return "";
    }
    final String tempDirectory = await getTempDirectory();
    String filePath = "$tempDirectory/$assetName";
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData = await loadAsset(assetName);
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return file.path;
  }

  //path: The format of the path parameter in the plugin is 'package$pluginName$assetsPrefix$assetsName'
  @visibleForTesting
  static Future<ByteData> loadAsset(String path) => rootBundle.load(path);

  @visibleForTesting
  static Future<String> getTempDirectory() async => (await getTemporaryDirectory()).path;
}