//
//  SoundManager.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 2022/02/10.
//

import Foundation
import AVFAudio

class SoundManager: NSObject {
    
    static var shared: SoundManager = {
        return SoundManager()
    }()
    
    private var players: [SoundPlayer] = []
    private var items: [SoundItem] = []
    
    func play(item: SoundItem) {
        if let playItem = self.items.filter({ $0.name == item.name }).first {
            if let player = SoundPlayer(item: playItem) {
                player.player?.delegate = self
                self.players.append(player)
                player.play()
            }
        }
    }
    
    func play(name: String) {
        let item = SoundItem(name: name, url: "")
        self.play(item: item)
    }
    
    func addItems(newItems: [SoundItem]) {
        newItems.forEach { item in
            if !self.items.contains(where: { $0.url == item.url }) {
                self.items.append(item)
            }
        }
    }
    
    func clear() {
        self.players.forEach { player in
            player.stop()
        }
        
        self.players.removeAll()
//        self.items.removeAll()
    }
    
    override init() {
        super.init()
        var item = SoundItem(name: "quiz_timer_musinsa", url: "https://dev-static.shoplive.cloud/sound/quiz_timer_musinsa.mp3")
//        var item2 = SoundItem(name: "test", url: "https://shoplive-sdk.s3.amazonaws.com/test.mp3")
    
        self.addItems(newItems: [item])
    }
    
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let playerIndex = self.players.firstIndex(where: { $0.player == player }) {
            self.players.remove(at: playerIndex)
        }
        
        ShopLiveLogger.debugLog("didFinishPlaying current players count \(self.players.count)")
    }
}

struct SoundItem {
    var name: String
    var url: String
}

extension SoundItem {
    var playItem: Data? {
        var item: Data? = nil
        
        guard let itemURL = URL(string: self.url) else {
            return item
        }
        
        do {
            item = try Data(contentsOf: itemURL)
        } catch {
            
        }
        
        return item
    }
}

class SoundPlayer {
    
    private(set) var player: AVAudioPlayer?
    
    init?(item: SoundItem) {
        
        guard let playItem = item.playItem else {
            return nil
        }
        
        do {
            player = try AVAudioPlayer(data: playItem)
        } catch {
            return nil
        }
        
        player?.prepareToPlay()
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
    }
    
}


