import 'package:tencent_calls_engine/tuicall_engine.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

void testSetVideoRenderParams(String userId) async {
  VideoRenderParams renderParams =
      VideoRenderParams(fillMode: FillMode.fill, rotation: Rotation.rotation_0);
  TUIResult result =
      await TUICallEngine.instance.setVideoRenderParams(userId, renderParams);
  if (result.code.isEmpty) {
    print("setVideoRenderParams Success");
  } else {
    print(
        "setVideoRenderParams Error code:${result.code}|message:${result.message}");
  }
}

void testSetVideoEncoderParams() async {
  VideoEncoderParams encoderParams = VideoEncoderParams(
      resolution: Resolution.resolution_960_720,
      resolutionMode: ResolutionMode.landscape);
  TUIResult result =
      await TUICallEngine.instance.setVideoEncoderParams(encoderParams);
  if (result.code.isEmpty) {
    print("setVideoEncoderParams Success");
  } else {
    print(
        "setVideoEncoderParams Error code:${result.code}|message:${result.message}");
  }
}
