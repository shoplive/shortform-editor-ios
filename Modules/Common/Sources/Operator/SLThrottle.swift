//
//  SLThrottle.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation

public class SLThrottle {
    private let queue: DispatchQueue
    private let delay: Double
    private var timer: DispatchSourceTimer?
    private var isReady = true

    public init(queue: DispatchQueue, delay: Double) {
        self.queue = queue
        self.delay = delay
    }

    /// Leading-edge throttle: executes the first call immediately, then ignores calls until `delay` elapses.
    /// No trailing call will be fired.
    public func callAsFunction(action: @escaping () -> Void, onCancel: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            if isReady {
                self.isReady = false
                action()
                self.reset()
            } else {
                // Drop subsequent calls during cooldown
                onCancel()
            }
        }
    }
        

    private func reset() {
        timer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { [weak self] in
            self?.isReady = true
            self?.timer?.cancel()
            self?.timer = nil
        }
        timer.schedule(deadline: .now() + delay)
        timer.resume()
        self.timer = timer
    }
}
