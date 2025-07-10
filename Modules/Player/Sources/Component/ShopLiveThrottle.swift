//
//  ShopLiveThrottle.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2023/06/16.
//

import Foundation

struct ShopLiveThrottle {
    private var queue = OperationQueue()
    
    init(qos : QualityOfService = .background, maxConcurrentCount : Int = 1) {
        self.queue.qualityOfService = qos
        self.queue.maxConcurrentOperationCount = maxConcurrentCount
    }
    
    func addQueue(timeInterval : TimeInterval, task : @escaping (() -> ())){
        let delayOperation = DelayOperation(timeInterval: timeInterval)
        
        let taskOperation = BlockOperation {
            task()
        }
        if queue.operationCount != 0 {
            queue.cancelAllOperations()
            taskOperation.addDependency(delayOperation)
            queue.addOperations([taskOperation,delayOperation], waitUntilFinished: false)
        }
        else {
            delayOperation.addDependency(taskOperation)
            queue.addOperations([taskOperation,delayOperation], waitUntilFinished: false)
        }
    }
}

fileprivate class DelayOperation : Operation, @unchecked Sendable {
    private let timeInterval: TimeInterval
    
    override var isAsynchronous: Bool {
        get{
            return true
        }
    }
    
    private var _executing: Bool = false
    override var isExecuting:Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
            if _cancelled == true {
                self.isFinished = true
            }
        }
    }
    private var _finished: Bool = false
    override var isFinished:Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _cancelled: Bool = false
    override var isCancelled: Bool {
        get { return _cancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _cancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    override func start() {
        super.start()
        self.isExecuting = true
    }
    
    override func main() {
        if isCancelled {
            isExecuting = false
            isFinished = true
            return
        }
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline:.now() + timeInterval){
            self.isFinished = true
            self.isExecuting = false
        }
    }
    
    override func cancel() {
        super.cancel()
        isCancelled = true
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
}
