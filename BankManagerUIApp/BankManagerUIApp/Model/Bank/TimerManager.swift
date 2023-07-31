//
//  TimerClerk.swift
//  BankManagerUIApp
//
//  Created by hoon, minsup on 2023/07/21.
//

import Foundation

class TimerManager {
    private enum State {
        case suspended
        case resumed
    }
    
    let timeInterval: TimeInterval
    var totalTaskTime: TimeInterval = 0
    var tempStoredTime: Date = Date()
    var startTime: Date = Date()
    var eventHandler: (() -> Void)?
    private var state: State = .suspended
    
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        
        return timer
    }()
    
    func resume() {
        if state == .resumed {
            tempStoredTime = startTime
            return
        }
        
        startTime = Date()
        state = .resumed
        timer.resume()
        tempStoredTime = startTime
    }

    func suspend() -> TimeInterval {
        if state == .suspended {
            return totalTaskTime
        }
        
        let currentTime = Date()
        state = .suspended
        timer.suspend()
        totalTaskTime += currentTime.timeIntervalSince(startTime)
        
        return totalTaskTime
    }
    
    func stop() -> TimeInterval {
        totalTaskTime = 0
        
        if state == .suspended {
            return totalTaskTime
        }
        
        state = .suspended
        timer.suspend()
        
        return totalTaskTime
    }
}
