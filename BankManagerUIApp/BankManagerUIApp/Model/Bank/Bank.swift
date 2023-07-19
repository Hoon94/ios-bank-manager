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
    private var lastPublishedNumberTicket = 1
    var timerDelegate: TimerDelegate?
    
    func appendTenCustomers() {
        (lastPublishedNumberTicket..<(lastPublishedNumberTicket + 10)).forEach {
            customers.enqueue(Customer(numberTicket: $0))
        }
        
        lastPublishedNumberTicket += 10
        start()
    }
    
    func start() {
        assignClerk()
        DispatchQueue.global().async {
            self.distributeCustomers()
        }
    }
    
    @objc func updateTotalTaskTime() {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        
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
