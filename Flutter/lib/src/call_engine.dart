import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_calls_uikit/src/platform/call_engine_platform_interface.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/call_observer.dart';
import 'package:tencent_calls_uikit/src/utils/utils.dart';

class TUICallEngine extends PlatformInterface {
  TUICallEngine() : super(token: _token);

  static final Object _token = Object();

  static TUICallEngine _instance = TUICallEngine();

  static TUICallEngine get instance => _instance;

  static set instance(TUICallEngine instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the SDK function, please call the function before using all the features to complete the initialization of the call service verification.
  ///
  /// @param sdkAppID  App ID
  /// @param userId    The ID of the current user
  /// @param userSig   Safety protection signature
  /// return TUIResult
  Future<TUIResult> init(int sdkAppID, String userId, String userSig) async {
    _setFramework();
    return await TUICallEnginePlatform.instance.init(sdkAppID, userId, userSig);
  }

  Future<TUIResult> unInit() async {
    return await TUICallEnginePlatform.instance.unInit();
  }

  Future<void> addObserver(TUICallObserver observer) async {
    await TUICallEnginePlatform.instance.addObserver(observer);
  }

  Future<void> removeObserver(TUICallObserver observer) async {
    await TUICallEnginePlatform.instance.removeObserver(observer);
  }

  /// Set the encoding parameters of the video encoder
  /// This setting can determine the image quality seen by the remote user,
  /// as well as the image quality of the video files recorded in the cloud.
  ///
  /// @param params   Encoding parameters: screen resolution, video aspect ratio mode
  /// @param callback result callback
  ///
  Future<TUIResult> setVideoEncoderParams(VideoEncoderParams params) async {
    return await TUICallEnginePlatform.instance.setVideoEncoderParams(params);
  }

  ///
  /// Set the rendering mode of the user screen
  ///
  /// @param userId   userid
  /// @param params   Screen rendering parameters: screen rotation angle, fill mode
  /// @param callback result callback
  ///
  Future<TUIResult> setVideoRenderParams(
      String userId, VideoRenderParams params) async {
    return await TUICallEnginePlatform.instance
        .setVideoRenderParams(userId, params);
  }

  ///
  /// Hangup
  ///
  /// @param callback result callback
  ///
  Future<TUIResult> hangup() async {
    return await TUICallEnginePlatform.instance.hangup();
  }

  /// Make a call
  ///
  /// @param userIdList    List of userId
  /// @param callMediaType Call type
  /// @param params        Call extension parameters
  Future<TUIResult> calls(
      List<String> userIdList, TUICallMediaType mediaType, TUICallParams params) async {
    return await TUICallEnginePlatform.instance.calls(userIdList, mediaType, params);
  }

  /// Call (1v1 call)
  ///
  /// @param roomId        The audio and video room ID of this call
  /// @param userId        Userid of the target user
  /// @param callMediaType Call media types, such as: video calls, voice calls
  /// @param params        Call parameter extension fields, for example: offline push custom content
  /// return TUIResult
  @Deprecated("This interface has been deprecated. It is recommended to use the calls interface.")
  Future<TUIResult> call(
      String userId, TUICallMediaType mediaType, TUICallParams params) async {
    return await TUICallEnginePlatform.instance.call(userId, mediaType, params);
  }

  /// To initiate group calls, note that you need to create an IM group before using group calls. If it has been created, please ignore it;
  ///
  /// @param roomId        The audio and video room ID of this call
  /// @param groupId       Group ID of this group call
  /// @param userIdList    Userid list of target users
  /// @param callMediaType Call media types, such as: video calls, voice calls
  /// @param params        Call parameter extension fields, for example: offline push custom content
  /// return TUIResult
  @Deprecated("This interface has been deprecated. It is recommended to use the calls interface.")
  Future<TUIResult> groupCall(String groupId, List<String> userIdList,
      TUICallMediaType mediaType, TUICallParams params) async {
    return await TUICallEnginePlatform.instance
        .groupCall(groupId, userIdList, mediaType, params);
  }

  /// After receiving the current call, when you call the callback as an oncallReceived (), you can call the function to answer the call.
  ///
  /// return TUIResult
  Future<TUIResult> accept() async {
    return await TUICallEnginePlatform.instance.accept();
  }

  /// Reject the current call, when you call the callback as an oncallReceived (), you can call the function to refuse the call.
  ///
  /// return TUIResult
  Future<TUIResult> reject() async {
    return await TUICallEnginePlatform.instance.reject();
  }

  /// Ignore the current call. When you call the callback as an oncallReceived (), you can call the function to ignore the call.
  ///
  /// return TUIResult
  Future<TUIResult> ignore() async {
    return await TUICallEnginePlatform.instance.ignore();
  }

  /// Invite users to join the group call.
  /// Use scene: users in a group call actively invite others to use.
  ///
  /// @param userIdList Userid list of target users
  /// @param params     Call parameter extension fields, for example: offline push custom content
  /// return TUIResult
  Future<void> iniviteUser(List<String> userIdList, TUICallParams params,
      TUIValueCallback callback) async {
    return await TUICallEnginePlatform.instance
        .iniviteUser(userIdList, params, callback);
  }

  /// Join a current call
  ///
  /// @param callId        Unique ID for this call
  Future<TUIResult> join(String callId) async {
    return await TUICallEnginePlatform.instance.join(callId);
  }

  /// Take the initiative to join the group call.
  /// Use scenario: users in the group actively join the group call for use.
  ///
  /// @param roomId        The audio and video room ID of this call
  /// @param groupId       Group ID of this group call
  /// @param callMediaType Call media types, such as: video calls, voice calls
  /// return TUIResult
  @Deprecated("This interface has been deprecated. It is recommended to use the join interface.")
  Future<TUIResult> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType mediaType) async {
    return await TUICallEnginePlatform.instance
        .joinInGroupCall(roomId, groupId, mediaType);
  }

  /// Switch the call media type, such as video call cutting audio calls
  ///
  /// @param newType Call media types, such as: video calls, voice calls
  Future<void> switchCallMediaType(TUICallMediaType mediaType) async {
    await TUICallEnginePlatform.instance.switchCallMediaType(mediaType);
  }

  /// Start subscription to remote user video stream
  ///
  /// @param userId    Userid of the target user
  /// @param viewId    Corresponding to the TRTCCloudVideoView of Native layer
  Future<void> startRemoteView(String userId, int? viewId) async {
    await TUICallEnginePlatform.instance.startRemoteView(userId, viewId);
  }

  /// Stop subscribe to remote user video stream
  ///
  /// @param userId Userid of the target user
  Future<void> stopRemoteView(String userId) async {
    await TUICallEnginePlatform.instance.stopRemoteView(userId);
  }

  /// Turn on the camera
  ///
  /// @param camera    Front/rear camera
  /// @param viewId    Corresponding to the TRTCCloudVideoView of Native layer
  /// return TUIResult
  Future<TUIResult> openCamera(TUICamera camera, int? viewId) async {
    return await TUICallEnginePlatform.instance.openCamera(camera, viewId);
  }

  /// Close the camera
  Future<void> closeCamera() async {
    await TUICallEnginePlatform.instance.closeCamera();
  }

  /// Switch the front and rear cameras
  ///
  /// @param camera Front/rear camera
  Future<void> switchCamera(TUICamera camera) async {
    await TUICallEnginePlatform.instance.switchCamera(camera);
  }

  /// Open the microphone
  ///
  /// return TUIResult
  Future<TUIResult> openMicrophone() async {
    return await TUICallEnginePlatform.instance.openMicrophone();
  }

  /// Close the microphone
  Future<void> closeMicrophone() async {
    await TUICallEnginePlatform.instance.closeMicrophone();
  }

  /// Select audio playback equipment
  ///
  /// @param device Headian/speaker
  Future<void> selectAudioPlaybackDevice(TUIAudioPlaybackDevice device) async {
    await TUICallEnginePlatform.instance.selectAudioPlaybackDevice(device);
  }

  /// Set the user's nickname and avatar
  ///
  /// @param nickname User's Nickname
  /// @param avatar   User avatar (format is URL)
  /// return TUIResult
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await TUICallEnginePlatform.instance.setSelfInfo(nickname, avatar);
  }

  /// Open/Close the multi -device login mode of TUICallEngine
  ///
  /// @param enable   true:YES; false:NO
  /// return TUIResult
  Future<TUIResult> enableMultiDeviceAbility(bool enable) async {
    return await TUICallEnginePlatform.instance
        .enableMultiDeviceAbility(enable);
  }

  /// Set beauty level
  ///
  /// @param level    Beauty level
  /// return TUIResult
  Future<TUIResult> setBeautyLevel(double level) async {
    return await TUICallEnginePlatform.instance.setBeautyLevel(level);
  }

  /// Set the blur effect level=0 close,1：low, 2:middle, 3:high
  void setBlurBackground(int level, Function(int code, String message)? errorCallback) async {
    TUICallEnginePlatform.instance.setBlurBackground(level, errorCallback);
  }

  /// Set the picture background effect ImagePath as empty, then turn off the effect; if it is not empty, the picture effect is displayed
  void setVirtualBackground(String imagePath, Function(int code, String message)? errorCallback) async {
    String path = await Utils.getAssetsFilePath(imagePath);
    TUICallEnginePlatform.instance.setVirtualBackground(path, errorCallback);
  }

  /// Call experimental interface
  ///
  /// @param jsonObject
  Future<void> callExperimentalAPI(Map<String, dynamic> jsonMap) async {
    await TUICallEnginePlatform.instance.callExperimentalAPI(jsonMap);
  }

  Future<void> queryRecentCalls(
      TUICallRecentCallsFilter filter, TUIValueCallback callback) async {
    await TUICallEnginePlatform.instance.queryRecentCalls(filter, callback);
  }

  Future<void> deleteRecordCalls(
      List<String> callIdList, TUIValueCallback callback) async {
    await TUICallEnginePlatform.instance.deleteRecordCalls(callIdList, callback);
  }

  _setFramework() async {
    await callExperimentalAPI({
      "api": "setFramework",
      "params": {
        "framework": 7,
        "component": 17,
        "language": 9,
      }
    });
  }
}
