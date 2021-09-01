//
//  TUICallingAudioPlayer.swift
//  TUICalling
//
//  Created by gg on 2021/8/4.
//

import Foundation

public enum CallingAudioType {
    case hangup     // 挂断
    case called     // 被动呼叫
    case dial       // 主动呼叫
}

@discardableResult
public func playAudio(type: CallingAudioType) -> Bool {
    switch type {
    case .hangup:
        guard let path = CallingBundle().path(forResource: "phone_hangup", ofType: "mp3") else { return false }
        let url = URL(fileURLWithPath: path)
        return TUICallingAudioPlayer.shared().playAudio(url, toTime: 2)
    case .called:
        guard let path = CallingBundle().path(forResource: "phone_ringing", ofType: "flac") else { return false }
        let url = URL(fileURLWithPath: path)
        return TUICallingAudioPlayer.shared().playAudio(url, startTime: 1.5, loop: true)
    case .dial:
        guard let path = CallingBundle().path(forResource: "phone_dialing", ofType: "m4a") else { return false }
        let url = URL(fileURLWithPath: path)
        return TUICallingAudioPlayer.shared().playAudio(url, startTime: 2, loop: true)
    }
}

public func stopAudio() {
    TUICallingAudioPlayer.shared().stopAudio()
}

class TUICallingAudioPlayer: NSObject {
    
    private static let staticInstance: TUICallingAudioPlayer = TUICallingAudioPlayer.init()
    static func shared() -> TUICallingAudioPlayer {
        return staticInstance
    }
    private override init(){}
    
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = 0
    private var toTime: TimeInterval = 10000
    private var loop = false
    
    private var player: AVAudioPlayer?
    
    func resetStatus() {
        loop = false
        startTime = 0
        toTime = 10000
        invalidateDisplayLink()
    }
    
    public func stopAudio() {
        guard let player = player else {
            return
        }
        player.stop()
        resetStatus()
        self.player = nil
        debugPrint("player: stop play")
    }
    
    @discardableResult
    public func playAudio(_ url: URL, startTime: TimeInterval = 0, toTime: TimeInterval = 0, loop: Bool = false) -> Bool {
        if player != nil {
            stopAudio()
        }
        player = try? AVAudioPlayer(contentsOf: url)
        guard let player = self.player else {
            debugPrint("player: url error, cannot create player")
            return false
        }
        guard player.prepareToPlay() else {
            debugPrint("player: prepare false")
            return false
        }
        
        self.startTime = startTime
        if startTime != 0 {
            player.currentTime = startTime
        }
        
        player.delegate = self
        
        let res = player.play()
        debugPrint("player: start play res: \(res)")
        
        self.toTime = toTime
        if toTime != 0 && res && toTime <= player.duration {
            startDisplayLink()
        }
        
        self.loop = loop
        return res
    }
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback(displayLink:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func displayLinkCallback(displayLink: CADisplayLink) {
        guard let player = player, toTime > 0, player.isPlaying else {
            return
        }
        if player.currentTime >= toTime {
            if loop {
                player.pause()
                player.currentTime = startTime
                player.play()
                debugPrint("player: restart")
            }
            else {
                stopAudio()
            }
        }
    }
}

extension TUICallingAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        debugPrint("player: finish play \(flag)")
        if loop {
            player.currentTime = startTime
            player.play()
            debugPrint("player: restart")
        }
        else {
            stopAudio()
        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error = error else {
            return
        }
        debugPrint("player: error: \(error)")
        stopAudio()
    }
}
