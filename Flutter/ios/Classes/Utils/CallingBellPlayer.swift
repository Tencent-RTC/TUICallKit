//
//  CallingBellPlayer.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/25.
//

import Foundation
import AVFAudio
import RTCRoomEngine
import TXLiteAVSDK_Professional

let CALLKIT_AUDIO_DIAL_ID: Int32 = 48

class CallingBellPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let instance = CallingBellPlayer()
    
    private var player: AVAudioPlayer?
    private var loop: Bool = true
    
    func startRing(filePath: String) {
        let url = URL(fileURLWithPath: filePath)

        if TUICallState.instance.selfUser.value.callRole.value == .called {
            let _ = playAudioBySystem(url: url)

        } else if (TUICallState.instance.selfUser.value.callRole.value == .call) {
            playAudioByTRTC(path: filePath, id: CALLKIT_AUDIO_DIAL_ID)
        }
    }
    
    func stopRing() {
        if TUICallState.instance.selfUser.value.callRole.value == .called {
            return stopPlayBySystem()
        }
        stopAudioByTRTC(id: CALLKIT_AUDIO_DIAL_ID)
    }
    
    // MARK: System Auido Player
    private func playAudioBySystem(url: URL, loop: Bool = true) -> Bool {
        self.loop = loop
        
        if player != nil {
            stopPlayBySystem()
        }
        
        do {
            try player = AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("err: \(error.localizedDescription)")
            return false
        }
                
        guard let prepare = player?.prepareToPlay() else { return false }
        if !prepare {
            return false
        }
        
        setAudioSessionPlayback()
        
        player?.delegate = self
        guard let res = player?.play() else { return false }

        return res
    }
        
    private func stopPlayBySystem() {
        if player == nil {
            return
        }
        player?.stop()
        player = nil
    }
    
    //MARK: AVAudioPlayerDelegate
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loop {
            player.play()
        } else {
            stopPlayBySystem()
        }
    }
    
    internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            stopPlayBySystem()
        }
    }
    
    private func setAudioSessionPlayback() {
        let audioSession = AVAudioSession()
        try? audioSession.setCategory(.soloAmbient)
        try? audioSession.setActive(true)
    }

    //MARK: TRTC Audio Player
    private func playAudioByTRTC(path: String, id: Int32) {
        let param = TXAudioMusicParam()
        param.id = id
        param.isShortFile = true
        param.path = path
        
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().startPlayMusic(param,
                                                                                                     onStart: nil,
                                                                                                     onProgress: nil)
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().setMusicPlayoutVolume(id, volume: 100)
        
    }
    
    private func stopAudioByTRTC(id: Int32) {
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().stopPlayMusic(id)
    }
}
