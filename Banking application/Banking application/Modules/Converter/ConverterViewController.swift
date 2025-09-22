//
//  ConverterViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//

import UIKit

class ConverterViewController: UIViewController {
    
    private let service = CurrencyService()
    static let customView = ConverterView()
    private let calculateService = CalculateService()
    var storageVariable = ""
        
    override func loadView() {
        view = ConverterViewController.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Конвертер"
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite(for: <#T##Currency#>)))
        recognizer.numberOfTapsRequired = 2
        
        let leftLabelTapped = UIAction(handler: { _ in
            ConverterViewController.customView.tableFrom.isHidden.toggle()
        })
        let rightLabelTapped = UIAction(handler: { _ in
            ConverterViewController.customView.tableTo.isHidden.toggle()
        })
        let calculateConversion = UIAction(handler: { _ in
            self.calculateService.calculateConversionForConverter()
        })
        let swapCurrency = UIAction(handler: { _ in
            guard ConverterViewController.customView.buttonFrom.titleLabel?.text != "Choose currency from:",
                  ConverterViewController.customView.buttonTo.titleLabel?.text != "Choose currency to:" else { return }
            
            self.storageVariable = ConverterViewController.customView.buttonFrom.titleLabel?.text ?? ""
            ConverterViewController.customView.buttonFrom.setTitle(ConverterViewController.customView.buttonTo.titleLabel?.text, for: .normal)
            ConverterViewController.customView.buttonTo.setTitle(self.storageVariable, for: .normal)
        })
        
        ConverterViewController.customView.buttonFrom.addAction(leftLabelTapped, for: .touchUpInside)
        ConverterViewController.customView.buttonTo.addAction(rightLabelTapped, for: .touchUpInside)
        ConverterViewController.customView.swapButton.addAction(swapCurrency, for: .touchUpInside)
        ConverterViewController.customView.textField.addAction(calculateConversion, for: .editingChanged)
        ConverterViewController.customView.buttonFrom.addAction(calculateConversion, for: .allEditingEvents)
        ConverterViewController.customView.buttonTo.addAction(calculateConversion, for: .allEditingEvents)

        
        ConverterViewController.customView.tableFrom.delegate = self
        ConverterViewController.customView.tableFrom.dataSource = self
        ConverterViewController.customView.tableTo.delegate = self
        ConverterViewController.customView.tableTo.dataSource = self
    }
    
    private func saveFavorites(_ currencies: [Currency]) {
        let data = try? JSONEncoder().encode(currencies)
        UserDefaults.standard.set(data, forKey: "favoriteCurrencies")
    }

    private func loadFavorites() -> [Currency] {
        guard let data = UserDefaults.standard.data(forKey: "favoriteCurrencies"),
              let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
            return []
        }
        return currencies
    }
    
    private func toggleFavorite(for currency: Currency) {
        var favorites = loadFavorites()
        if favorites.contains(currency) {
            favorites.removeAll { $0 == currency }
        } else {
            favorites.append(currency)
        }
        saveFavorites(favorites)
    }
}

extension ConverterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DashboardViewController.currencyCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        cell.textLabel?.text = DashboardViewController.currencyCodes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == ConverterViewController.customView.tableFrom {
            ConverterViewController.customView.buttonFrom.setTitle(DashboardViewController.currencyCodes[indexPath.row], for: .normal)
            ConverterViewController.customView.tableFrom.isHidden = true
        } else if tableView == ConverterViewController.customView.tableTo {
            ConverterViewController.customView.buttonTo.setTitle(DashboardViewController.currencyCodes[indexPath.row], for: .normal)
            ConverterViewController.customView.tableTo.isHidden = true
        }
        
    }
}
