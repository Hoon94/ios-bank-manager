//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by hoon, minsup on 2023/07/14.
//

import Foundation

@objc
protocol TimerDelegate {
    func updateTimerUI(totalTaskTime: String)
}

class Bank {
    private var customers = Queue<Customer>()
    private let depositQueue = OperationQueue()
    private let loanQueue = OperationQueue()
    private let totalCustomerCount = 0
    private var startTime = Date()
    private var totalTaskTime = 0.0
    private var lastPublishedNumberTicket = 1
    private var timer: RepeatingTimer
    var timerDelegate: TimerDelegate?
    
    init() {
        timer = RepeatingTimer(timeInterval: 0.001)
        timer.eventHandler = {
            self.updateTotalTaskTime()
        }
    }
    
    func appendTenCustomers() {
        (lastPublishedNumberTicket..<(lastPublishedNumberTicket + 10)).forEach {
            customers.enqueue(Customer(numberTicket: $0))
        }
        
        lastPublishedNumberTicket += 10
        start()
    }
    
    func resetBank() {
        depositQueue.cancelAllOperations()
        loanQueue.cancelAllOperations()
        totalTaskTime = timer.stop()
        timerDelegate?.updateTimerUI(totalTaskTime: "00:00:000")
    }
    
    func start() {
        assignClerk()
        startTime = timer.resume()
        DispatchQueue.global().async {
            self.distributeCustomers()
        }
    }
    
    @objc func updateTotalTaskTime() {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime) + totalTaskTime
        
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
        
        let result = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        timerDelegate?.updateTimerUI(totalTaskTime: result)
    }
    
    private func assignClerk() {
        depositQueue.assignBankClerkCount(2)
        loanQueue.assignBankClerkCount(1)
    }
    
    private func distributeCustomers() {
        while let customer = customers.dequeue() {
            NotificationCenter.default.post(name: NSNotification.Name("view"), object: self, userInfo: ["customer" : customer])
            
            switch customer.task {
            case .deposit:
                depositQueue.addOperation(work(customer: customer))
            case .loan:
                loanQueue.addOperation(work(customer: customer))
            }
        }
        depositQueue.waitUntilAllOperationsAreFinished()
        loanQueue.waitUntilAllOperationsAreFinished()
        totalTaskTime = timer.suspend()
    }
    
    private func work(customer: Customer) -> BlockOperation {
        return BlockOperation {
            NotificationCenter.default.post(name: NSNotification.Name("start"), object: self, userInfo: ["customer" : customer])
            Thread.sleep(forTimeInterval: customer.task.information.time)
            NotificationCenter.default.post(name: NSNotification.Name("end"), object: self, userInfo: ["customer" : customer])
        }
    }
}

//MARK: - OperationQueue Extension
extension OperationQueue {
    func assignBankClerkCount(_ count: Int) {
        self.maxConcurrentOperationCount = count
    }
}

class RepeatingTimer {
    let timeInterval: TimeInterval
    var totalTaskTime: TimeInterval = 0
    var startTime: Date = Date()
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        print("timer reset")
        timer.setEventHandler {}
        timer.cancel()
        let _ = resume()
        eventHandler = nil
    }
    
    func resume() -> Date {
        if state == .resumed {
            return startTime
        }
        startTime = Date()
        state = .resumed
        timer.resume()
        
        return startTime
    }

    func suspend() -> TimeInterval {
        let currentTime = Date()
        
        if state == .suspended {
            return totalTaskTime
        }
        
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
