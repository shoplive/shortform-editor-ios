//
//  SoundManager.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2022/02/10.
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
        DispatchQueue.main.async {
            if let playItem = self.items.filter({ $0.alias == item.alias }).first {
                if let player = SoundPlayer(item: playItem) {
                    player.player?.delegate = self
                    self.players.append(player)
                    player.play()
                }
            }
        }
    }
    
    func play(alias: String) {
        DispatchQueue.main.async {
            let item = SoundItem(alias: alias, url: "")
            self.play(item: item)
        }
    }
    
    func stop(alias: String) {
        DispatchQueue.main.async {
            let filteredPlayer = self.players.filter({ $0.item.alias == alias })
            
            filteredPlayer.forEach { player in
                if let playerIndex = self.players.firstIndex(where: { $0.player == player.player }) {
                    player.player?.stop()
                    self.players.remove(at: playerIndex)
                }
            }
        }
    }
    
    func addItems(newItems: [SoundItem]) {
        newItems.forEach { item in
            if !self.items.contains(where: { $0.url == item.url }) {
                self.items.append(item)
                // preload
                DispatchQueue.global().async {
                    _ = SoundPlayer(item: item)
                }
            }
        }
    }
    
    func removeAllSounds() {
        DispatchQueue.main.async {
            self.players.forEach { player in
                player.stop()
            }
            
            self.players.removeAll()
        }
    }
    
    override init() {
        super.init()
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
    var alias: String
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
    var item: SoundItem
    
    init?(item: SoundItem) {
        
        guard let playItem = item.playItem else {
            return nil
        }
        
        self.item = item
        
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


