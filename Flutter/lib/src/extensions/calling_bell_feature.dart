import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';

class CallingBellFeature {
  static FileSystem fileSystem = const LocalFileSystem();
  static String package = "packages/";
  static String pluginName = "tencent_calls_uikit/";
  static String assetsPrefix = "assets/audios/";
  static String callerRingName = "phone_dialing.mp3";
  static String calledRingName = "phone_ringing.mp3";

  static Future<void> startRing() async {
    final String tempDirectory = await getTempDirectory();
    String filePath = "$tempDirectory/$callerRingName";
    String assetsName = callerRingName;
    if (TUICallRole.called == CallState.instance.selfUser.callRole) {
      if (CallState.instance.enableMuteMode) {
        return;
      }
      filePath = "$tempDirectory/$calledRingName";
      assetsName = calledRingName;
    }
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData =
          await loadAsset('$package$pluginName$assetsPrefix$assetsName');
      await file.create();
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    TUICallKitPlatform.instance.startRing(file.path);
  }

  static Future<void> stopRing() async {}

  //path: The format of the path parameter in the plugin is 'package$pluginName$assetsPrefix$assetsName'
  @visibleForTesting
  static Future<ByteData> loadAsset(String path) => rootBundle.load(path);

  @visibleForTesting
  static Future<String> getTempDirectory() async =>
      (await getTemporaryDirectory()).path;
}
