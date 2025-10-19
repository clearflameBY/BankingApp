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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let allRatesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Все курсы", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
     }()
    
    let converterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Конвертер", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
     }()
    
    let searchATMButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Поиск банкоматов", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
     }()
    
    let rates: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.borderColor = UIColor.gray.cgColor
        table.layer.borderWidth = 1.0
        table.layer.cornerRadius = 8.0
        table.rowHeight = 40
        return table
    }()
    
    let butttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let notificationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔔", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let fromCurrencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let toCurrencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let amountField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Введите значение"
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Результат: 0.00"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .systemBackground
        
        addSubview(headerStack)
        headerStack.addArrangedSubview(balanceLabel)
        headerStack.addArrangedSubview(notificationsButton)
        
        addSubview(rates)
        
        addSubview(butttonsStack)
        butttonsStack.addArrangedSubview(allRatesButton)
        butttonsStack.addArrangedSubview(converterButton)
        butttonsStack.addArrangedSubview(searchATMButton)
        
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
            
            butttonsStack.topAnchor.constraint(equalTo: rates.bottomAnchor, constant: 5),
            butttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            butttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            mainStack.topAnchor.constraint(equalTo: butttonsStack.bottomAnchor, constant: 5),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
