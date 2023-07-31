//
//  BankManagerView.swift
//  BankManagerUIApp
//
//  Created by hoon, minsup on 2023/07/21.
//

import UIKit

final class BankManagerView: UIView {
    lazy var addButton = {
        let button = UIButton()
        button.setTitle("고객 10명 추가", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        return button
    }()
    
    lazy var resetButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        return button
    }()
    
    private let buttonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    let taskTimeLabel = {
        let label = UILabel()
        label.text = "업무시간 - 00:00:000"
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        
        return label
    }()
    
    private let waitLabel = {
        let label = UILabel()
        label.text = "대기중"
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.backgroundColor = .green
        
        return label
    }()
    
    private let waitScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    let waitContentStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let waitStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }()
    
    private let workLabel = {
        let label = UILabel()
        label.text = "업무중"
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.backgroundColor = .blue
        
        return label
    }()
    
    private let workScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    let workContentStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let workStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
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
        stackView.spacing = 12
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundColor = .systemBackground
        
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
        
        addSubview(totalStackView)
    }
    
    private func configureConstraint() {
        configureTotalStackView()
        configureWaitContentStackView()
        configureWorkContentStackView()
    }
    
    private func configureTotalStackView() {
        NSLayoutConstraint.activate([
            totalStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            totalStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            totalStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            totalStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureWaitContentStackView() {
        NSLayoutConstraint.activate([
            waitContentStackView.topAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.topAnchor),
            waitContentStackView.leadingAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.leadingAnchor),
            waitContentStackView.trailingAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.trailingAnchor),
            waitContentStackView.bottomAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.bottomAnchor),
            waitContentStackView.widthAnchor.constraint(equalTo: waitScrollView.frameLayoutGuide.widthAnchor),
            waitContentStackView.heightAnchor.constraint(equalTo: waitScrollView.contentLayoutGuide.heightAnchor)
        ])
        
        let minimumWaitContentStackViewHeight = waitContentStackView.heightAnchor.constraint(equalToConstant: 0)
        minimumWaitContentStackViewHeight.priority = .defaultLow
        minimumWaitContentStackViewHeight.isActive = true
    }
    
    private func configureWorkContentStackView() {
        NSLayoutConstraint.activate([
            workContentStackView.topAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.topAnchor),
            workContentStackView.leadingAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.leadingAnchor),
            workContentStackView.trailingAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.trailingAnchor),
            workContentStackView.bottomAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.bottomAnchor),
            workContentStackView.widthAnchor.constraint(equalTo: workScrollView.frameLayoutGuide.widthAnchor),
            workContentStackView.heightAnchor.constraint(equalTo: workScrollView.contentLayoutGuide.heightAnchor)
        ])
        
        let minimumWorkContentStackViewHeight = workContentStackView.heightAnchor.constraint(equalToConstant: 0)
        minimumWorkContentStackViewHeight.priority = .defaultLow
        minimumWorkContentStackViewHeight.isActive = true
    }
}
