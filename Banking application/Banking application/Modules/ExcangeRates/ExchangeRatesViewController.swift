//
//  RatesViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//
import UIKit

class ExchangeRatesViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var rates: [CurrencyRate2] = []
    private var filteredRates: [CurrencyRate2] = []

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Курсы"

        setupTableView()
        setupSearch()
        setupRefresh()

        fetchRates()
    }

    private func setupTableView() {
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
        // Вызов в Presenter или напрямую в API-сервис
        // пока заглушка
        self.rates = mockRates()
        self.filteredRates = self.rates
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }

    private func mockRates() -> [CurrencyRate2] {
        var rates: [CurrencyRate2] = []
        DashboardViewController.rates.forEach { element in
            rates.append(CurrencyRate2(name: element.curAbbreviation,
                                       fullName: element.curName,
                                       rate: element.curOfficialRate / element.curScale,
                                       type: .fiat))
        }
        rates.removeFirst()
        return rates
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
        cell.detailTextLabel?.text = "Курс: \(rate.rate) BYN"
        return cell
    }
}

extension ExchangeRatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // переход на экран с графиком
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
