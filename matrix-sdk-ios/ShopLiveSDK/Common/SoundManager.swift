//
//  SoundManager.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2022/02/10.
//

import Foundation
import AVFAudio

class SoundManager: NSObject {
    
    static let shared: SoundManager = SoundManager()
    
    private var players: [SoundPlayer] = []
    private var items: [SoundItem] = []
    
    
    func play(alias : String) {
        if let playItem = self.items.filter({ $0.alias == alias }).first {
            if let player = self.players.filter({ $0.item.alias == playItem.alias }).first {
                player.play()
            }
        }
    }
    
    func stop(alias: String) {
        if let first = players.filter({ $0.item.alias == alias }).first {
            first.stop()
        }
    }
    
    func addItems(newItems: [SoundItem]) {
        newItems.forEach { item in
            if !self.items.contains(where: { $0.url == item.url }) {
                self.items.append(item)
                self.players.append(SoundPlayer(item: item))
            }
        }
    }
    
    func removeAllSounds() {
        self.players.forEach { player in
            player.stop()
        }
        self.items.removeAll()
        self.players.removeAll()
    }
    
    override init() {
        super.init()
    }
    
}

class SoundItem {
    var alias: String
    var url: String
    private var localUrl : URL?
    
    
    init(alias: String, url: String) {
        self.alias = alias
        self.url = url
        
        guard let requestUrl = URL(string: url) else { return }
        self.checkIfDownloaded(audioUrl: requestUrl)
    }
    
    func downloadSoundItem(requestUrl : URL, destination : URL) {
        let task = URLSession.shared.downloadTask(with: requestUrl) {  [weak self] localUrl, response , error in
            guard let self = self else { return }
            guard let localUrl = localUrl else { return }
            self.localUrl = destination
            do {
                try FileManager.default.moveItem(at: localUrl, to: destination)
            }
            catch(let error) {
                ShopLiveLogger.debugLog("soundItem file directory couldn't be moved \(error)")
            }
        }
        task.resume()
    }
    
    
    private func checkIfDownloaded(audioUrl : URL) {
        DispatchQueue.global(qos: .background).async {
            let documentsUrl = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let destination = documentsUrl.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destination.path) {
                self.localUrl = destination
            }
            else {
                self.downloadSoundItem(requestUrl: audioUrl, destination: destination)
            }
        }
    }
    
}

extension SoundItem {
    
    var playItem: Data? {
        var item: Data? = nil
        
        guard let localUrl = self.localUrl else { return nil }
        
        do {
            item = try Data(contentsOf: localUrl)
        }
        catch (let error) {
            ShopLiveLogger.debugLog("soundItem failed to read from directory \(error)")
            return nil
        }
        
        return item
    }
}

class SoundPlayer {
    
    private(set) var player: AVAudioPlayer?
    var item: SoundItem
    
    init(item: SoundItem) {
        self.item = item
        
    }
    
    func play() {
        player = nil
        guard let playeItem = self.item.playItem else { return }
        do {
            player = try AVAudioPlayer(data: playeItem)
        }
        catch {
            ShopLiveLogger.debugLog("SoundPlayer player set failed")
        }
        player?.play()
    }
    
    
    func stop() {
        player?.stop()
    }
    
}


