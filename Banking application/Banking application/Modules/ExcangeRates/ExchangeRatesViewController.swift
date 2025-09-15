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
    
    private let formatter = DateFormatter()
    private let service = CurrencyService()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        
        title = "Курсы"
        setupTableView()
        setupSearch()
        setupRefresh()

        fetchRates()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
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

    @objc private func fetchRates() {
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
                    
                    self.filteredRates = self.rates
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
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
}

extension ExchangeRatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type: CurrencyType = section == 0 ? .fiat : section == 1 ? .crypto : .metal
        return filteredRates.filter { $0.type == type }.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Валюты"
        case 1: return "Криптовалюты"
        case 2: return "Драгметаллы"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type: CurrencyType = indexPath.section == 0 ? .fiat : indexPath.section == 1 ? .crypto : .metal
        let items = filteredRates.filter { $0.type == type }

        let rate = items[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "\(rate.name) - \(rate.fullName)"
        if rate.type == .crypto {
            cell.detailTextLabel?.text = "Курс: \(rate.rate) USD"
            } else {
                cell.detailTextLabel?.text = "Курс: \(rate.rate) BYN"
            }
        return cell
    }
}

extension ExchangeRatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath),
              let text = cell.textLabel?.text else { return }
        
        var curScale = 1.0
        var curId: Int = 0
        var currencyName: String = ""
        var currencyFullName: String = ""
        var isCrypto = false
        
        if text.contains("AUD") {
            curId = 440
            currencyName = "AUD"
        } else if text.contains("AMD") {
            curId = 510
            currencyName = "AMD"
            curScale = 1000
        } else if text.contains("BGN") {
            curId = 441
            currencyName = "BGN"
        } else if text.contains("BRL") {
            curId = 514
            currencyName = "BRL"
            curScale = 10
        } else if text.contains("UAH") {
            curId = 449
            currencyName = "UAH"
            curScale = 100
        } else if text.contains("DKK") {
            curId = 450
            currencyName = "DKK"
            curScale = 10
        } else if text.contains("AED") {
            curId = 513
            currencyName = "AED"
            curScale = 10
        } else if text.contains("USD") {
            curId = 431
            currencyName = "USD"
        } else if text.contains("VND") {
            curId = 512
            currencyName = "VND"
            curScale = 100000
        } else if text.contains("EUR") {
            curId = 451
            currencyName = "EUR"
        } else if text.contains("PLN") {
            curId = 452
            currencyName = "PLN"
            curScale = 10
        } else if text.contains("JPY") {
            curId = 508
            currencyName = "JPY"
            curScale = 100
        } else if text.contains("INR") {
            curId = 511
            currencyName = "INR"
            curScale = 100
        } else if text.contains("IRR") {
            curId = 461
            currencyName = "IRR"
            curScale = 100000
        } else if text.contains("ISK") {
            curId = 453
            currencyName = "ISK"
            curScale = 100
        } else if text.contains("CAD") {
            curId = 371
            currencyName = "CAD"
        } else if text.contains("CNY") {
            curId = 462
            currencyName = "CNY"
            curScale = 10
        } else if text.contains("KWD") {
            curId = 394
            currencyName = "KWD"
        } else if text.contains("MDL") {
            curId = 454
            currencyName = "MDL"
            curScale = 10
        } else if text.contains("NZD") {
            curId = 448
            currencyName = "NZD"
        } else if text.contains("NOK") {
            curId = 455
            currencyName = "NOK"
            curScale = 10
        } else if text.contains("RUB") {
            curId = 456
            currencyName = "RUB"
            curScale = 100
        } else if text.contains("XDR") {
            curId = 457
            currencyName = "XDR"
        } else if text.contains("SGD") {
            curId = 421
            currencyName = "SGD"
        } else if text.contains("KGS") {
            curId = 458
            currencyName = "KGS"
            curScale = 100
        } else if text.contains("KZT") {
            curId = 459
            currencyName = "KZT"
            curScale = 1000
        } else if text.contains("TRY") {
            curId = 460
            currencyName = "TRY"
            curScale = 10
        } else if text.contains("GBP") {
            curId = 429
            currencyName = "GBP"
        } else if text.contains("CZK") {
            curId = 463
            currencyName = "CZK"
            curScale = 100
        } else if text.contains("SEK") {
            curId = 464
            currencyName = "SEK"
            curScale = 10
        } else if text.contains("CHF") {
            curId = 426
            currencyName = "CHF"
        } else if text.contains("XAU") {
            curId = 0
            currencyName = "XAU"
        } else if text.contains("XAG") {
            curId = 1
            currencyName = "XAG"
        } else if text.contains("XPT") {
            curId = 2
            currencyName = "XPT"
        } else if text.contains("XPD") {
            curId = 3
            currencyName = "XPD"
        } else if text.contains("BTC") {
            currencyName = "BTC"
            currencyFullName = "bitcoin"
            isCrypto = true
        } else if text.contains("ETH") {
            currencyName = "ETH"
            currencyFullName = "ethereum"
            isCrypto = true
        }
        
        if curId > 370 && curId < 514 {
            let chartView = ChartScreenForCurrency(curScale: curScale, curId: curId, currencyName: currencyName)
            let chartVC = UIHostingController(rootView: chartView)
            navigationController?.pushViewController(chartVC, animated: true)
        } else if curId >= 0 && curId <= 4 && !isCrypto {
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
