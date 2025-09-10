//
//  ConverterViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//

import UIKit

class ConverterViewController: UIViewController {
    private let amountField = UITextField()
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Конвертер"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        amountField.placeholder = "Введите сумму"
        amountField.borderStyle = .roundedRect
        amountField.keyboardType = .decimalPad
        
        resultLabel.text = "Результат: 0"
        resultLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [amountField, resultLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
