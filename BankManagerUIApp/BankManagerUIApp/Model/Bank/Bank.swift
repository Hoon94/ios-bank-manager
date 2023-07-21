//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by hoon, minsup on 2023/07/14.
//

import Foundation

protocol TimerDelegate {
    func addWaitingQueue(customer: Customer)
    func moveToWorkingQueue(customer: Customer)
    func removeWorkingQueue(customer: Customer)
    func updateTimerUI(totalTaskTime: String)
}

final class Bank {
    private var customers = Queue<Customer>()
    private let depositQueue = OperationQueue()
    private let loanQueue = OperationQueue()
    private let totalCustomerCount = 0
    private var totalTaskTime = 0.0
    private var lastPublishedNumberTicket = 1
    private var timer: TimerManager
    private let semaphore = DispatchSemaphore(value: 1)
    var timerDelegate: TimerDelegate?
    
    init() {
        timer = TimerManager(timeInterval: 0.053)
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
    
    func start() {
        assignClerk()
        timer.resume()
        DispatchQueue.global().async {
            self.distributeCustomers()
        }
    }
    
    @objc func updateTotalTaskTime() {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(timer.tempStoredTime) + totalTaskTime
        
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime * 1000).truncatingRemainder(dividingBy: 1000))
        
        let result = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        timerDelegate?.updateTimerUI(totalTaskTime: result)
    }
    
    private func assignClerk() {
        depositQueue.assignBankClerkCount(Deposit.clerkCount)
        loanQueue.assignBankClerkCount(Loan.clerkCount)
    }
    
    private func distributeCustomers() {
        while let customer = customers.dequeue() {
            
            self.timerDelegate?.addWaitingQueue(customer: customer)
            
            switch customer.task {
            case .deposit:
                depositQueue.addOperation(work(customer: customer))
            case .loan:
                loanQueue.addOperation(work(customer: customer))
            }
        }
        
        depositQueue.waitUntilAllOperationsAreFinished()
        loanQueue.waitUntilAllOperationsAreFinished()
        
        semaphore.wait()
        totalTaskTime = timer.suspend()
        semaphore.signal()
    }
    
    private func work(customer: Customer) -> BlockOperation {
        return BlockOperation {
            self.timerDelegate?.moveToWorkingQueue(customer: customer)
            Thread.sleep(forTimeInterval: customer.task.information.time)
            self.timerDelegate?.removeWorkingQueue(customer: customer)
        }
    }
    
    func resetBank() {
        depositQueue.cancelAllOperations()
        loanQueue.cancelAllOperations()
        totalTaskTime = timer.stop()
        lastPublishedNumberTicket = 1
        timerDelegate?.updateTimerUI(totalTaskTime: "00:00:000")
    }
}

//MARK: - OperationQueue Extension
extension OperationQueue {
    func assignBankClerkCount(_ count: Int) {
        self.maxConcurrentOperationCount = count
    }
}

//MARK: - Task Extension
extension Bank {
    enum Task {
        case loan
        case deposit
        
        static var random: Self {
            return Int.random(in: 1...2) % 2 == 1 ? .loan : .deposit
        }
        
        var information: (title: String, time: Double) {
            switch self {
            case .deposit:
                return (title: Deposit.title, time: Deposit.taskTime)
            case .loan:
                return (title: Loan.title, time: Loan.taskTime)
            }
        }
    }
}

//MARK: - Namespace Extension
extension Bank {
    enum Deposit {
        static let clerkCount = 2
        static let title = "예금"
        static let taskTime = 0.7
    }
    
    enum Loan {
        static let clerkCount = 1
        static let title = "대출"
        static let taskTime = 1.1
    }
}

