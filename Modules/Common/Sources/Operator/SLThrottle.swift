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
    private var delayedBlock: (() -> Void)?
    private var cancelBlock: (() -> Void)?
    private var timer: DispatchSourceTimer?
    private var isReady = true
    private var hasDelayedBlock: Bool { delayedBlock != nil }

    public init(queue: DispatchQueue, delay: Double) {
        self.queue = queue
        self.delay = delay
    }

    public func callAsFunction(action: @escaping () -> Void, onCancel: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                onCancel()
                return
            }
            if self.isReady {
                self.isReady = false
                action()
                self.scheduleTimer()
            } else {
                self.cancelBlock?()
                self.cancelBlock = onCancel
                self.delayedBlock = action
            }
        }
    }

    private func scheduleTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.hasDelayedBlock {
                self.cancelBlock = nil
                self.delayedBlock?()
                self.delayedBlock = nil
                self.scheduleTimer()
            } else {
                self.isReady = true
            }
        }
        timer.schedule(deadline: .now() + delay)
        timer.resume()
        self.timer = timer
    }
}
