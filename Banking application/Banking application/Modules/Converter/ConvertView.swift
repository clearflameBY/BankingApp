//
//  ConvertView.swift
//  Banking application
//
//  Created by Илья Степаненко on 16.09.25.
//
import UIKit

class ConverterView: UIView {
    
    let historyButton : UIButton = {
        let historyButton = UIButton()
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        config.baseBackgroundColor = .systemYellow
        historyButton.configuration = config
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.setTitleColor(.black, for: .normal)
        historyButton.setTitle("История конверсий", for: .normal)
        historyButton.layer.borderColor = UIColor.black.cgColor
        historyButton.layer.borderWidth = 1
        historyButton.layer.cornerRadius = 8
        return historyButton
    }()
    
    let swapButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        config.baseBackgroundColor = .white
        button.configuration = config
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Поменять местами", for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.text = "Я хочу купить:"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.text = "Мне надо отдать:"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.placeholder = "Введите значение"
        return field
    }()
    
    let labelResult: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.00"
        return label
    }()
    
    let tableFrom: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.borderColor = UIColor.gray.cgColor
        table.layer.borderWidth = 1.0
        table.layer.cornerRadius = 8.0
        return table
    }()
    
    let tableTo: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.borderColor = UIColor.gray.cgColor
        table.layer.borderWidth = 1.0
        table.layer.cornerRadius = 8.0
        return table
    }()
    
    let buttonFrom: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Choose currency from:", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let buttonTo: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Choose currency to:", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let stack1 = UIStackView(arrangedSubviews: [buttonFrom, tableFrom, label1, textField])
        stack1.axis = .vertical
        stack1.translatesAutoresizingMaskIntoConstraints = false
        
        let stack2 = UIStackView(arrangedSubviews: [buttonTo, tableTo, label2, labelResult])
        stack2.axis = .vertical
        stack2.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(historyButton)
        addSubview(swapButton)
        addSubview(stack1)
        addSubview(stack2)
        
        NSLayoutConstraint.activate([
            historyButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            historyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            swapButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 250),
            swapButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            buttonFrom.topAnchor.constraint(equalTo: stack1.topAnchor),
            buttonFrom.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            tableFrom.heightAnchor.constraint(equalToConstant: 300),
            tableFrom.bottomAnchor.constraint(equalTo: stack1.bottomAnchor),
            tableFrom.leadingAnchor.constraint(equalTo: stack1.leadingAnchor),
            tableFrom.trailingAnchor.constraint(equalTo: stack1.trailingAnchor),
            
            buttonTo.topAnchor.constraint(equalTo: stack2.topAnchor),
            buttonTo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),

            tableTo.heightAnchor.constraint(equalToConstant: 300),
            tableTo.bottomAnchor.constraint(equalTo: stack2.bottomAnchor),
            tableTo.leadingAnchor.constraint(equalTo: stack2.leadingAnchor),
            tableTo.trailingAnchor.constraint(equalTo: stack2.trailingAnchor),
            
            stack1.topAnchor.constraint(equalTo: swapButton.bottomAnchor),
            stack1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            stack2.topAnchor.constraint(equalTo: swapButton.bottomAnchor),
            stack2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
