//
//  TUIVideoViewFactory.swift
//  tencent_calls_engine
//
//  Created by vincepzhang on 2023/5/26.
//

import Foundation
import RTCRoomEngine

class PlatformVideoView: NSObject, FlutterPlatformView {
        
    var viewID: Int64
    var videoView: UIView
    var methodChannel: FlutterMethodChannel
    
    init(message: FlutterBinaryMessenger, viewID: Int64, videoView: UIView, args: Any?) {
        self.viewID = viewID
        self.videoView = videoView
        self.methodChannel = FlutterMethodChannel(name: "tuicall_kit/video_view_\(viewID)", binaryMessenger: message)
        
        super.init()
        self.methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "destoryVideoView":
                self.destoryVideoView(call: call, result: result)
            default: break
            }

        }
    }
    
    func view() -> UIView {
        return videoView
    }
    
    func destoryVideoView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        PlatformVideoViewFactory.videoViewMap.removeValue(forKey: String(viewID))
    }
}

class PlatformVideoViewFactory: NSObject, FlutterPlatformViewFactory {
    static var videoViewMap: [String: PlatformVideoView] = [:]

    var messager: FlutterBinaryMessenger
    
    init(messager: FlutterBinaryMessenger) {
        self.messager = messager
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let videoView = PlatformVideoView(message: messager, viewID: viewId, videoView: UIView(frame: frame), args: args)
        PlatformVideoViewFactory.videoViewMap[String(viewId)] = videoView
        return videoView
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
