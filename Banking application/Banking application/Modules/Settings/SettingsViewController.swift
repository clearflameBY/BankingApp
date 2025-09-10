//
//  SettingsViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource {
    private let options = ["Face ID вход", "Push уведомления", "Выход"]
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        view.backgroundColor = .systemBackground
        
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
}
