//
//  ConversionsHistoryViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.10.25.
//
import UIKit

final class ConversionsHistoryViewController: UIViewController {
    
    private var history: [ConversionHistoryModel] = []
    private let historyRepository = ConversionsHistoryRepository()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        history = historyRepository.getAllContributions()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        history = historyRepository.getAllContributions()
        tableView.reloadData()
    }
}

extension ConversionsHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = .current
        let localDateString = formatter.string(from: history[indexPath.row].date)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = UIListContentConfiguration.cell()
        config.text = "\(history[indexPath.row].valueFrom), \(history[indexPath.row].currencyFrom), \(history[indexPath.row].currencyTo), \(history[indexPath.row].valueTo), \(localDateString)"
        cell.contentConfiguration = config
        return cell
    }
    
    
}
