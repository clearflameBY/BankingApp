//
//  RatesViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//
import UIKit
import SwiftUI

class ExchangeRatesViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var rates: [CurrencyRate2] = []
    private var filteredRates: [CurrencyRate2] = []
    
    private var favoriteCodes: Set<String> = []
    private let favoritesKey = "FavoriteCurrencyCodes"
    
    private let formatter = DateFormatter()
    private let service = CurrencyService()
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        title = "Курсы"
        
        let recognizerHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizerHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizerHideKeyboard)
        
        setupTableView()
        setupSearch()
        setupRefresh()
        loadFavorites()
        fetchRates()
    }
    
    private func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "exchangeCell")
    }
    
    private func setupSearch() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    private func setupRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchRates), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Favorites
    private func loadFavorites() {
        if let codes = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteCodes = Set(codes)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteCodes), forKey: favoritesKey)
    }
    
    private func isFavorite(code: String) -> Bool {
        favoriteCodes.contains(code)
    }
    
    private func toggleFavorite(code: String) {
        if favoriteCodes.contains(code) {
            favoriteCodes.remove(code)
        } else {
            favoriteCodes.insert(code)
        }
        saveFavorites()
        tableView.reloadData()
    }
    
    @objc private func fetchRates() {
        rates.removeAll()
        filteredRates.removeAll()
        tableView.reloadData()
        mockRates()
        mockMetals()
        mockCryptos()
    }
    
    private func mockRates(){
        service.fetchRatesForCurrency { result in
            switch result {
            case .success(let currencyRates):
                currencyRates.forEach { element in
                    self.rates.append(CurrencyRate2(name: element.curAbbreviation,
                                                    fullName: element.curName,
                                                    rate: element.curOfficialRate / element.curScale,
                                                    type: .fiat))
                }
                DispatchQueue.main.async {
                    self.filteredRates = self.rates
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                print("Ошибка загрузки:", error.localizedDescription)
            }
        }
    }
    
    private func mockMetals(){
        var dayForMetalCurrency = Date()
        
        while Calendar.current.isDateInWeekend(dayForMetalCurrency) {
            dayForMetalCurrency = Calendar.current.date(byAdding: .day, value: -1, to: dayForMetalCurrency)!
        }
        let dayForMetalCurrencyString = formatter.string(from: dayForMetalCurrency)
        
        service.fetchRatesForMetals(dayForMetalCurrencyString: dayForMetalCurrencyString) { result in
            switch result {
            case .success(let metals):
                metals.forEach { element in
                    self.rates.append(CurrencyRate2(name: element.metalId == 0 ? "XAU" : element.metalId == 1 ? "XAG" : element.metalId == 2 ? "XPT" : element.metalId == 3 ? "XPD" : "",
                                                    fullName: element.metalId == 0 ? "Золото" : element.metalId == 1 ? "Серебро" : element.metalId == 2 ? "Платина" : element.metalId == 3 ? "Палладий" : "",
                                                    rate: element.value,
                                                    type: .metal))
                }
                DispatchQueue.main.async {
                    self.filteredRates = self.rates
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                print("Ошибка загрузки:", error.localizedDescription)
            }
        }
    }
    
    private func mockCryptos() {
        service.fetchCryptoPrice(crypto: "bitcoin") { price in
            self.rates.append(CurrencyRate2(name: "BTC", fullName: "Bitcoin", rate: price ?? 0, type: .crypto))
            DispatchQueue.main.async {
                self.filteredRates = self.rates
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
        
        service.fetchCryptoPrice(crypto: "ethereum") { price in
            self.rates.append(CurrencyRate2(name: "ETH", fullName: "Etherium", rate: price ?? 0, type: .crypto))
            DispatchQueue.main.async {
                self.filteredRates = self.rates
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Section helpers
    private func section(at index: Int) -> exchangesTableSection {
        guard let s = exchangesTableSection(rawValue: index) else {
            fatalError("Unexpected section index: \(index)")
        }
        return s
    }
    
    private func items(for section: exchangesTableSection) -> [CurrencyRate2] {
        switch section {
        case .favorites:
            return filteredRates.filter { isFavorite(code: $0.name) }.sorted(by: { $0.fullName < $1.fullName })
        case .fiat:
            return filteredRates.filter { $0.type == .fiat && !isFavorite(code: $0.name) }
        case .crypto:
            return filteredRates.filter { $0.type == .crypto && !isFavorite(code: $0.name) }
        case .metal:
            return filteredRates.filter { $0.type == .metal && !isFavorite(code: $0.name) }.sorted(by: { $0.fullName < $1.fullName })
        }
    }
}

// MARK: - Table View Data Source
extension ExchangeRatesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        exchangesTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        let s = section(at: sectionIndex)
        return items(for: s).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        section(at: sectionIndex).title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exchangeCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        let s = section(at: indexPath.section)
        let rate = items(for: s)[indexPath.row]
        let isFav = isFavorite(code: rate.name)

        cell.configureCell(rate: rate, isFavorite: isFav)
        cell.onToggleFavorite = { [weak self] in
            self?.toggleFavorite(code: rate.name)
        }
        return cell
    }
}

// MARK: - Table View Delegate
extension ExchangeRatesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let s = section(at: indexPath.section)
        let rate = items(for: s)[indexPath.row]
        
        let isFav = isFavorite(code: rate.name)
        let action = UIContextualAction(style: .normal,
                                        title: isFav ? "Убрать из избранного" : "В избранное") { [weak self] _, _, completion in
            self?.toggleFavorite(code: rate.name)
            completion(true)
        }
        action.backgroundColor = isFav ? .systemOrange : .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let s = section(at: indexPath.section)
        let rate = items(for: s)[indexPath.row]
        let code = rate.name

        var curScale = 1.0
        var curId: Int = -1
        let currencyName: String = code
        var currencyFullName: String = ""
        var isCrypto = false

        // Маппинг по коду валюты/металла/крипты (оставить как есть)
        switch code {
        case "AUD": curId = 440
        case "AMD": curId = 510; curScale = 1000
        case "BGN": curId = 441
        case "BRL": curId = 514; curScale = 10
        case "UAH": curId = 449; curScale = 100
        case "DKK": curId = 450; curScale = 10
        case "AED": curId = 513; curScale = 10
        case "USD": curId = 431
        case "VND": curId = 512; curScale = 100000
        case "EUR": curId = 451
        case "PLN": curId = 452; curScale = 10
        case "JPY": curId = 508; curScale = 100
        case "INR": curId = 511; curScale = 100
        case "IRR": curId = 461; curScale = 100000
        case "ISK": curId = 453; curScale = 100
        case "CAD": curId = 371
        case "CNY": curId = 462; curScale = 10
        case "KWD": curId = 394
        case "MDL": curId = 454; curScale = 10
        case "NZD": curId = 448
        case "NOK": curId = 455; curScale = 10
        case "RUB": curId = 456; curScale = 100
        case "XDR": curId = 457
        case "SGD": curId = 421
        case "KGS": curId = 458; curScale = 100
        case "KZT": curId = 459; curScale = 1000
        case "TRY": curId = 460; curScale = 10
        case "GBP": curId = 429
        case "CZK": curId = 463; curScale = 100
        case "SEK": curId = 464; curScale = 10
        case "CHF": curId = 426
        case "XAU": curId = 0
        case "XAG": curId = 1
        case "XPT": curId = 2
        case "XPD": curId = 3
        case "BTC":
            isCrypto = true
            currencyFullName = "bitcoin"
        case "ETH":
            isCrypto = true
            currencyFullName = "ethereum"
        default:
            break
        }
        
        if curId > 370 && curId < 515 {
            let chartView = ChartScreenForCurrency(curScale: curScale, curId: curId, currencyName: currencyName)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        } else if (0...4).contains(curId) && !isCrypto {
            let chartView = ChartScreenForMetals(curId: curId, currencyName: currencyName)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        } else if isCrypto {
            let chartView = ChartScreenForCrypto(currencyName: currencyName, currencyFullName: currencyFullName)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        }
    }
}

// MARK: - Search Controller
extension ExchangeRatesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            filteredRates = rates
            tableView.reloadData()
            return
        }
        
        filteredRates = rates.filter {
            $0.name.lowercased().contains(text.lowercased()) ||
            $0.fullName.lowercased().contains(text.lowercased())
        }
        
        tableView.reloadData()
    }
}

