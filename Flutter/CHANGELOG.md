## 1.9.2
## New Features
- iOS: Support Voip.
### Bug Fixes
- iOS: Fixed an issue where the call page would be abnormal when receiving a call in the background.

## 1.9.0
## New Features
- Android$iOS: Add an interface for setting ringtones.
### Function Optimization:
- Android & iOS: Optimize package purchasing prompts.
- Android & iOS: Optimize default bitrates for different resolutions, [see details](https://trtc.io/document/46660/51002/54904/54909).
### Bug Fixes
- iOS: Fixed the issue where the same Observer object can be registered twice.
### Dependency Description
- Upgrade the dependent client SDK version: Android&iOS TUICore:7.5.4852, Android&iOS TUICallEngine:1.9.0.680.

## 1.8.3
### Bug Fixes
- Android&iOS: Fixed the problem of no call message display when using tencent_cloud_chat_uikit.
- Android&iOS: Fixed the problem of occasionally pulling up the group call page during a single-person call.
- Android&iOS: Fixed the problem of occasionally pulling up the call page twice during a call.
- Android&iOS: Fixed the problem of abnormal display of call duration.
### Function Optimization:
- Android: Optimized the problem of failing to pull up the interface in the background when receiving a call.
### Dependency Description
- Upgrade tencent_cloud_uikit_core to version 1.1.1.

## 1.8.2
### Bug Fixes
- iOS: Fixed the problem of some compilers failing to compile due to the use of deprecated Swift interfaces.

## 1.8.1
### Bug Fixes
- Android&iOS: Fixed the problem of the video stream of the other party being displayed during a group call voice call.

## 1.8.0
## New Features
- Android&iOS: Built a new TUICallkit based on the Dart language, which makes it easier to customize your own UI style.
- Android&iOS: TUICallEngine adds multiple business interfaces such as hangup, accept, reject, etc.

## 1.7.6-preview
### Function Optimization:
- Android&iOS: Optimized the display of user information when the username and user avatar are not set.
- Android&iOS: Optimized the UI of one-to-one video calls.
### Bug Fixes:
- Android&iOS: Fixed the problem of abnormal pages generated when logging out during a call.
- Android: Fixed the problem of abnormal pages generated when kicked offline during a call.

## 1.7.5-preview
### New Features
- Android&iOS: Built a new TUICallkit based on the Dart language, which makes it easier to customize your own UI style.
- Android&iOS: TUICallEngine adds multiple business interfaces such as hangup, accept, reject, etc.

## 1.7.4
### Function Optimization:
- Android: Gravity sensing is turned off by default, optimizing the call experience on large screens and customized devices.
### Bug Fixes:
- Android&iOS: When A calls B (offline) and cancels it, A calls B again, and B logs in and comes online, there is an abnormal problem with B's cloud call records.

## 1.7.3
### Function Optimization
- Android: Supports development and debugging using emulators.
### Dependency Description
- Upgrade the dependent client SDK version: Android LiteAVSDK_Professional: 11.3.0.13176.

## 1.7.2
### Bug Fixes
- iOS: Upgrade the client SDK version to fix the problem of AppStore rejection due to Non-public API usage.

## 1.7.1
### New Features
- Android&iOS: Added cloud call records, you can open the service in the console to experience the query.
### Function Optimization
- Android: Lower the level of system keep-alive during the call, only display the keep-alive prompt in the status bar, and remove the notification and vibration.

## 1.6.3
### Bug Fixes:
- iOS: Fixed the problem of an empty page when adding a participant during a call after calling joinInGroupCall.
- iOS: Fixed the problem of user screen being covered after calling joinInGroupCall.

## 1.6.2
### Bug Fixes:
- Android: Fixed the crash problem caused by calling the joinInGroupCall API.

## 1.6.1
### Bug Fixes
- iOS: Fixed the problem of an empty midway page after calling joinInGroupCall.
- iOS: Fixed the problem of user screen blocking after calling joinInGroupCall.

## 1.6.0
### New Features
- Android&iOS: Added the hangup interface.
- Android&iOS: Added user-defined fields and user-defined call timeout duration.
- Android&iOS: Added a midway page for group calls.
### Function Optimization
- Android: Optimized the display of single-person video call avatars.
- Android&iOS: In group calls, inviting other group members to join the call is supported by default.
### Bug Fixes
- Android: Fixed the problem of no sound after connecting to Bluetooth on Android 12 and above devices.
- Android: Fixed the problem of occasional failure of muting on the called end.
- iOS: Fixed the problem of occasional failure to receive incoming call invitations after re-logging in.
- iOS: Fixed the problem of incorrect display of the nickname on the VoIP push page.
### Dependency Description
- Upgrade the dependent client SDK version: Android LiteAVSDK_Professional: 11.1.0.13111, iOS TXLiteAVSDK_Professional: 11.1.14143.

## 1.5.4
### New Features
- iOS: Supports VoIP message push function, providing a better call answering experience.
- Android&iOS: Added advanced parameters for offline push of Xiaomi, Huawei, and VIVO.
- Android&iOS: Supports setting encoding resolution, picture direction, etc.
- Android&iOS: Supports setting rendering direction, rendering mode (adaptive, fill), etc.
### Function Optimization
- Android: Optimized the totaltime parameter unit to milliseconds in the onCallEnd callback.
### Bug Fixes
- Android&iOS: Fixed the abnormal problem of the onCallReceived callback.
- iOS: Fixed the problem of incomplete display of the call page when the screen is rotated.

## 1.5.3
### Bug Fixes
- Android: Fixed the packaging failure problem.
- Android&iOS: Fixed the problem of throwing an exception when the callback method is not implemented.

## 1.5.2
### Bug Fixes
- Android: Fixed the compilation error caused by the API change of TUICallDefine.OfflinePushInfo.

## 1.5.1
### Bug Fixes
- Android&iOS: Fixed the problem of incorrect version dependency of tencent_calls_engine.

## 1.5.0
### Function Optimization
- Android: The ear-to-ear screen function is turned off by default.
- Android: Upgrade the gradle plugin and version.
- Android: Optimized the ringtone playback class to support loop playback.
## Bug Fixes
- Android&iOS: Fixed the problem of no onCallCancel callback when the callee failed to answer the call.
- Android: Fixed the problem of the caller's exception when the callee failed to answer the call.
- Android: Fixed the problem of the callee's interface being called again when the caller cancels the call during the first call permission check and the callee pulls up the interface again.
- Android: Fixed the problem of the userId parameter being empty in the network quality callback to the upper layer.
- iOS: Fixed the problem of incorrect Observer registration timing in the Example.

## 1.4.2
### Bug Fixes
- Android&iOS: Fixed the problem of call exceptions caused by incorrect Observer registration timing in the Example.
- iOS: Fixed the problem of occasional invalid settings of the removeObserver API.

## 1.4.1
### Bug Fixes
- Android: Fixed the problem of the OnCallEnd event being lost after the call ends.

## 1.4.0
### Bug Fixes
- Android&iOS: Fixed the problem of call exceptions when actively joining a room (joinInGroupCall).
- Android: Fixed the problem of call status exceptions when the app is backgrounded during a call and then returned to the foreground.
- Android: Fixed the problem of call initiation failure caused by login status when integrating the tencent_cloud_chat_uikit plugin at the same time.
- Android: Fixed the problem of call initiation failure caused by parameter check issues during group call initiation.

## 1.3.1
### New Features
- Android&iOS: Supports custom offline push messages during calls.
### Bug Fixes
- Android: Fixed the problem of the sdkappid is invalid prompt when integrating the tencent_cloud_chat_uikit plugin at the same time.

## 1.3.0
### Function Optimization
- iOS: Optimized the TUICallKit framework size.
### Bug Fixes
- Android&iOS: Fixed the problem of the call interface not disappearing when the server dissolves the room or kicks out a user.
- Android: Fixed the problem of the call interface not displaying when A calls offline user B, cancels the call, and then calls B again after B comes online.

## 1.2.2
### Bug Fixes
- iOS: Fixed the compilation error caused by static library linking.

## 1.2.0
### New Features
- Android&iOS: Supports 1v1 audio and video calls and group audio and video calls.
- Android&iOS: Supports custom avatars and nicknames.
- Android&iOS: Supports setting custom ringtones.
- Android&iOS: Supports opening a floating window during a call.
- Android&iOS: Supports incoming call services under multiple platform login status.