//
//  PictureInPictureFeature.swift
//  TUICallKit_Swift
//
//  Created by noah on 2025/8/7.
//

import Foundation
import RTCRoomEngine
import SDWebImage
import ImSDK_Plus

enum PictureInPictureFillMode: Int, Codable {
    case fill = 0
    case fit = 1
}

struct PictureInPictureRegion: Codable {
    let userId: String
    let userName: String
    let width: Double
    let height: Double
    let x: Double
    let y: Double
    let fillMode: PictureInPictureFillMode
    let streamType: String
    let backgroundColor: String
    let backgroundImage: String?
    
    init(userId: String, userName: String, width: Double, height: Double, x: Double, y: Double, fillMode: PictureInPictureFillMode, streamType: String, backgroundColor: String, backgroundImage: String? = nil) {
        self.userId = userId
        self.userName = userName
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.fillMode = fillMode
        self.streamType = streamType
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
    }
}

struct PictureInPictureCanvas: Codable {
    let width: Int
    let height: Int
    let backgroundColor: String
}

struct PictureInPictureParams: Codable {
    let enable: Bool
    let cameraBackgroundCapture: Bool?
    let canvas: PictureInPictureCanvas?
    var regions: [PictureInPictureRegion]?
    
    init(enable: Bool, cameraBackgroundCapture: Bool? = nil, canvas: PictureInPictureCanvas? = nil, regions: [PictureInPictureRegion]? = nil) {
        self.enable = enable
        self.cameraBackgroundCapture = cameraBackgroundCapture
        self.canvas = canvas
        self.regions = regions
    }
}

struct PictureInPictureRequest: Codable {
    let api: String
    var params: PictureInPictureParams
}

// MARK: - Configuration
private struct PictureInPictureConfiguration {
    static let backgroundColor = "#111111"
    static let canvasWidth = 720
    static let canvasHeight = 1280
    static let apiName = "configPictureInPicture"
    static let maxGridUsers = 9
}

class PictureInPictureFeature: NSObject {
    private var currentRequest: PictureInPictureRequest?
    private let remoteUserListObserver = Observer()
    private let selfCallStatusObserver = Observer()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        registerObservers()
        let params = PictureInPictureParams(enable: true, cameraBackgroundCapture: true)
        sendPictureInPictureRequest(params)
    }
    
    deinit {
        unregisterObservers()
    }
    
    private func registerObservers() {
        CallManager.shared.userState.remoteUserList.addObserver(remoteUserListObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue.isEmpty {
                if let currentRequest = self.currentRequest, currentRequest.params.enable {
                    self.closePictureInPicture()
                    return
                }
            }
            if CallManager.shared.callState.mediaType.value == .video &&
                CallManager.shared.userState.selfUser.callStatus.value == .accept {
                self.updatePictureInPicture(newValue)
            }
        }
        
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfCallStatusObserver) { [weak self] newValue, _ in
            guard
                let self,
                newValue == .accept,
                CallManager.shared.callState.mediaType.value == .video
            else { return }
            
            self.updatePictureInPicture(CallManager.shared.userState.remoteUserList.value)
        }
    }
    
    private func unregisterObservers() {
        CallManager.shared.userState.remoteUserList.removeObserver(remoteUserListObserver)
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfCallStatusObserver)
    }
    
    func updatePictureInPicture(_ users: [User]) {
        var userList = users
        let selfUser = CallManager.shared.userState.selfUser
        if !userList.contains(where: { $0.id.value == selfUser.id.value }) {
            userList.append(selfUser)
        }
        guard !userList.isEmpty else { return }
        
        let regions = calculateLayout(for: userList)
        guard !regions.isEmpty else { return }
        
        let canvas = PictureInPictureCanvas(width: PictureInPictureConfiguration.canvasWidth,
                                            height: PictureInPictureConfiguration.canvasHeight,
                                            backgroundColor: PictureInPictureConfiguration.backgroundColor)
        let params = PictureInPictureParams(enable: true, cameraBackgroundCapture: true, canvas: canvas, regions: regions)
        
        sendPictureInPictureRequest(params)
        downloadAvatars(for: userList)
    }
    
    func closePictureInPicture() {
        let params = PictureInPictureParams(enable: false)
        sendPictureInPictureRequest(params)
    }
    
    private func downloadAvatars(for users: [User]) {
        UserManager.getUserInfosFromIM(userIDs: users.map { $0.id.value }) { userList in
            for user in userList {
                let avatarUrl = user.avatar.value
                guard !avatarUrl.isEmpty, let url = URL(string: avatarUrl) else { continue }
                
                SDWebImageDownloader.shared.downloadImage(with: url) { [weak self, user] image, data, error, finished in
                    guard let self = self else { return }
                    
                    if let image = image, finished {
                        let cacheKey = SDWebImageManager.shared.cacheKey(for: url)
                        SDImageCache.shared.store(image, forKey: cacheKey, toDisk: true, completion: {
                            if let cachePath = SDImageCache.shared.cachePath(forKey: cacheKey) {
                                self.setBackgroundImage(forUserId: user.id.value, to: "file://" + cachePath)
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func setBackgroundImage(forUserId userId: String, to backgroundImage: String) {
        guard var currentRequest = currentRequest,
              let regions = currentRequest.params.regions,
              currentRequest.params.enable else { return }
        
        let updatedRegions = regions.map { region -> PictureInPictureRegion in
            if region.userId == userId {
                return PictureInPictureRegion(
                    userId: region.userId,
                    userName: region.userName,
                    width: region.width,
                    height: region.height,
                    x: region.x,
                    y: region.y,
                    fillMode: region.fillMode,
                    streamType: region.streamType,
                    backgroundColor: region.backgroundColor,
                    backgroundImage: backgroundImage
                )
            } else {
                return region
            }
        }
        currentRequest.params.regions = updatedRegions
        sendPictureInPictureRequest(currentRequest.params)
    }
    
    private func sendPictureInPictureRequest(_ params: PictureInPictureParams) {
        let request = PictureInPictureRequest(api: PictureInPictureConfiguration.apiName, params: params)
        self.currentRequest = request
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(request), let jsonString = String(data: data, encoding: .utf8) {
            TUICallEngine.createInstance().callExperimentalAPI(jsonObject: jsonString)
        }
    }
}

extension PictureInPictureFeature {
    private func calculateLayout(for users: [User]) -> [PictureInPictureRegion] {
        var regions: [PictureInPictureRegion] = []
        
        switch users.count {
        case 1:
            regions.append(createFullScreenRegion(for: users[0]))
        case 2:
            regions.append(contentsOf: createTwoPersonLayout(for: users))
        case 3:
            regions.append(contentsOf: createThreePersonLayout(for: users))
        case 4:
            regions.append(contentsOf: createFourPersonLayout(for: users))
        default:
            regions.append(contentsOf: createGridLayout(for: users))
        }
        
        return regions
    }
    
    private func createFullScreenRegion(for user: User) -> PictureInPictureRegion {
        return PictureInPictureRegion(
            userId: user.id.value,
            userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
            width: 1.0, height: 1.0, x: 0.0, y: 0.0,
            fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
        )
    }
    
    private func createTwoPersonLayout(for users: [User]) -> [PictureInPictureRegion] {
        let otherUsers = users.filter { $0.id.value != CallManager.shared.userState.selfUser.id.value }
        let selfUser = users.first { $0.id.value == CallManager.shared.userState.selfUser.id.value }
        
        var regions: [PictureInPictureRegion] = []
        
        for user in otherUsers {
            regions.append(PictureInPictureRegion(
                userId: user.id.value,
                userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
                width: 1.0, height: 1.0, x: 0.0, y: 0.0,
                fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
            ))
        }
        
        if let selfUser = selfUser {
            regions.append(PictureInPictureRegion(
                userId: selfUser.id.value,
                userName: selfUser.nickname.value.isEmpty ? selfUser.id.value : selfUser.nickname.value,
                width: 1.0/3.0, height: 1.0/3.0, x: 0.65, y: 0.05,
                fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
            ))
        }
        
        return regions
    }
    
    private func createThreePersonLayout(for users: [User]) -> [PictureInPictureRegion] {
        var regions: [PictureInPictureRegion] = []
        
        for (index, user) in users.enumerated() {
            if index < 2 {
                let x = index == 0 ? 0.0 : 0.5
                regions.append(PictureInPictureRegion(
                    userId: user.id.value,
                    userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
                    width: 0.5, height: 0.5, x: x, y: 0.0,
                    fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
                ))
            } else {
                regions.append(PictureInPictureRegion(
                    userId: user.id.value,
                    userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
                    width: 0.5, height: 0.5, x: 0.25, y: 0.5,
                    fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
                ))
            }
        }
        
        return regions
    }
    
    private func createFourPersonLayout(for users: [User]) -> [PictureInPictureRegion] {
        var regions: [PictureInPictureRegion] = []
        
        for (index, user) in users.enumerated() {
            let row = index / 2
            let col = index % 2
            regions.append(PictureInPictureRegion(
                userId: user.id.value,
                userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
                width: 0.5, height: 0.5, x: Double(col) * 0.5, y: Double(row) * 0.5,
                fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
            ))
        }
        
        return regions
    }
    
    private func createGridLayout(for users: [User]) -> [PictureInPictureRegion] {
        var regions: [PictureInPictureRegion] = []
        
        for (index, user) in users.prefix(PictureInPictureConfiguration.maxGridUsers).enumerated() {
            let row = index / 3
            let col = index % 3
            regions.append(PictureInPictureRegion(
                userId: user.id.value,
                userName: user.nickname.value.isEmpty ? user.id.value : user.nickname.value,
                width: 1.0/3.0, height: 1.0/3.0, x: Double(col) * 1.0/3.0, y: Double(row) * 1.0/3.0,
                fillMode: .fill, streamType: "high", backgroundColor: PictureInPictureConfiguration.backgroundColor
            ))
        }
        
        return regions
    }
}
