//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by hoon, minsup on 2023/07/14.
//

import Foundation

struct Bank {
    private var customers = Queue<Customer>()
    private let depositQueue = OperationQueue()
    private let loanQueue = OperationQueue()
    private let totalCustomerCount: Int = 0
    private var totalTaskTime: CFAbsoluteTime = 0
    private var lastPublishedNumberTicket = 1
    
    mutating func appendTenCustomers() {
        (lastPublishedNumberTicket..<(lastPublishedNumberTicket + 10)).forEach {
            customers.enqueue(Customer(numberTicket: $0))
        }

        lastPublishedNumberTicket += 10
        start()
    }
    
    mutating func start() {
        assignClerk()
        totalTaskTime = measureTime {
            distributeCustomers()
        }
    }
    
    private func assignClerk() {
        depositQueue.assignBankClerkCount(2)
        loanQueue.assignBankClerkCount(1)
    }
    
    private func measureTime(perform: () -> Void) -> CFAbsoluteTime {
        let start = CFAbsoluteTimeGetCurrent()
        perform()
        let end = CFAbsoluteTimeGetCurrent()
        
        return end - start
    }
    
    private mutating func distributeCustomers() {
        while let customer = customers.dequeue() {
            NotificationCenter.default.post(name: NSNotification.Name("view"), object: self, userInfo: ["customer" : customer])
            
            switch customer.task {
            case .deposit:
                depositQueue.addOperation(work(customer: customer))
            case .loan:
                loanQueue.addOperation(work(customer: customer))
            }
        }
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
