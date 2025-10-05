// PlaceDetailsViewController.swift
import UIKit

final class PlaceDetailsViewController: UIViewController {
    
    private let details: GooglePlaceDetails
    
    // UI
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let statusLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Data
    private var weekdayText: [String] = []
    
    init(details: GooglePlaceDetails) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
        self.weekdayText = details.currentOpeningHours?.weekdayText
            ?? details.openingHours?.weekdayText
            ?? []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Режим работы"
        
        setupHeader()
        setupTable()
        applyDetails()
    }
    
    private func setupHeader() {
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.numberOfLines = 0
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.numberOfLines = 1
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, addressLabel, statusLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16)
        ])
        
        // Устанавливаем как таблицу + header
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = header
        
        // Важно: задать корректную ширину header и пересчитать высоту
        header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func applyDetails() {
        nameLabel.text = details.name
        addressLabel.text = details.formattedAddress
        
        let hours = details.currentOpeningHours ?? details.openingHours
        if let open = hours?.openNow {
            statusLabel.text = open ? "Сейчас открыто" : "Сейчас закрыто"
            statusLabel.textColor = open ? .systemGreen : .systemRed
        } else {
            statusLabel.text = "Нет данных об открытости"
            statusLabel.textColor = .secondaryLabel
        }
        
        tableView.reloadData()
    }
}

extension PlaceDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(weekdayText.count, 1)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Расписание по дням"
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
