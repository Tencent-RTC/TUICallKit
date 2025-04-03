import Flutter
import UIKit
import Flutter
import RTCRoomEngine

public class TUICallEngineHandler: NSObject {
    
    static let channelName = "tuicall_kit_engine"
    private let channel: FlutterMethodChannel
    
    init(registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: TUICallEngineHandler.channelName, binaryMessenger: registrar.messenger())
        
        super.init()

        self.channel.setMethodCallHandler({[weak self] call, result in
            guard let self = self else {
                result(FlutterError(code: "Error", message: "self is nil", details: nil))
                return
            }
            self.handle(call, result: result)
        })
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            initEngine(call: call, result: result)
            
        case "unInit":
            destroyInstance(call: call, result: result)

        case "addObserver":
            addObserver(call: call, result: result)
            
        case "removeAddObserver":
            removeObserver(call: call, result: result)
            
        case "setVideoEncoderParams":
            setVideoEncoderParams(call: call, result: result)
            
        case "setVideoRenderParams":
            setVideoRenderParams(call: call, result: result)
            
        case "hangup":
            hangup(call: call, result: result)
            
        case "calls":
            calls(call: call, result: result)
            
        case "call":
            singleCall(call: call, result: result)
            
        case "groupCall":
            groupCall(call: call, result: result)

        case "accept":
            accept(call: call, result: result)

        case "reject":
            reject(call: call, result: result)

        case "ignore":
            ignore(call: call, result: result)

        case "iniviteUser":
            iniviteUser(call: call, result: result)

        case "join":
            join(call: call, result: result)
            
        case "joinInGroupCall":
            joinInGroupCall(call: call, result: result)

        case "switchCallMediaType":
            switchCallMediaType(call: call, result: result)

        case "startRemoteView":
            startRemoteView(call: call, result: result)

        case "stopRemoteView":
            stopRemoteView(call: call, result: result)
            
        case "openCamera":
            openCamera(call: call, result: result)
            
        case "closeCamera":
            closeCamera(call: call, result: result)
            
        case "switchCamera":
            switchCamera(call: call, result: result)
            
        case "openMicrophone":
            openMicrophone(call: call, result: result)

        case "closeMicrophone":
            closeMicrophone(call: call, result: result)

        case "selectAudioPlaybackDevice":
            selectAudioPlaybackDevice(call: call, result: result)

        case "setSelfInfo":
            setSelfInfo(call: call, result: result)
            
        case "enableMultiDeviceAbility":
            enableMultiDeviceAbility(call: call, result: result)

        case "queryRecentCalls":
            queryRecentCalls(call: call, result: result)
            
        case "deleteRecordCalls":
            deleteRecordCalls(call: call, result: result)
            
        case "setBeautyLevel":
            setBeautyLevel(call: call, result: result)
            
        case "setBlurBackground":
            setBlurBackground(call: call, result: result)
            
        case "setVirtualBackground":
            setVirtualBackground(call: call, result: result)

        case "callExperimentalAPI":
            callExperimentalAPI(call: call, result: result)

        default: break
        }
    }
}

// MARK: TUICallEngine Method
extension TUICallEngineHandler {
    func initEngine(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let sdkAppId = MethodUtils.getMethodParams(call: call, key: "sdkAppID", resultType: Int32.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "initEngine", paramKey: "sdkAppID", result: result)
            return
        }
        
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "initEngine", paramKey: "userId", result: result)
            return
        }
        
        guard let userSig = MethodUtils.getMethodParams(call: call, key: "userSig", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "initEngine", paramKey: "userSig", result: result)
            return
        }

        TUICallEngine.createInstance().`init`(sdkAppId, userId: userId, userSig: userSig) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func destroyInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.destroyInstance()
    }

    func addObserver(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().addObserver(self)
    }
    
    func removeObserver(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().removeObserver(self)
    }
    
    func setVideoEncoderParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let params = TUIVideoEncoderParams()
        
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Int>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setVideoEncoderParams", paramKey: "params", result: result)
            return
        }
        
        if let modeIndex = paramsDic["resolutionMode"]  {
            if modeIndex == 0 {
                params.resolutionMode = .landscape
            } else if modeIndex == 1 {
                params.resolutionMode = .portrait
            }
        }
        
        if let resolutionIndex = paramsDic["resolution"] {
            switch resolutionIndex {
                case 0:
                    params.resolution = ._640_360
                case 1:
                    params.resolution = ._960_540
                case 2:
                    params.resolution = ._1280_720
                case 3:
                    params.resolution = ._1920_1080

                default:
                    break
            }
        }

        TUICallEngine.createInstance().setVideoEncoderParams(params) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func setVideoRenderParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let params = TUIVideoRenderParams()
        
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setVideoRenderParams", paramKey: "userId", result: result)
            return
        }
        
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Int>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setVideoRenderParams", paramKey: "params", result: result)
            return
        }

        if let fillModeIndex = paramsDic["fillMode"] {
            if fillModeIndex == 0 {
                params.fillMode = .fill
            } else if fillModeIndex == 1 {
                params.fillMode = .fit
            }
        }
        
        if let rotationIndex = paramsDic["rotation"] {
            switch rotationIndex {
                case 0 :
                    params.rotation = ._0
                
                case 1 :
                    params.rotation = ._90

                case 2 :
                    params.rotation = ._180

                case 3 :
                    params.rotation = ._270
                    
                default:
                    break
            }
        }

        TUICallEngine.createInstance().setVideoRenderParams(userId: userId, params: params) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func hangup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().hangup(succ: {
            result(NSNumber(value: 0))
        }, fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        })
    }
    
    func calls(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIdListKey = "userIdList"
        guard let userIdList = MethodUtils.getMethodParams(call: call, key: userIdListKey, resultType: Array<String>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "calls", paramKey: userIdListKey, result: result)
            return
        }
        
        let callMediaTypeKey = "mediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "calls", paramKey: callMediaTypeKey, result: result)
            return
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "calls", paramKey: "params", result: result)
            return
        }
        let params = convertTUICallParams(paramsDic: paramsDic)

        TUICallEngine.createInstance().calls(userIdList: userIdList, callMediaType: callMediaType, params: params) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: "calls Error{\(message ?? "unkonw error")}", details: nil)
            result(error)
        }
    }

    
    func singleCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "singleCall", paramKey: "userId", result: result)
            return
        }
        
        guard let mediaType = MethodUtils.getMethodParams(call: call, key: "mediaType", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "singleCall", paramKey: "mediaType", result: result)
            return
        }
        
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "singleCall", paramKey: "params", result: result)
            return
        }
        let params = convertTUICallParams(paramsDic: paramsDic)


        TUICallEngine.createInstance().call(userId: userId, callMediaType: TUICallMediaType(rawValue: mediaType) ?? .unknown, params: params) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func groupCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupIdKey = "groupId"
        guard let groupId = MethodUtils.getMethodParams(call: call, key: groupIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: groupIdKey, result: result)
            return
        }
        
        let userIdListKey = "userIdList"
        guard let userIdList = MethodUtils.getMethodParams(call: call, key: userIdListKey, resultType: Array<String>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: userIdListKey, result: result)
            return
        }
        
        let callMediaTypeKey = "mediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: callMediaTypeKey, result: result)
            return
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: "params", result: result)
            return
        }
        let params = convertTUICallParams(paramsDic: paramsDic)

        TUICallEngine.createInstance().groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func accept(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().accept {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func reject(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().reject {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func ignore(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().ignore {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func iniviteUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userIdList = MethodUtils.getMethodParams(call: call, key: "userIdList", resultType: Array<String>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "iniviteUser", paramKey: "userIdList", result: result)
            return
        }
                
        guard let paramsDic = MethodUtils.getMethodParams(call: call, key: "params", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "iniviteUser", paramKey: "params", result: result)
            return
        }
        let params = convertTUICallParams(paramsDic: paramsDic)

        TUICallEngine.createInstance().inviteUser(userIdList: userIdList, params: params) { inviteeUserIdsList in
            result(inviteeUserIdsList)
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func join(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let callId = MethodUtils.getMethodParams(call: call, key: "callId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "join", paramKey: "callId", result: result)
            return
        }
        
        TUICallEngine.createInstance().join(callId: callId) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }


    func joinInGroupCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let roomIdDic = MethodUtils.getMethodParams(call: call, key: "roomId", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: "roomId", result: result)
            return
        }
        let roomId = convertRoomID(roomIdDic: roomIdDic)
        
        let groupIdKey = "groupId"
        guard let groupId = MethodUtils.getMethodParams(call: call, key: groupIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: groupIdKey, result: result)
            return
        }

        let callMediaTypeKey = "mediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: callMediaTypeKey, result: result)
            return
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        
        TUICallEngine.createInstance().joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func switchCallMediaType(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: "mediaType", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "switchCallMediaType", paramKey: "mediaType", result: result)
            return
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }

        TUICallEngine.createInstance().switchCallMediaType(callMediaType)
    }

    func startRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = MethodUtils.getMethodParams(call: call, key: "viewId", resultType: UInt.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "openCamera", paramKey: "viewId", result: result)
            return
        }
        guard let platforeVideoView = PlatformVideoViewFactory.videoViewMap[String(viewId)] else { return }
        let videoView = platforeVideoView.videoView

        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "startRemoteView", paramKey: "mediaType", result: result)
            return
        }

        guard let viewId = MethodUtils.getMethodParams(call: call, key: "viewId", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "startRemoteView", paramKey: "viewId", result: result)
            return
        }

        TUICallEngine.createInstance().startRemoteView(userId: userId, videoView: videoView) { userId in
            
        } onLoading: { userId in
            
        } onError: { userId, code, message in
            
        }
    }

    func stopRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "stopRemoteView", paramKey: "mediaType", result: result)
            return
        }

        TUICallEngine.createInstance().stopRemoteView(userId: userId)
    }

    func openCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = MethodUtils.getMethodParams(call: call, key: "viewId", resultType: UInt.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "openCamera", paramKey: "viewId", result: result)
            return
        }
        guard let platforeVideoView = PlatformVideoViewFactory.videoViewMap[String(viewId)] else { return }
        let videoView = platforeVideoView.videoView
        
        
        guard let cameraIndex = MethodUtils.getMethodParams(call: call, key: "camera", resultType: UInt.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "openCamera", paramKey: "camera", result: result)
            return
        }
        
        TUICallEngine.createInstance().openCamera(TUICamera(rawValue: cameraIndex) ?? .front, videoView: videoView) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func closeCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().closeCamera()
    }

    func switchCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let cameraIndex = MethodUtils.getMethodParams(call: call, key: "camera", resultType: UInt.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "switchCamera", paramKey: "camera", result: result)
            return
        }

        TUICallEngine.createInstance().switchCamera(TUICamera(rawValue: cameraIndex) ?? .front)
    }

    func openMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().openMicrophone {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func closeMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallEngine.createInstance().closeMicrophone()
    }

    func selectAudioPlaybackDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let deviceIndex = MethodUtils.getMethodParams(call: call, key: "device", resultType: UInt.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "selectAudioPlaybackDevice", paramKey: "device", result: result)
            return
        }

        TUICallEngine.createInstance().selectAudioPlaybackDevice(TUIAudioPlaybackDevice(rawValue: deviceIndex) ?? .earpiece)
    }

    func setSelfInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let nickname = MethodUtils.getMethodParams(call: call, key: "nickname", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setSelfInfo", paramKey: "nickname", result: result)
            return
        }

        guard let avatar = MethodUtils.getMethodParams(call: call, key: "avatar", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setSelfInfo", paramKey: "avatar", result: result)
            return
        }

        TUICallEngine.createInstance().setSelfInfo(nickname: nickname, avatar: avatar) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func enableMultiDeviceAbility(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: Bool.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "enableMultiDeviceAbility", paramKey: "enable", result: result)
            return
        }

        TUICallEngine.createInstance().enableMultiDeviceAbility(enable: enable) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func queryRecentCalls(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let filterDic = MethodUtils.getMethodParams(call: call, key: "filter", resultType: Dictionary<String, Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "queryRecentCalls", paramKey: "filter", result: result)
            return
        }
        let filter = TUICallRecentCallsFilter()
        if let resultTypeIndex = filterDic["resultType"] as? UInt {
            filter.result = TUICallResultType(rawValue: resultTypeIndex) ?? .unknown
        }

        TUICallEngine.createInstance().queryRecentCalls(filter: filter) { records in
            
            var params: [[String: Any]] = []
            for record in records {
                let json: [String: Any] = ["callId": record.callId,
                                           "inviter": record.inviter,
                                           "inviteList": record.inviteList,
                                           "scene": record.scene.rawValue,
                                           "mediaType": record.mediaType.rawValue,
                                           "groupId": record.groupId,
                                           "role": record.role.rawValue,
                                           "result": record.result.rawValue,
                                           "beginTime": Int(record.beginTime),
                                           "totalTime": Int(record.totalTime)]
                params.append(json)
            }

            result(params)
        } fail: {
            let error = FlutterError(code: "-1", message: "ERROR", details: nil)
            result(error)
        }
    }
    
    func deleteRecordCalls(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let callIdList = MethodUtils.getMethodParams(call: call, key: "callIdList", resultType: Array<String>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "deleteRecordCalls", paramKey: "callIdList", result: result)
            return
        }
        
        TUICallEngine.createInstance().deleteRecordCalls(callIdList) { callIds in
            result(callIds)
        } fail: {
            let error = FlutterError(code: "-1", message: "ERROR", details: nil)
            result(error)
        }
    }

    func setBeautyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "level", resultType: Double.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setBeautyLevel", paramKey: "level", result: result)
            return
        }

        TUICallEngine.createInstance().setBeautyLevel(level) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func setBlurBackground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let level = MethodUtils.getMethodParams(call: call, key: "level", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setBlurBackground", paramKey: "level", result: result)
            return
        }
        
        TUICallEngine.createInstance().setBlurBackground(level) { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func setVirtualBackground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let imagePath = MethodUtils.getMethodParams(call: call, key: "imagePath", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setVirtualBackground", paramKey: "imagePath", result: result)
            return
        }
        
        TUICallEngine.createInstance().setVirtualBackground(imagePath) { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func callExperimentalAPI(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonDic = MethodUtils.getMethodParams(call: call, key: "jsonMap", resultType: Dictionary<String, Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setBeautyLevel", paramKey: "jsonMap", result: result)
            return
        }
    
        let jsonStr = jsonDic.toJsonString() ?? ""

        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: jsonStr)
    }
}

// MARK: TUICallObserver
extension TUICallEngineHandler: TUICallObserver {
    
    enum TUICallEngineObserverType: String {
      case onError
      case onUserInviting
      case onCallReceived
      case onCallCancelled
      case onCallNotConnected
      case onCallBegin
      case onCallEnd
      case onCallMediaTypeChanged
      case onUserReject
      case onUserNoResponse
      case onUserLineBusy
      case onUserJoin
      case onUserLeave
      case onUserVideoAvailable
      case onUserAudioAvailable
      case onUserVoiceVolumeChanged
      case onUserNetworkQualityChanged
      case onKickedOffline
      case onUserSigExpired
    }
    
    func invokeListener(type: TUICallEngineObserverType, params: Any? = nil) {
        var arguments: [String: Any] = [:]
        arguments["method"] = type.rawValue
        if let paramsValue = params {
            arguments["params"] = paramsValue
        }
        channel.invokeMethod("onTUICallObserver", arguments: arguments)
    }
    
    public func onError(code: Int32, message: String?) {
        invokeListener(type: .onError, params: [
            "code": code,
            "message": message ?? ""
        ])
    }
    
    public func onUserInviting(userId: String) {
        invokeListener(type: .onUserInviting, params: [
            "userId": userId
        ])
    }
    
    public func onCallReceived(_ callId: String, callerId: String, calleeIdList: [String], mediaType: TUICallMediaType, info: TUICallObserverExtraInfo) {
        invokeListener(type: .onCallReceived, params: [
            "callId": callId,
            "callerId": callerId,
            "calleeIdList": calleeIdList as Any,
            "mediaType": mediaType.rawValue,
            "info": getCallObserverExtraInfoMap(info: info)
        ])
    }

    public func onCallCancelled(callerId: String) {
        invokeListener(type: .onCallCancelled, params: [
            "callerId": callerId
        ])
    }
    
    public func onCallNotConnected(callId: String, mediaType: TUICallMediaType, reason: TUICallEndReason, userId: String, info: TUICallObserverExtraInfo) {
        invokeListener(type: .onCallNotConnected, params: [
            "callId": callId,
            "mediaType": mediaType.rawValue,
            "reason": reason.rawValue,
            "userId": userId,
            "info": getCallObserverExtraInfoMap(info: info)
        ])
    }
    
    public func onCallBegin(callId: String, mediaType: TUICallMediaType, info: TUICallObserverExtraInfo) {
        invokeListener(type: .onCallBegin, params: [
            "callId": callId,
            "mediaType": mediaType.rawValue,
            "info": getCallObserverExtraInfoMap(info: info)
        ])
    }
    
    public func onCallEnd(callId: String, mediaType: TUICallMediaType, reason: TUICallEndReason, userId: String, totalTime: Float, info: TUICallObserverExtraInfo) {
        invokeListener(type: .onCallEnd, params: [
            "callId": callId,
            "mediaType": mediaType.rawValue,
            "reason": reason.rawValue,
            "userId": userId,
            "totalTime": totalTime,
            "info": getCallObserverExtraInfoMap(info: info)
        ])
    }

    public func onCallMediaTypeChanged(oldCallMediaType: TUICallMediaType, newCallMediaType: TUICallMediaType) {
        invokeListener(type: .onCallMediaTypeChanged, params: [
            "oldCallMediaType": oldCallMediaType.rawValue,
            "newCallMediaType": newCallMediaType.rawValue,
        ])
    }
    
    public func onUserReject(userId: String) {
        invokeListener(type: .onUserReject, params: [
            "userId": userId,
        ])
    }
    
    public func onUserNoResponse(userId: String) {
        invokeListener(type: .onUserNoResponse, params: [
            "userId": userId,
        ])
    }
    
    public func onUserLineBusy(userId: String) {
        invokeListener(type: .onUserLineBusy, params: [
            "userId": userId,
        ])
    }
    
    public func onUserJoin(userId: String) {
        invokeListener(type: .onUserJoin, params: [
            "userId": userId,
        ])
    }
    
    public func onUserLeave(userId: String) {
        invokeListener(type: .onUserLeave, params: [
            "userId": userId,
        ])
    }
    
    public func onUserVideoAvailable(userId: String, isVideoAvailable: Bool) {
        invokeListener(type: .onUserVideoAvailable, params: [
            "userId": userId,
            "isVideoAvailable": isVideoAvailable,
        ])
    }
    
    public func onUserAudioAvailable(userId: String, isAudioAvailable: Bool) {
        invokeListener(type: .onUserAudioAvailable, params: [
            "userId": userId,
            "isAudioAvailable": isAudioAvailable,
        ])
    }

    public func onUserVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        invokeListener(type: .onUserVoiceVolumeChanged, params: [
            "volumeMap": volumeMap,
        ])
    }
    
    public func onUserNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {        
        var infos: [[String : Any]] = []
        for info in networkQualityList {
            let param: [String : Any] = ["userId" : info.userId ?? "", "networkQuality" : info.quality.rawValue]
            infos.append(param)
        }
        
        invokeListener(type: .onUserNetworkQualityChanged, params: [
            "networkQualityList": infos,
        ])
    }
    
    
    public func onKickedOffline() {
        invokeListener(type: .onKickedOffline)
    }
    
    public func onUserSigExpired() {
        invokeListener(type: .onUserSigExpired)
    }
    
}

private extension TUICallEngineHandler {
    func convertRoomID(roomIdDic: [String: Any]) -> TUIRoomId {
        let roomId = TUIRoomId()
        if let id = roomIdDic["intRoomId"] as? UInt32 {
            roomId.intRoomId = id
        }
        if let id = roomIdDic["strRoomId"] as? String {
            roomId.strRoomId = id
        }
        return roomId
    }
    
    func convertTUICallParams(paramsDic: [String: Any]) -> TUICallParams {
        let params = TUICallParams()

        let offlinePushInfo = TUIOfflinePushInfo()
        if let offlinePushInfoDic = paramsDic["offlinePushInfo"] as? Dictionary<String, Any> {
            if let title = offlinePushInfoDic["title"] as? String {
                offlinePushInfo.title = title
            }

            if let desc = offlinePushInfoDic["desc"] as? String {
                offlinePushInfo.desc = desc
            }

            if let isDisablePush = offlinePushInfoDic["isDisablePush"] as? Bool {
                offlinePushInfo.isDisablePush = isDisablePush
            }

            if let iOSPushType = offlinePushInfoDic["iOSPushType"] as? Int {
                offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.apns
                if iOSPushType == 1 {
                    offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.voIP
                }
            }

            if let ignoreIOSBadge = offlinePushInfoDic["ignoreIOSBadge"] as? Bool {
                offlinePushInfo.ignoreIOSBadge = ignoreIOSBadge
            }

            if let iOSSound = offlinePushInfoDic["iOSSound"] as? String {
                offlinePushInfo.iOSSound = iOSSound
            }

            if let androidSound = offlinePushInfoDic["androidSound"] as? String {
                offlinePushInfo.androidSound = androidSound
            }

            if let androidOPPOChannelID = offlinePushInfoDic["androidOPPOChannelID"] as? String {
                offlinePushInfo.androidOPPOChannelID = androidOPPOChannelID
            }

            if let androidFCMChannelID = offlinePushInfoDic["androidFCMChannelID"] as? String {
                offlinePushInfo.androidFCMChannelID = androidFCMChannelID
            }

            if let androidXiaoMiChannelID = offlinePushInfoDic["androidXiaoMiChannelID"] as? String {
                offlinePushInfo.androidXiaoMiChannelID = androidXiaoMiChannelID
            }

            if let androidVIVOClassification = offlinePushInfoDic["androidVIVOClassification"] as? Int {
                offlinePushInfo.androidVIVOClassification = androidVIVOClassification
            }

            if let androidHuaWeiCategory = offlinePushInfoDic["androidHuaWeiCategory"] as? String {
                offlinePushInfo.androidHuaWeiCategory = androidHuaWeiCategory
            }

            params.offlinePushInfo = offlinePushInfo
        }

        if let timeout =  paramsDic["timeout"] as? Int32 {
            params.timeout = timeout
        }

        if let userData = paramsDic["userData"] as? String {
            params.userData = userData
        }

        if let roomIdDic = paramsDic["roomId"] as? [String: Any] {
            params.roomId = convertRoomID(roomIdDic: roomIdDic)
        }
        
        if let chatGroupId = paramsDic["chatGroupId"] as? String {
            params.chatGroupId = chatGroupId
        }

        return params
    }
    
    func getCallObserverExtraInfoMap(info: TUICallObserverExtraInfo?) -> [String: Any] {
        var map = [String: Any]()
        if let info = info {
            map["roomId"] = ["intRoomId" : info.roomId.intRoomId,
                             "strRoomId" : info.roomId.strRoomId]
            map["role"] = info.role.rawValue
            map["userData"] = info.userData
            map["chatGroupId"] = info.chatGroupId
        }
        return map
    }
}

public extension Dictionary {
    func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: JSONSerialization.WritingOptions.init(rawValue: 0)) else {
            return nil
        }
        guard let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        return String(jsonStr)
    }
}
