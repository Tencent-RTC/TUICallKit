//
//  VideoFactory.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class VideoFactory {
    
    static let instance = VideoFactory()
    var viewMap: [String: UserVideoEntity] = Dictionary()
    
    func createVideoView(userId: String,frame: CGRect) -> VideoView {
        let videoView = VideoView(frame: frame)
        let userVideoEntity = UserVideoEntity()
        userVideoEntity.userId = userId
        userVideoEntity.videoView = videoView
        if TUICallState.instance.selfUser.value.id.value == userId {
            userVideoEntity.user = TUICallState.instance.selfUser.value
        } else {
            for user in TUICallState.instance.remoteUserList.value where user.id.value == userId {
                userVideoEntity.user = user
            }
        }
        viewMap[userId] = userVideoEntity
        return videoView
    }
    
    func isExistVideoView(videoView: VideoView) -> Bool {
        let isExist = false
        for view in viewMap where view.value.videoView == videoView {
            return true
        }
        return isExist
    }
    
    func setVideoView(user: User, videoView: VideoView) {
        if viewMap[user.id.value] != nil {
            viewMap[user.id.value]?.userId = user.id.value
            viewMap[user.id.value]?.user = user
            viewMap[user.id.value]?.videoView = videoView
        } else {
            let entity = UserVideoEntity()
            entity.userId = user.id.value
            entity.videoView = videoView
            entity.user = user
            viewMap[user.id.value] = entity
        }
    }
}

class UserVideoEntity {
    var userId: String = ""
    var user: User  = User()
    var videoView: VideoView = VideoView(frame: CGRect.zero)
}
