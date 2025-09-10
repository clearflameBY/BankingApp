//
//  DashboardView.swift
//  Banking application
//
//  Created by Илья Степаненко on 20.08.25.
//

import UIKit

final class DashboardView: UIView {
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Баланс: 0 BYN"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    let allRatesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Все курсы", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
     }()
    
    let rates: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let notificationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔔", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        return button
    }()
    
    let fromCurrencyPicker = UIPickerView()
    let toCurrencyPicker = UIPickerView()
    
    let amountField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Сумма"
        tf.keyboardType = .decimalPad
        return tf
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Результат: 0"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let converterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(headerStack)
        headerStack.addArrangedSubview(balanceLabel)
        headerStack.addArrangedSubview(notificationsButton)
        
        addSubview(rates)
        addSubview(allRatesButton)
        
        addSubview(converterStack)
        converterStack.addArrangedSubview(fromCurrencyPicker)
        converterStack.addArrangedSubview(toCurrencyPicker)
        
        addSubview(mainStack)
        mainStack.addArrangedSubview(amountField)
        mainStack.addArrangedSubview(converterStack)
        mainStack.addArrangedSubview(resultLabel)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            rates.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            rates.leadingAnchor.constraint(equalTo: leadingAnchor),
            rates.trailingAnchor.constraint(equalTo: trailingAnchor),
            rates.heightAnchor.constraint(equalToConstant: 250),
            
            allRatesButton.topAnchor.constraint(equalTo: rates.bottomAnchor, constant: 5),
            allRatesButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            mainStack.topAnchor.constraint(equalTo: allRatesButton.bottomAnchor, constant: 5),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
