//
//  CustomerCellView.swift
//  BankManagerUIApp
//
//  Created by hoon, minsup on 2023/07/21.
//

import UIKit

final class CustomerCellView: UIView {
    let itemLabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    init(message: String, color: UIColor, tag: Int) {
        super.init(frame: .zero)
        itemLabel.text = message
        itemLabel.textColor = color
        self.tag = tag
        configureItemLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureItemLabel() {
        addSubview(itemLabel)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: itemLabel.centerXAnchor),
            centerYAnchor.constraint(equalTo: itemLabel.centerYAnchor),
            heightAnchor.constraint(equalTo: itemLabel.heightAnchor)
        ])
    }
}
