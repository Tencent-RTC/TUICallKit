import 'package:tencent_calls_uikit/src/call_define.dart';

/// The TUICallObserver class.
/// TUICallObserver is used to observe TUICallEngine event that you are interested in.
///
class TUICallObserver {
  const TUICallObserver({
    this.onError,
    this.onCallReceived,
    this.onCallCancelled,
    this.onCallBegin,
    this.onCallEnd,
    this.onCallMediaTypeChanged,
    this.onUserReject,
    this.onUserNoResponse,
    this.onUserLineBusy,
    this.onUserJoin,
    this.onUserLeave,
    this.onUserVideoAvailable,
    this.onUserAudioAvailable,
    this.onUserVoiceVolumeChanged,
    this.onUserNetworkQualityChanged,
    this.onKickedOffline,
    this.onUserSigExpired,
  });

  /// An error occurred inside the SDK.
  ///
  /// [code] Error code
  /// [messgae]  Error message
  ///
  final void Function(int code, String message)? onError;

  /// Callback for receiving a call request (received only by the callee)
  ///
  /// [callerId]      Caller
  /// [calleeIdList]  List of callees
  /// [groupId]      GroupID
  /// [callMediaType] Call type，eg: audio、video
  /// [userData]      User-defined extension fields
  ///
  final void Function(String callerId, List<String> calleeIdList,
      String groupId, TUICallMediaType callMediaType, String? userData)? onCallReceived;

  /// A user who cancel the call
  /// [callerId]  User who cancel the call request
  final void Function(String callerId)? onCallCancelled;

  /// Call start(received by both caller and callee)
  ///
  /// [roomId]        Current call room ID
  /// [callMediaType] Call type，eg: audio、video
  /// [callRole]      Call role
  final void Function(TUIRoomId roomId, TUICallMediaType callMediaType,
      TUICallRole callRole)? onCallBegin;

  /// Call end(received by both caller and callee)
  ///
  /// [roomId]       Current call room ID
  /// [callMediaType] Call type，eg: audio、video
  /// [callRole ]     Call role
  /// [totalTime ]    Total time of the call
  final void Function(TUIRoomId roomId, TUICallMediaType callMediaType,
      TUICallRole callRole, double totalTime)? onCallEnd;

  /// call type change
  ///
  /// [oldCallMediaType] Old call type
  /// [newCallMediaType] New call type
  final void Function(
          TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType)?
      onCallMediaTypeChanged;

  /// A user who reject the call
  ///
  /// [userId] User who reject the call
  final void Function(String userId)? onUserReject;

  /// A user who did not answer the call
  ///
  /// [userId] User who did not answer the call
  final void Function(String userId)? onUserNoResponse;

  /// A user who is busy
  ///
  /// [userId] User who is busy
  final void Function(String onUserLineBusy)? onUserLineBusy;

  /// A user who join the call
  ///
  /// [userId] User who join the call
  final void Function(String userId)? onUserJoin;

  /// A user who leave the call
  ///
  /// [userId] User who leave the call
  final void Function(String userId)? onUserLeave;

  /// A remote user published/unpublished primary stream video
  ///
  /// [userId]           User ID of the remote user
  /// [isVideoAvailable] Whether the user published (or unpublished) primary stream video
  final void Function(String userId, bool isVideoAvailable)?
      onUserVideoAvailable;

  /// A remote user published/unpublished audio
  ///
  /// [userId]           User ID of the remote user
  /// [isAudioAvailable] Whether the user published (or unpublished) audio.
  final void Function(String userId, bool isAudioAvailable)?
      onUserAudioAvailable;

  /// All user volume change
  ///
  /// [volumeMap] The total volume of all users. Value range: 0-100
  final void Function(Map<String, int> volumeMap)? onUserVoiceVolumeChanged;

  /// Real-time network quality statistics
  ///
  /// [networkQualityList] All users Real-time network quality statistics
  final void Function(List<TUINetworkQualityInfo> networkQualityList)?
      onUserNetworkQualityChanged;

  /// The callback of the current user being kicked off, the user can be prompted on the UI at this time, and call init() function of TUICallEngine to log in again.
  ///
  final void Function()? onKickedOffline;

  /// The callback of the login credentials expired when online, you need to generate a new userSig and call init() function of TUICallEngine to log in again.
  ///
  final void Function()? onUserSigExpired;
}
