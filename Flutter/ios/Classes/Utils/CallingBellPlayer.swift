//
//  CallingBellPlayer.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/25.
//

import Foundation
import AVFAudio

class CallingBellPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let instance = CallingBellPlayer()
    
    var player: AVAudioPlayer?
    var loop: Bool = true
        
    func playAudio(url: URL, loop: Bool = true) -> Bool {
        self.loop = loop
        
        if player != nil {
            stopPlay()
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
        
    func stopPlay() {
        if player == nil {
            return
        }
        player?.stop()
        player = nil
    }
    
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loop {
            player.play()
        } else {
            stopPlay()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            stopPlay()
        }
    }
    
    func setAudioSessionPlayback() {
        let audioSession = AVAudioSession()
        try? audioSession.setCategory(.soloAmbient)
        try? audioSession.setActive(true)
    }
}
