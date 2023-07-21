//
//  BankManagerUIApp - ViewController.swift
//  Created by yagom.
//  Copyright © yagom academy. All rights reserved.
//

import UIKit

class BankManagerViewController: UIViewController, TimerDelegate {
    private var bank = Bank()
    private var timer: Timer?
        
    private lazy var addButton = {
        let button = UIButton()
        button.setTitle("고객 10명 추가", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.backgroundColor = .cyan
        button.addAction(UIAction(handler: { _ in self.bank.appendTenCustomers() }), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var resetButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.backgroundColor = .red
        button.addAction(UIAction(handler: { _ in self.resetTask() }), for: .touchUpInside)
        
        return button
    }()
    
    private let buttonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let taskTimeLabel = {
        let label = UILabel()
        label.text = "업무시간 - 00:00:000"
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.backgroundColor = .darkGray
        
        return label
    }()
    
    private let waitLabel = {
        let label = UILabel()
        label.text = "대기중"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.backgroundColor = .green
        
        return label
    }()
    
    private let waitScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .orange
        
        return scrollView
    }()
    
    private let waitContentStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.backgroundColor = .red
        
        return stackView
    }()
    
    private let waitStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let workLabel = {
        let label = UILabel()
        label.text = "업무중"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.backgroundColor = .blue
        
        return label
    }()
    
    private let workScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .purple
        
        return scrollView
    }()
    
    private let workContentStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.backgroundColor = .red
        
        return stackView
    }()
    
    private let workStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private let queueStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let totalStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.backgroundColor = .black
        
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bank.timerDelegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("view"), object: nil, queue: .main) { notification in
            self.addWaitingQueue(notification as NSNotification)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("start"), object: nil, queue: .main) { notification in
            self.passWaitingQueueToWorkingQueue(notification as NSNotification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("end"), object: nil, queue: .main) { notification in
            self.removeWorkingQueue(notification as NSNotification)
        }
        
        view.backgroundColor = .systemBackground
        
        buttonStackView.addArrangedSubview(addButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        waitScrollView.addSubview(waitContentStackView)
        
        waitStackView.addArrangedSubview(waitLabel)
        waitStackView.addArrangedSubview(waitScrollView)
        
        workScrollView.addSubview(workContentStackView)
        
        workStackView.addArrangedSubview(workLabel)
        workStackView.addArrangedSubview(workScrollView)
        
        queueStackView.addArrangedSubview(waitStackView)
        queueStackView.addArrangedSubview(workStackView)
        
        totalStackView.addArrangedSubview(buttonStackView)
        totalStackView.addArrangedSubview(taskTimeLabel)
        totalStackView.addArrangedSubview(queueStackView)
        
        view.addSubview(totalStackView)
        
        NSLayoutConstraint.activate([
            totalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            totalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            totalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            totalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            waitContentStackView.topAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.topAnchor),
            waitContentStackView.leadingAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.leadingAnchor),
            waitContentStackView.trailingAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.trailingAnchor),
            waitContentStackView.bottomAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.bottomAnchor),
            waitContentStackView.heightAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.heightAnchor),
            waitContentStackView.widthAnchor.constraint(equalTo: waitScrollView.frameLayoutGuide.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            workContentStackView.topAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.topAnchor),
            workContentStackView.leadingAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.leadingAnchor),
            workContentStackView.trailingAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.trailingAnchor),
            workContentStackView.bottomAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.bottomAnchor),
            workContentStackView.heightAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.heightAnchor),
            workContentStackView.widthAnchor.constraint(equalTo: workScrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    func updateTimerUI(totalTaskTime: String) {
        //TODO: UI update
        print(totalTaskTime)
        taskTimeLabel.text = "업무시간 - \(totalTaskTime)"
    }
    
    func resetTask() {
        waitContentStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        workContentStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        bank.resetBank()
    }
    
    @objc private func addWaitingQueue(_ notification: NSNotification) {
        let customer = notification.userInfo!["customer"] as! Customer
//        print("\(customer.numberTicket) - \(customer.task.information.title)")
        
        let customerLabel = {
            let label = UILabel()
            label.text = "\(customer.numberTicket) - \(customer.task.information.title)"
            label.tag = customer.numberTicket
            
            return label
        }()
        
        waitContentStackView.addArrangedSubview(customerLabel)
    }
    
    @objc private func passWaitingQueueToWorkingQueue(_ notification: NSNotification) {
        let customer = notification.userInfo!["customer"] as! Customer
        
        waitContentStackView.subviews.forEach { subview in
            if subview.tag == customer.numberTicket {
                waitContentStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
                workContentStackView.addArrangedSubview(subview)
            }
        }
    }
    
    @objc private func removeWorkingQueue(_ notification: NSNotification) {
        let customer = notification.userInfo!["customer"] as! Customer
        
        workContentStackView.subviews.forEach { subview in
            if subview.tag == customer.numberTicket {
                workContentStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
    }
}
