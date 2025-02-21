package com.tencent.cloud.tuikit.flutter.tuicallkit;

import android.content.Context;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.engine.call.TUICallDefine;
import com.tencent.cloud.tuikit.engine.call.TUICallEngine;
import com.tencent.cloud.tuikit.engine.call.TUICallObserver;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.ObjectParse;
import com.tencent.cloud.tuikit.flutter.tuicallkit.view.videoview.PlatformVideoViewFactory;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.Logger;
import com.tencent.cloud.tuikit.flutter.tuicallkit.utils.MethodCallUtils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * TUICallEnginePlugin
 */
public class TUICallEngineHandler {
    private MethodChannel            channel;
    private Context                  mApplicationContext;
    private PlatformVideoViewFactory mVideoViewFactory;

    public TUICallEngineHandler(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuicall_kit_engine");

        mApplicationContext = flutterPluginBinding.getApplicationContext();
        mVideoViewFactory = new PlatformVideoViewFactory(flutterPluginBinding.getBinaryMessenger());
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(PlatformVideoViewFactory.SIGN,
                mVideoViewFactory);

        channel.setMethodCallHandler((call, result) -> {
            try {
                Method method = TUICallEngineHandler.class.getDeclaredMethod(call.method, MethodCall.class,
                        Result.class);
                method.invoke(this, call, result);
            } catch (NoSuchMethodException e) {
                Logger.error(TUICallKitPlugin.TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
                result.notImplemented();
            } catch (IllegalAccessException e) {
                Logger.error(TUICallKitPlugin.TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            } catch (Exception e) {
                Logger.error(TUICallKitPlugin.TAG, "|method=" + call.method + "|arguments=" + call.arguments + "|error=" + e);
            }
        });
    }

    public void removeMethodCallHandler() {
        channel.setMethodCallHandler(null);
    }

    public void addObserver(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).addObserver(mTUICallObserver);
        result.success("");
    }

    public void removeObserver(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).removeObserver(mTUICallObserver);
        result.success("");
    }

    public void setVideoEncoderParams(MethodCall call, Result result) {
        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICommonDefine.VideoEncoderParams encoderParams = ObjectParse.getVideoEncoderParamsByMap(paramsMap);

        TUICallEngine.createInstance(mApplicationContext).setVideoEncoderParams(encoderParams, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "setVideoEncoderParams Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void setVideoRenderParams(MethodCall call, Result result) {
        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICommonDefine.VideoRenderParams params = ObjectParse.getVideoRenderParamsByMap(paramsMap);

        String userId = MethodCallUtils.getMethodParams(call, "userId");

        TUICallEngine.createInstance(mApplicationContext).setVideoRenderParams(userId, params,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "setVideoRenderParams Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void hangup(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).hangup(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "hangup Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void init(MethodCall call, Result result) {
        int sdkAppID = MethodCallUtils.getMethodParams(call, "sdkAppID");
        String userId = MethodCallUtils.getMethodParams(call, "userId");
        String userSig = MethodCallUtils.getMethodParams(call, "userSig");
        TUICallEngine.createInstance(mApplicationContext).init(sdkAppID, userId, userSig, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "init Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void unInit(MethodCall call, Result result) {
        TUICallEngine.destroyInstance();
        result.success(0);
    }

    public void calls(MethodCall call, Result result) {
        List<String> userIdList = MethodCallUtils.getMethodParams(call, "userIdList");
        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "mediaType", result);
        TUICallDefine.MediaType mediaType = ObjectParse.getMediaType(mediaTypeIndex);

        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICallDefine.CallParams params = ObjectParse.getTUICallParamsByMap(paramsMap);

        TUICallEngine.createInstance(mApplicationContext).calls(userIdList, mediaType, params, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "calls Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void call(MethodCall call, Result result) {
        String userId = MethodCallUtils.getMethodRequiredParams(call, "userId", result);

        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "mediaType", result);
        TUICallDefine.MediaType mediaType = ObjectParse.getMediaType(mediaTypeIndex);

        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICallDefine.CallParams params = ObjectParse.getTUICallParamsByMap(paramsMap);

        TUICallEngine.createInstance(mApplicationContext).call(userId, mediaType, params, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "call Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });

    }

    public void groupCall(MethodCall call, Result result) {
        String groupId = MethodCallUtils.getMethodParams(call, "groupId");
        List<String> userIdList = MethodCallUtils.getMethodParams(call, "userIdList");

        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "mediaType", result);
        TUICallDefine.MediaType mediaType = ObjectParse.getMediaType(mediaTypeIndex);

        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICallDefine.CallParams params = ObjectParse.getTUICallParamsByMap(paramsMap);

        TUICallEngine.createInstance(mApplicationContext).groupCall(groupId, userIdList, mediaType, params,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "groupCall Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void accept(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).accept(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                result.error("" + code, message, "");
            }
        });
    }

    public void reject(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).reject(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "reject Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }


    public void ignore(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).ignore(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "ignore Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void iniviteUser(MethodCall call, Result result) {
        List<String> userIdList = MethodCallUtils.getMethodParams(call, "userIdList");
        Map paramsMap = MethodCallUtils.getMethodParams(call, "params");
        TUICallDefine.CallParams params = ObjectParse.getTUICallParamsByMap(paramsMap);

        TUICallEngine.createInstance(mApplicationContext).inviteUser(userIdList, params, new TUICommonDefine.ValueCallback() {
            @Override
            public void onSuccess(Object userIdList) {
                result.success(userIdList);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "iniviteUser Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void join(MethodCall call, Result result) {
        String callId = MethodCallUtils.getMethodParams(call, "callId");
        if (callId == null) {
            result.error("-1", "callId is empty", "");
            return;
        }

        TUICallEngine.createInstance(mApplicationContext).join(callId, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "join Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void joinInGroupCall(MethodCall call, Result result) {
        Map roomIdMap = MethodCallUtils.getMethodParams(call, "roomId");
        TUICommonDefine.RoomId roomId = ObjectParse.getRoomIdByMap(roomIdMap);
        if (roomId == null) {
            result.error("-1", "roomId is empty", "");
            return;
        }

        String groupId = MethodCallUtils.getMethodParams(call, "groupId");

        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "mediaType", result);
        TUICallDefine.MediaType mediaType = ObjectParse.getMediaType(mediaTypeIndex);

        TUICallEngine.createInstance(mApplicationContext).joinInGroupCall(roomId, groupId, mediaType,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "joinInGroupCall Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void switchCallMediaType(MethodCall call, Result result) {
        int mediaTypeIndex = MethodCallUtils.getMethodRequiredParams(call, "mediaType", result);
        TUICallDefine.MediaType mediaType = ObjectParse.getMediaType(mediaTypeIndex);

        TUICallEngine.createInstance(mApplicationContext).switchCallMediaType(mediaType);
        result.success(0);
    }

    public void startRemoteView(MethodCall call, Result result) {
        String userId = MethodCallUtils.getMethodParams(call, "userId");
        int viewId = MethodCallUtils.getMethodParams(call, "viewId");

        TUIVideoView videoView = (TUIVideoView) PlatformVideoViewFactory.mVideoViewMap.get(viewId).getView();
        TUICallEngine.createInstance(mApplicationContext).startRemoteView(userId, videoView, new TUICommonDefine.PlayCallback() {
            @Override
            public void onPlaying(String userId) {

            }

            @Override
            public void onLoading(String userId) {

            }

            @Override
            public void onError(String userId, int code, String message) {
                Logger.error(TUICallKitPlugin.TAG,
                        "startRemoteView Error{ code:" + code + ",message:" + message + ",userId:" + userId + "}");
            }
        });
        result.success(0);
    }

    public void stopRemoteView(MethodCall call, Result result) {
        String userId = MethodCallUtils.getMethodParams(call, "userId");

        TUICallEngine.createInstance(mApplicationContext).stopRemoteView(userId);
        result.success(0);
    }

    public void openCamera(MethodCall call, Result result) {
        int cameraIndex = MethodCallUtils.getMethodParams(call, "camera");
        TUICommonDefine.Camera camera = ObjectParse.getCameraType(cameraIndex);

        int viewId = MethodCallUtils.getMethodParams(call, "viewId");

        TUIVideoView videoView = (TUIVideoView) PlatformVideoViewFactory.mVideoViewMap.get(viewId).getView();
        TUICallEngine.createInstance(mApplicationContext).openCamera(camera, videoView,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        Log.i(TUICallKitPlugin.TAG, "openCamera success");
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "openCamera Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void closeCamera(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).closeCamera();
        result.success(0);
    }

    public void switchCamera(MethodCall call, Result result) {
        int cameraIndex = MethodCallUtils.getMethodParams(call, "camera");
        TUICommonDefine.Camera camera = ObjectParse.getCameraType(cameraIndex);

        TUICallEngine.createInstance(mApplicationContext).switchCamera(camera);
        result.success(0);
    }

    public void openMicrophone(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).openMicrophone(new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "openMicrophone Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void closeMicrophone(MethodCall call, Result result) {
        TUICallEngine.createInstance(mApplicationContext).closeMicrophone();
        result.success(0);
    }

    public void selectAudioPlaybackDevice(MethodCall call, Result result) {
        int audioPlaybackDeviceIndex = MethodCallUtils.getMethodParams(call, "device");
        TUICommonDefine.AudioPlaybackDevice audioPlaybackDevice = ObjectParse.getAudioPlaybackDeviceType(audioPlaybackDeviceIndex);

        TUICallEngine.createInstance(mApplicationContext).selectAudioPlaybackDevice(audioPlaybackDevice);
        result.success(0);
    }

    public void setSelfInfo(MethodCall call, Result result) {
        String nickname = MethodCallUtils.getMethodParams(call, "nickname");
        String avatar = MethodCallUtils.getMethodParams(call, "avatar");

        TUICallEngine.createInstance(mApplicationContext).setSelfInfo(nickname, avatar, new TUICommonDefine.Callback() {
            @Override
            public void onSuccess() {
                result.success(0);
            }

            @Override
            public void onError(int code, String message) {
                Logger.error(TUICallKitPlugin.TAG, "setSelfInfo Error{ code:" + code + ",message:" + message + "}");
                result.error("" + code, message, "");
            }
        });
    }

    public void enableMultiDeviceAbility(MethodCall call, Result result) {
        boolean enable = MethodCallUtils.getMethodParams(call, "enable");

        TUICallEngine.createInstance(mApplicationContext).enableMultiDeviceAbility(enable,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "enableMultiDeviceAbility Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void queryRecentCalls(MethodCall call, Result result) {
        Map map = MethodCallUtils.getMethodParams(call, "filter");
        TUICallDefine.RecentCallsFilter filter = ObjectParse.getRecentCallsFilterByMap(map);

        TUICallEngine.createInstance(mApplicationContext).queryRecentCalls(filter,
                new TUICommonDefine.ValueCallback() {
                    @Override
                    public void onSuccess(Object recordList) {
                        List<Map> list = new ArrayList<>();
                        if (recordList != null && recordList instanceof List) {
                            List<TUICallDefine.CallRecords> records = (List<TUICallDefine.CallRecords>) recordList;
                            for (TUICallDefine.CallRecords record : records) {
                                list.add(ObjectParse.getCallRecordsMap(record));
                            }
                        }
                        result.success(list);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "queryRecentCalls Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void deleteRecordCalls(MethodCall call, Result result) {
        List<String> callIdList = MethodCallUtils.getMethodParams(call, "callIdList");

        TUICallEngine.createInstance(mApplicationContext).deleteRecordCalls(callIdList,
                new TUICommonDefine.ValueCallback() {
                    @Override
                    public void onSuccess(Object deleteList) {
                        result.success(deleteList);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "deleteRecordCalls Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }


    public void setBeautyLevel(MethodCall call, Result result) {
        float level = MethodCallUtils.getMethodParams(call, "level");

        TUICallEngine.createInstance(mApplicationContext).setBeautyLevel(level,
                new TUICommonDefine.Callback() {

                    @Override
                    public void onSuccess() {
                        result.success(0);
                    }

                    @Override
                    public void onError(int code, String message) {
                        Logger.error(TUICallKitPlugin.TAG, "setBeautyLevel Error{ code:" + code + ",message:" + message + "}");
                        result.error("" + code, message, "");
                    }
                });
    }

    public void setBlurBackground(MethodCall call, Result result) {
        int level = MethodCallUtils.getMethodParams(call, "level");
        TUICallEngine.createInstance(mApplicationContext).setBlurBackground(level,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(int i, String s) {
                        Logger.error(TUICallKitPlugin.TAG, "setBlurBackground Error{ code:" + i + ",message:" + s + "}");
                        result.error("" + i, s, "");
                    }
                });
    }

    public void setVirtualBackground(MethodCall call, Result result) {
        String imagePath = MethodCallUtils.getMethodParams(call, "imagePath");

        TUICallEngine.createInstance(mApplicationContext).setVirtualBackground(imagePath,
                new TUICommonDefine.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(int i, String s) {
                        Logger.error(TUICallKitPlugin.TAG, "setVirtualBackground Error{ code:" + i + ",message:" + s + "}");
                        result.error("" + i, s, "");
                    }
                });
    }

    public void callExperimentalAPI(MethodCall call, Result result) {
        Map jsonMap = MethodCallUtils.getMethodParams(call, "jsonMap");

        TUICallEngine.createInstance(mApplicationContext).callExperimentalAPI(new Gson().toJson(jsonMap));
        result.success(0);
    }


    private TUICallObserver mTUICallObserver = new TUICallObserver() {
        @Override
        public void onError(int code, String message) {
            invokeObserverMethod("onError", new HashMap<String, Object>() {{
                put("code", code);
                put("message", message);
            }});
        }

        @Override
        public void onCallReceived(String callerId, List<String> calleeIdList, String groupId,
                                   TUICallDefine.MediaType callMediaType, String userData) {
            invokeObserverMethod("onCallReceived", new HashMap<String, Object>() {{
                put("callerId", callerId);
                put("calleeIdList", calleeIdList);
                put("groupId", groupId);
                put("callMediaType", callMediaType.ordinal());
                put("userData", userData);
            }});
        }

        @Override
        public void onCallCancelled(String callerId) {
            invokeObserverMethod("onCallCancelled", new HashMap<String, Object>() {{
                put("callerId", callerId);
            }});
        }

        @Override
        public void onCallBegin(TUICommonDefine.RoomId roomId, TUICallDefine.MediaType callMediaType,
                                TUICallDefine.Role callRole) {
            Map roomIdMap = new HashMap() {
                {
                    put("intRoomId", roomId.intRoomId);
                    put("strRoomId", roomId.strRoomId);
                }
            };
            invokeObserverMethod("onCallBegin", new HashMap<String, Object>() {{
                put("roomId", roomIdMap);
                put("callMediaType", callMediaType.ordinal());
                put("callRole", callRole.ordinal());
            }});
        }

        @Override
        public void onCallEnd(TUICommonDefine.RoomId roomId, TUICallDefine.MediaType callMediaType,
                              TUICallDefine.Role callRole, long totalTime) {

            Map roomIdMap = new HashMap() {
                {
                    put("intRoomId", roomId.intRoomId);
                    put("strRoomId", roomId.strRoomId);
                }
            };
            invokeObserverMethod("onCallEnd", new HashMap<String, Object>() {{
                put("roomId", roomIdMap);
                put("callMediaType", callMediaType.ordinal());
                put("callRole", callRole.ordinal());
                put("totalTime", (double) totalTime);
            }});
        }

        @Override
        public void onCallMediaTypeChanged(TUICallDefine.MediaType oldCallMediaType,
                                           TUICallDefine.MediaType newCallMediaType) {
            invokeObserverMethod("onCallMediaTypeChanged", new HashMap<String, Object>() {{
                put("oldCallMediaType", oldCallMediaType.ordinal());
                put("newCallMediaType", newCallMediaType.ordinal());
            }});
        }

        @Override
        public void onUserReject(String userId) {
            invokeObserverMethod("onUserReject", new HashMap<String, Object>() {{
                put("userId", userId);
            }});
        }

        @Override
        public void onUserNoResponse(String userId) {
            invokeObserverMethod("onUserNoResponse", new HashMap<String, Object>() {{
                put("userId", userId);
            }});
        }

        @Override
        public void onUserLineBusy(String userId) {
            invokeObserverMethod("onUserLineBusy", new HashMap<String, Object>() {{
                put("userId", userId);
            }});
        }

        @Override
        public void onUserJoin(String userId) {
            invokeObserverMethod("onUserJoin", new HashMap<String, Object>() {{
                put("userId", userId);
            }});
        }

        @Override
        public void onUserLeave(String userId) {
            invokeObserverMethod("onUserLeave", new HashMap<String, Object>() {{
                put("userId", userId);
            }});
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
            invokeObserverMethod("onUserVideoAvailable", new HashMap<String, Object>() {{
                put("userId", userId);
                put("isVideoAvailable", isVideoAvailable);
            }});
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isAudioAvailable) {
            invokeObserverMethod("onUserAudioAvailable", new HashMap<String, Object>() {{
                put("userId", userId);
                put("isAudioAvailable", isAudioAvailable);
            }});
        }

        @Override
        public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
            invokeObserverMethod("onUserVoiceVolumeChanged", new HashMap<String, Object>() {{
                put("volumeMap", volumeMap);
            }});
        }

        @Override
        public void onUserNetworkQualityChanged(List<TUICommonDefine.NetworkQualityInfo> networkQualityList) {

            List<Map> networkQualityMapList = new ArrayList<>();
            for (int i = 0; i < networkQualityList.size(); i++) {
                TUICommonDefine.NetworkQualityInfo networkQualityItem = networkQualityList.get(i);

                networkQualityMapList.add(new HashMap<String, Object>() {{
                    put("userId", networkQualityItem.userId);
                    put("networkQuality", networkQualityItem.quality.ordinal());
                }});

            }

            invokeObserverMethod("onUserNetworkQualityChanged", new HashMap<String, Object>() {{
                put("networkQualityList", networkQualityMapList);
            }});
        }

        @Override
        public void onKickedOffline() {
            invokeObserverMethod("onKickedOffline", new HashMap<String, Object>() {{
            }});
        }

        @Override
        public void onUserSigExpired() {
            invokeObserverMethod("onUserSigExpired", new HashMap<String, Object>() {{
            }});
        }
    };

    private void invokeObserverMethod(String method, Map params) {
        Map arguments = new HashMap();
        arguments.put("method", method);
        if (params != null && params.size() != 0) {
            arguments.put("params", params);
        }
        channel.invokeMethod("onTUICallObserver", arguments);
    }

    private void invokeMethodCallback(String method, Map params) {
        Map arguments = new HashMap();
        arguments.put("method", method);
        if (params != null && params.size() != 0) {
            arguments.put("params", params);
        }
        channel.invokeMethod("onMethodCallback", arguments);
    }
}
