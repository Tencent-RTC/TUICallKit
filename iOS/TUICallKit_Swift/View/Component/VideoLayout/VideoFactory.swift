//
//  VideoFactory.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import RTCCommon

class UserVideoEntity {
    var user: User
    var videoView: VideoView
    
    init(user: User, videoView: VideoView) {
        self.user = user
        self.videoView = videoView
    }
}

class VideoFactory {
    static let shared = VideoFactory()
    private var videoEntityMap : [String: UserVideoEntity] = [:]
    private let callStatusObserver = Observer()
            
    func createVideoView(user: User, isShowFloatWindow: Bool) -> VideoView? {
        if user.id.value.isEmpty {
            TRTCLog.error("TUICallKit - VideoFactory::createVideoView, user id is empty")
            return nil
        }
        
        if let videoView = getVideoView(user: user) {
            videoView.setIsShowFloatWindow(isShowFloatWindow: isShowFloatWindow)
            return videoView
        }
        
        let videoView = VideoView(user: user, isShowFloatWindow: isShowFloatWindow)
        let videoEntity = UserVideoEntity(user: user, videoView: videoView)
        videoEntityMap[user.id.value] = videoEntity
        return videoView
    }
    
    private func getVideoView(user: User) -> VideoView? {
        guard let videoEntity = videoEntityMap[user.id.value] else {
            return nil
        }
        return videoEntity.videoView
    }
    
    func removeVideoView(user: User) {
        videoEntityMap.removeValue(forKey: user.id.value)
    }
    
    func removeAllVideoView() {
        videoEntityMap.removeAll()
    }
}
