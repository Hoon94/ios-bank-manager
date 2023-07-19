//
//  Customer.swift
//  BankManagerConsoleApp
//
//  Created by hoon, minsup on 2023/07/14.
//

struct Customer {
    enum Task {
        case loan
        case deposit
        
        static var random: Self {
            return Int.random(in: 1...2) % 2 == 1 ? .loan : .deposit
        }
        
        var information: (title: String, time: Double) {
            switch self {
            case .loan:
                return (title: "대출", time: 1.1)
            case .deposit:
                return (title: "예금", time: 0.7)
            }
        }
    }
    
    let numberTicket: Int
    let task: Task
    
    init(numberTicket: Int) {
        self.numberTicket = numberTicket
        self.task = Task.random
    }
}
