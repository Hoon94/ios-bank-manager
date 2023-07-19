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
    
    mutating func appendTenCustomers() {
        (1...10).forEach {
            customers.enqueue(Customer(numberTicket: $0))
        }

        start()
    }
    
    mutating func start() {
        assignClerk()
        totalTaskTime = measureTime {
            distributeCustomers()
        }
        announceResult()
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
        
//        depositQueue.waitUntilAllOperationsAreFinished()
//        loanQueue.waitUntilAllOperationsAreFinished()
    }
    
    private func work(customer: Customer) -> BlockOperation {
        return BlockOperation {
            NotificationCenter.default.post(name: NSNotification.Name("start"), object: self, userInfo: ["customer" : customer])
            print("\(customer.numberTicket)번 고객 \(customer.task.information.title)업무 시작")
            Thread.sleep(forTimeInterval: customer.task.information.time)
            print("\(customer.numberTicket)번 고객 \(customer.task.information.title)업무 완료")
//            NotificationCenter.default.post(name: NSNotification.Name("end"), object: self, userInfo: ["customer" : customer])
        }
    }
    
    private func announceResult() {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(totalCustomerCount)명이며, 총 업무시간은 \(String(format: "%.2f", totalTaskTime))초 입니다.")
    }
}

//MARK: - OperationQueue Extension
extension OperationQueue {
    func assignBankClerkCount(_ count: Int) {
        self.maxConcurrentOperationCount = count
    }
}
