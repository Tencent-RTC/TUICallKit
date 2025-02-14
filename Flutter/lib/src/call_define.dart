class TUIValueCallback {
  const TUIValueCallback({this.onSuccess, this.onError});

  final void Function(Object? data)? onSuccess;
  final void Function(int code, String message)? onError;
}

class TUICallDefine {
  static const String version = "0.0.0.0";
}

/// Indicates the error code during the calls.
///
class TUICallError {
  /// You have not purchased the calls capability package, please go to the IM console to activate the free experience or purchase the official version.
  static const int errorPackageNotPurchased = -1001;

  /// The calls capability package you currently purchased does not support this function. It is recommended that you upgrade the package type.
  static const int errorPackageNotSupported = -1002;
}

/// Indicates the media room id of the calls.
///
class TUIRoomId {
  int intRoomId;
  String strRoomId;

  TUIRoomId({required this.intRoomId, required this.strRoomId});

  TUIRoomId.intRoomId({required this.intRoomId}) : strRoomId = '';

  TUIRoomId.strRoomId({required this.strRoomId}) : intRoomId = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['intRoomId'] = intRoomId;
    data['strRoomId'] = strRoomId;
    return data;
  }
}

/// Indicates the media type of the calls.
///
enum TUICallMediaType {
  /// 0: Default value, unknown media type,
  none,

  /// 1: Audio calls
  audio,

  /// 2: Video calls
  video
}

/// Indicates the role in the calls.
///
enum TUICallRole {
  /// 0: Default value, no role.
  none,

  /// 1: Caller, the member who initiated the calls.
  caller,

  /// 2: Called, the member invited to the calls.
  called
}

/// Indicates the calls status
///
enum TUICallStatus {
  /// 0: Default value, Idle state.
  none,

  /// 1: Waiting accept/reject state.
  waiting,

  /// 2: In calling state.
  accept
}

/// Indicates the call scene, including 1v1 calls, group calls etc.
enum TUICallScene {
  /// 0: 1v1 calls.
  singleCall,

  /// 1: Group call.
  /// notes: you need to create an IM group in advance
  groupCall,
}

enum TUICamera {
  front,
  back,
}

enum TUIAudioPlaybackDevice {
  speakerphone,
  earpiece,
}

enum TUICallResultType {
  unknown,
  missed,
  incoming,
  outgoing,
}

/// network quality
enum TUINetworkQuality {
  /// 0: unknow
  unknown,

  /// 1: excellent
  excellent,

  /// 2: good
  good,

  /// 3: poor
  poor,

  /// 4: bad
  bad,

  /// 5: vBad
  vBad,

  /// 6: down
  down,
}

enum FillMode {
  /// 0, Filling mode: the content of the screen will be centered and scaled proportionally
  /// to fill the entire display area, and the part beyond the display area will be cropped,
  /// and the screen may be incomplete in this mode.
  fill,

  /// 1, Adaptive mode: scale according to the long side of the screen to fit the display area,
  /// and the short side will be filled with black. In this mode, the image is complete
  /// but there may be black borders.
  fit,
}

enum Rotation {
  rotation_0,
  rotation_90,
  rotation_180,
  rotation_270,
}

class VideoRenderParams {
  FillMode fillMode;

  Rotation rotation;

  VideoRenderParams({required this.fillMode, required this.rotation});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fillMode'] = fillMode.index;
    data['rotation'] = rotation.index;
    return data;
  }
}

enum ResolutionMode {
  /// 0, Landscape resolution,For example：Resolution_640_360 + Landscape = 640x360。
  landscape,

  /// 1, Portrait resolution,For example：Resolution_640_360 + Portrait = 360x640。
  portrait,
}

enum Resolution {
  /// aspect ratio 16:9；resolution 640x360；Recommended code rate（VideoCall）500kbps。
  resolution_640_360,

  /// aspect ratio 16:9；resolution 960x540；Recommended code rate（VideoCall）850kbps。
  resolution_960_540,

  /// aspect ratio 16:9；resolution 1280x720；Recommended code rate（VideoCall）1200kbps。
  resolution_1280_720,

  /// aspect ratio 16:9；resolution 1920x1080；Recommended code rate（VideoCall）2000kbps。
  resolution_1920_1080,
}

enum TUICallIOSOfflinePushType {
  /// Normal APNs push
  APNs,  // ignore: constant_identifier_names

  /// VoIP push
  VoIP,  // ignore: constant_identifier_names
}

/// Video encoding parameters
class VideoEncoderParams {
  Resolution resolution;

  ResolutionMode resolutionMode;

  VideoEncoderParams({required this.resolution, required this.resolutionMode});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resolution'] = resolution.index;
    data['resolutionMode'] = resolutionMode.index;
    return data;
  }
}

/// network quality info
class TUINetworkQualityInfo {
  /// user id
  String userId;

  /// network quality
  TUINetworkQuality quality;

  TUINetworkQualityInfo({required this.userId, required this.quality});
}

/// Generic function return type
class TUIResult {
  String code;
  String? message;

  TUIResult({
    required this.code,
    required this.message,
  });
}

class TUICallParams {
  TUIRoomId? roomId;
  TUIOfflinePushInfo? offlinePushInfo;
  int? timeout;
  String? userData;
  String? chatGroupId;

  TUICallParams();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomId'] = roomId?.toJson();
    data['offlinePushInfo'] = offlinePushInfo?.toJson();
    data['timeout'] = timeout;
    data['userData'] = userData;
    data['chatGroupId'] = chatGroupId;
    return data;
  }
}

class TUIOfflinePushInfo {
  String? title;
  String? desc;
  bool? ignoreIOSBadge;
  String? iOSSound;
  String? androidSound;
  String? androidOPPOChannelID;
  int? androidVIVOClassification;
  String? androidXiaoMiChannelID;
  String? androidFCMChannelID;
  String? androidHuaWeiCategory;
  bool? isDisablePush;
  TUICallIOSOfflinePushType? iOSPushType;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['desc'] = desc;
    data['ignoreIOSBadge'] = ignoreIOSBadge;
    data['iOSSound'] = iOSSound;
    data['androidSound'] = androidSound;
    data['androidOPPOChannelID'] = androidOPPOChannelID;
    data['androidVIVOClassification'] = androidVIVOClassification;
    data['androidXiaoMiChannelID'] = androidXiaoMiChannelID;
    data['androidFCMChannelID'] = androidFCMChannelID;
    data['androidHuaWeiCategory'] = androidHuaWeiCategory;
    data['isDisablePush'] = isDisablePush;
    data['iOSPushType'] = iOSPushType?.index;
    return data;
  }
}

class TUICallRecords {
  String? callId;
  String? inviter;
  List<String>? inviteList;
  TUICallScene? scene;
  TUICallMediaType? mediaType;
  String? groupId;
  TUICallRole? role;
  TUICallResultType? result;
  int? beginTime;
  int? totalTime;
}

class TUICallRecentCallsFilter {
  double? begin;
  double? end;
  TUICallResultType resultType = TUICallResultType.unknown;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['begin'] = begin;
    data['end'] = end;
    data['resultType'] = resultType.index;
    return data;
  }
}
