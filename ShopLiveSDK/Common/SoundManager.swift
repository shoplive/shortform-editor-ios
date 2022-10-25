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
            guard !ShopLiveController.shared.isMuted else { return }
            guard let item = self.items.filter({ $0.alias == alias}).first else { return }
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
        DispatchQueue.main.async {
            newItems.forEach { item in
                if !self.items.contains(where: { $0.url == item.url }) {
                    self.items.append(item)
                    // preload
                        if let player = SoundPlayer(item: item) {
                            self.players.append(player)
                        }
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
        DispatchQueue.main.async {
            if let playerIndex = self.players.firstIndex(where: { $0.player == player }) {
                self.players.remove(at: playerIndex)
            }
            ShopLiveLogger.debugLog("didFinishPlaying current players count \(self.players.count)")
        }
    }
}

struct SoundItem {
    var alias: String
    var url: String
    
    init(alias: String, url: String) {
        self.alias = alias
        self.url = url
    }
    
    func download(completion: @escaping ((URL?) -> Void)) {
        guard let url = self.playUrl else { return }
        
        DispatchQueue.global(qos: .background).async {
            let downloadTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: .init(url: url)) { url, response, error in
                completion(url)
            }
            downloadTask.resume()
        }
    }
    
    private var playUrl: URL? {
        URL(string: self.url)
    }
}

extension SoundItem {
    
}

class SoundPlayer {
    
    private(set) var player: AVAudioPlayer?
    var item: SoundItem
    
    init?(item: SoundItem) {
        self.item = item
    }
    
    func play() {
        DispatchQueue.main.async {
            self.item.download { url in
                guard let url = url else { return }
                do {
                    self.player = try AVAudioPlayer(contentsOf: url)
                    self.player?.prepareToPlay()
                    self.player?.play()
                } catch {
                    return
                }
            }
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.player?.stop()
        }
    }
    
}


