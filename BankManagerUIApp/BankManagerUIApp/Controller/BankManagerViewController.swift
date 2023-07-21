//
//  BankManagerUIApp - ViewController.swift
//  Created by yagom.
//  Copyright © yagom academy. All rights reserved.
//

import UIKit

final class BankManagerViewController: UIViewController {
    private var bank = Bank()
    private var timer: Timer?
    private let bankManagerView = BankManagerView()
    
    override func loadView() {
        view = bankManagerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bank.timerDelegate = self
        configureButton()
    }
    
    private func configureButton() {
        bankManagerView.addButton.addAction(UIAction(handler: { _ in self.bank.appendTenCustomers() }), for: .touchUpInside)
        bankManagerView.resetButton.addAction(UIAction(handler: { _ in self.resetTask() }), for: .touchUpInside)
    }
    
    private func resetTask() {
        bankManagerView.waitContentStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        bankManagerView.workContentStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        bank.resetBank()
    }
}

//MARK: - TimerDelegate Extension
extension BankManagerViewController: TimerDelegate {
    func updateTimerUI(totalTaskTime: String) {
        bankManagerView.taskTimeLabel.text = "업무시간 - \(totalTaskTime)"
    }
    
    func addWaitingQueue(customer: Customer) {
        DispatchQueue.main.async {
            let message = "\(customer.numberTicket) - \(customer.task.information.title)"
            let color = customer.task == .deposit ? UIColor.black : UIColor.purple
            let customerCell = CustomerCellView(message: message, color: color, tag: customer.numberTicket)
            self.bankManagerView.waitContentStackView.addArrangedSubview(customerCell)
        }
    }
    
    func moveToWorkingQueue(customer: Customer) {
        DispatchQueue.main.async {
            self.bankManagerView.waitContentStackView.subviews.forEach { subview in
                if subview.tag == customer.numberTicket {
                    self.bankManagerView.waitContentStackView.removeArrangedSubview(subview)
                    subview.removeFromSuperview()
                    self.bankManagerView.workContentStackView.addArrangedSubview(subview)
                }
            }
        }
    }
    
    func removeWorkingQueue(customer: Customer) {
        DispatchQueue.main.async {
            self.bankManagerView.workContentStackView.subviews.forEach { subview in
                if subview.tag == customer.numberTicket {
                    self.bankManagerView.workContentStackView.removeArrangedSubview(subview)
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
