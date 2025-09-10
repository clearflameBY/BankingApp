//
//  RatesViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//

//import UIKit
//
//class RatesViewController: UIViewController, UITableViewDataSource {
//    private var rates = [
//        Currency(name: "USD", value: 92.3),
//        Currency(name: "EUR", value: 101.4),
//        Currency(name: "CNY", value: 12.8)
//    ]
//    
//    private let tableView = UITableView()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Курсы валют"
//        view.backgroundColor = .systemBackground
//        
//        tableView.frame = view.bounds
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        view.addSubview(tableView)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return rates.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let rate = rates[indexPath.row]
//        cell.textLabel?.text = "\(rate.name): \(rate.value)"
//        return cell
//    }
//}
