//
//  DashboardViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 14.08.25.
//
import UIKit
import Charts
import SwiftUI

final class DashboardViewController: UIViewController {
    
    static var rates: [CurrencyRate] = []
    private var metals : [MetalModel] = []
    private var curenciesData: [String] = []
    static var currencyCodes: [String] = []
    private var currentAbbreviationOfCurrency = ""
    
    private let formatter = DateFormatter()
    private let service = CurrencyService()
    static let customView = DashboardView()
    private let calculateService = CalculateService()
    
    override func loadView() {
        view = DashboardViewController.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        formatter.dateFormat = "yyyy-MM-dd"
        title = "Главный экран"
        
        fetchData()
        
        let openRates = UIAction(handler: { _ in
            self.tabBarController?.selectedIndex = 2
        })
        
        let openConverter = UIAction(handler: { _ in
            self.tabBarController?.selectedIndex = 3
        })
        
        let openSearchingATMs = UIAction(handler: { _ in
            self.tabBarController?.selectedIndex = 1
        })
        
        let calculateConversion = UIAction(handler: { _ in
            self.calculateService.calculateConversionForDashboard()
        })
        
        let recognizerHideKeyboard = UITapGestureRecognizer(target: DashboardViewController.customView, action: #selector(DashboardViewController.customView.endEditing))
        
        recognizerHideKeyboard.cancelsTouchesInView = false // for working tableView
        DashboardViewController.customView.addGestureRecognizer(recognizerHideKeyboard)
        
        DashboardViewController.customView.allRatesButton.addAction(openRates, for: .touchUpInside)
        DashboardViewController.customView.converterButton.addAction(openConverter, for: .touchUpInside)
        DashboardViewController.customView.searchATMButton.addAction(openSearchingATMs, for: .touchUpInside)
        DashboardViewController.customView.amountField.addAction(calculateConversion, for: .editingChanged)
        DashboardViewController.customView.fromCurrencyPicker.dataSource = self
        DashboardViewController.customView.fromCurrencyPicker.delegate = self
        DashboardViewController.customView.toCurrencyPicker.dataSource = self
        DashboardViewController.customView.toCurrencyPicker.delegate = self
        DashboardViewController.customView.rates.dataSource = self
        DashboardViewController.customView.rates.delegate = self
    }
    
    private func fetchData() {
        service.fetchRatesForCurrency { [weak self] result in
            switch result {
            case .success(let rates):
                self?.handleSuccessFetchRates(rates)
            case .failure(let error):
                print("Ошибка загрузки:", error.localizedDescription)
            }
        }
    }
    
    private func handleSuccessFetchRates(_ rates: [CurrencyRate]) {
        var allRates = rates
        
        let byn = CurrencyRate( date: formatter.string(from: Date()), curOfficialRate: 1.0, curID: 0, curAbbreviation: "BYN", curScale: 1, curName: "Белорусский рубль")
        allRates.insert(byn, at: 0)
        
        DashboardViewController.rates = allRates
        DashboardViewController.currencyCodes = allRates.map { $0.curAbbreviation }
        
        DispatchQueue.main.async {
            self.updateRatesUI()
            DashboardViewController.customView.fromCurrencyPicker.reloadAllComponents()
            DashboardViewController.customView.toCurrencyPicker.reloadAllComponents()
        }
    }
    
    private func updateRatesUI() {
        // Валюты
        let wantedCurrencies = ["UAH", "USD", "EUR", "RUB"]
        for rate in DashboardViewController.rates.filter({ wantedCurrencies.contains($0.curAbbreviation) }) {
            let ratePerOne = rate.curOfficialRate / Double(rate.curScale)
            curenciesData.append("\(rate.curAbbreviation): \(String(format: "%.4f", ratePerOne)) BYN")
        }
        
        // Металлы
        var dayForMetalCurrency = Date()
        
        while Calendar.current.isDateInWeekend(dayForMetalCurrency) {
            dayForMetalCurrency = Calendar.current.date(byAdding: .day, value: -1, to: dayForMetalCurrency)!
        }
        let dayForMetalCurrencyString = formatter.string(from: dayForMetalCurrency)
        
        service.fetchRatesForMetals(dayForMetalCurrencyString: dayForMetalCurrencyString) { result in
            switch result {
            case .success(let metals):
                self.fetchMetals(metals)
            case .failure(let error):
                print("Ошибка загрузки:", error.localizedDescription)
            }
        }
    }

    private func fetchMetals(_ metals: [MetalModel]) {
        self.metals = metals
        let wantedMetalsID = [0,1]
        for metal in self.metals.filter({ wantedMetalsID.contains($0.metalId) }) {
            let name = metal.metalId == 0 ? "Золото" : "Серебро"
            self.curenciesData.append("\(name): \(metal.value) BYN/грамм")
        }
        DashboardViewController.customView.rates.reloadData()

    }
    
    @objc private func showGraph(row: Int) {
        var currencyId = 0
        var currentAbbreviationOfCurrency = ""
        var curScale = 1.0
        
        switch row {
        case 0:
            currencyId = 449
            currentAbbreviationOfCurrency = "UAH"
            curScale = 100
        case 1:
            currencyId = 431
            currentAbbreviationOfCurrency = "USD"
        case 2:
            currencyId = 451
            currentAbbreviationOfCurrency = "EUR"
        case 3:
            currencyId = 456
            currentAbbreviationOfCurrency = "RUB"
            curScale = 100
        case 4:
            currencyId = 0
            currentAbbreviationOfCurrency = "XAU"
        case 5:
            currencyId = 1
            currentAbbreviationOfCurrency = "XAG"
        default:
            break
        }
        
        if currencyId == 0 || currencyId == 1 {
            let chartView = ChartScreenForMetals(curId: currencyId, currencyName: currentAbbreviationOfCurrency)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        } else {
            let chartView = ChartScreenForCurrency(curScale: curScale, curId: currencyId, currencyName: currentAbbreviationOfCurrency)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        }
    }
}

extension DashboardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        DashboardViewController.currencyCodes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        DashboardViewController.currencyCodes[safe: row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        calculateService.calculateConversionForDashboard()
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curenciesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.text = curenciesData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DashboardViewController.customView.rates.deselectRow(at: indexPath, animated: true)
        showGraph(row: indexPath.row)
    }
}
