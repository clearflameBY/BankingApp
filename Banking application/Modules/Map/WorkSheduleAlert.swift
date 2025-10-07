//
//  WorkSheduleAlert.swift
//  Banking application
//
//  Created by Илья Степаненко on 6.10.25.
//

import UIKit

class WorkSheduleAlert: UIView {
    
    private var weekdayText: [String] = []
    private let details: GooglePlaceDetails
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Режим работы:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let closeAlertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⨉", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let statusLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var headerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    init(frame: CGRect, details: GooglePlaceDetails) {
        
        self.details = details
        super.init(frame: frame)
        
        if MapViewController.isAlertShown {
            self.removeAlertView()
        }
                
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        
        let closeAction = UIAction(handler: { _ in
            self.removeAlertView()
            MapViewController.isAlertShown = false
        })
        closeAlertButton.addAction(closeAction, for: .touchUpInside)
        
        self.weekdayText = details.currentOpeningHours?.weekdayText
            ?? details.openingHours?.weekdayText
            ?? []
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
                
        addSubview(closeAlertButton)
        setupHeader()
        setupTable()
        applyDetails()
        
        NSLayoutConstraint.activate([
            closeAlertButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            closeAlertButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            closeAlertButton.heightAnchor.constraint(equalTo: closeAlertButton.widthAnchor),

            headerStack.topAnchor.constraint(equalTo: closeAlertButton.bottomAnchor, constant: 5),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupHeader() {
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.numberOfLines = 0
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.numberOfLines = 1
        
        addSubview(headerStack)
        addSubview(tableView)

        headerStack.addArrangedSubview(nameLabel)
        headerStack.addArrangedSubview(addressLabel)
        headerStack.addArrangedSubview(statusLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func applyDetails() {
        nameLabel.text = details.name
        addressLabel.text = details.formattedAddress
        
        let hours = details.currentOpeningHours ?? details.openingHours
        if let open = hours?.openNow {
            statusLabel.text = open ? "Сейчас открыто" : "Сейчас закрыто"
            statusLabel.textColor = open ? .systemGreen : .systemRed
        } else {
            statusLabel.text = "Нет данных о режиме работы"
            statusLabel.textColor = .secondaryLabel
        }
        
        tableView.reloadData()
    }
    
    private func removeAlertView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = -self.frame.height
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

extension WorkSheduleAlert: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(weekdayText.count, 1)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Расписание по дням:"
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if weekdayText.isEmpty {
            cell.textLabel?.text = "Нет данных о режиме работы"
            cell.textLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = weekdayText[indexPath.row]
            cell.selectionStyle = .none
        }
        return cell
    }
}

