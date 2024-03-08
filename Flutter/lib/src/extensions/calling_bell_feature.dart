import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/utils/preference_utils.dart';

class CallingBellFeature {
  static FileSystem fileSystem = const LocalFileSystem();
  static String keyRingPath = "key_ring_path";
  static String package = "packages/";
  static String pluginName = "tencent_calls_uikit/";
  static String assetsPrefix = "assets/audios/";
  static String callerRingName = "phone_dialing.mp3";
  static String calledRingName = "phone_ringing.mp3";

  static Future<void> startRing() async {
    TRTCLogger.info('CallingBellFeature startRing');
    String filePath = await PreferenceUtils.getInstance().getString(keyRingPath);
    if (filePath.isNotEmpty &&
        TUICallRole.called == CallState.instance.selfUser.callRole &&
        !CallState.instance.enableMuteMode) {
      TUICallKitPlatform.instance.startRing(filePath);
      return;
    }

    final String tempDirectory = await getTempDirectory();
    filePath = "$tempDirectory/$callerRingName";
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
      ByteData byteData = await loadAsset('$package$pluginName$assetsPrefix$assetsName');
      await file.create();
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    TUICallKitPlatform.instance.startRing(file.path);
  }

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

  static Future<void> stopRing() async {
    TRTCLogger.info('CallingBellFeature stopRing');
    TUICallKitPlatform.instance.stopRing();
  }

  //path: The format of the path parameter in the plugin is 'package$pluginName$assetsPrefix$assetsName'
  @visibleForTesting
  static Future<ByteData> loadAsset(String path) => rootBundle.load(path);

  @visibleForTesting
  static Future<String> getTempDirectory() async => (await getTemporaryDirectory()).path;
}
