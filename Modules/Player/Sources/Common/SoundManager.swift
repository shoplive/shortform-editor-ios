//
//  SoundManager.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2022/02/10.
//

import Foundation
import AVFAudio
import AVKit
import ShopliveSDKCommon

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
    
    //for cached
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
    
    //for non cached
    var avPlayerItem : AVPlayerItem?
    
    init(alias: String, url: String) {
        self.alias = alias
        self.url = url
        guard let requestUrl = URL(string: url) else { return }
        self.checkIfDownloaded(audioUrl: requestUrl)
    }
    
    func downloadSoundItem(requestUrl : URL, destination : URL) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let task = URLSession.shared.downloadTask(with: requestUrl) { localUrl, response , error in
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
    }
    
    
    private func checkIfDownloaded(audioUrl : URL) {
        let documentsUrl = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var audioUrlPath = self.alias
        audioUrlPath = audioUrlPath.replacingOccurrences(of: "/", with: "_")
        let destination = documentsUrl.appendingPathComponent(audioUrlPath)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            self.avPlayerItem = nil
            self.localUrl = destination
        }
        else {
            self.avPlayerItem = AVPlayerItem(url: audioUrl)
            self.downloadSoundItem(requestUrl: audioUrl, destination: destination)
        }
    }
    
}
class SoundPlayer {
    
    private(set) var player: AVAudioPlayer?
    private(set) var avPlayer : AVPlayer?
    var item: SoundItem
    
    init(item: SoundItem) {
        self.item = item
    }
    
    func play() {
        player = nil
        avPlayer = nil
        if let playeItem = self.item.playItem {
            do {
                player = try AVAudioPlayer(data: playeItem)
            }
            catch {
                ShopLiveLogger.debugLog("SoundPlayer player set failed")
            }
            self.avPlayer = nil
            self.item.avPlayerItem = nil
            player?.play()
        }
        else if let avPlayerItem = self.item.avPlayerItem {
            avPlayer = AVPlayer(playerItem: avPlayerItem)
            avPlayer?.play()
        }
    }
    
    func stop() {
        player?.stop()
        avPlayer?.pause()
    }
    
}


