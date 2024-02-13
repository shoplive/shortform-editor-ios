//
//  NetworkMonitor.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/23/22.
//
import Foundation

/**
 networkMonitor.resultHandler = { [weak self] (result) in
     DispatchQueue.main.async { [weak self] in
         switch result {
         case let .statusChanged(status):
             let available = status.isConnected
             self?.isNetworkAvailable = available
             if !available {
                 self?.setErrorView(visible: !available)
             }
             
         }
     }
 }
 */
public final class NetworkMonitor: SLResultObservable {
    public enum ConnectionType {
        case wifi
        case cellular
        case disconnected
        case none
        
        var rawValue: String {
            switch self {
            case .wifi: return "W"
            case .cellular: return "C"
            case .disconnected: return "U"
            case .none: return "N"
            }
        }
        
        public var isConnected: Bool {
            return self != .disconnected && self != .none
        }
        
        public var isInitialzed: Bool {
            return self != .none
        }
    }
    
    public enum Result {
        case statusChanged(ConnectionType)
    }
    
    public var resultHandler: ((Result) -> ())?
    
    public init() {
        reachability = try? SLReachability()
        
        reachability?.whenReachable = { [weak self] r in
            if r.connection == .wifi {
                //NSLog("shorts network .wifi")
                self?.resultHandler?(.statusChanged(.wifi))
                self?.connectionType = .wifi
            } else {
                //NSLog("shorts network .cellular")
                self?.resultHandler?(.statusChanged(.cellular))
                self?.connectionType = .cellular
            }
        }
        reachability?.whenUnreachable = {[weak self] _ in
            //NSLog("shorts network .disconnected")
            self?.connectionType = .disconnected
            self?.resultHandler?(.statusChanged(.disconnected))
        }

        do {
            try reachability?.startNotifier()
        } catch {
            // print(error)
        }
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    private var reachability: SLReachability?
    private var connectionType = ConnectionType.disconnected
    
    var networkType: String {
        return connectionType.rawValue
    }
    
    public var isConnected: Bool {
        return ["W", "C"].contains(networkType)
    }
}
