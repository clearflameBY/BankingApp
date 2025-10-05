//
//  ConverterViewController.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//

import UIKit

final class ConverterViewController: UIViewController {
    
    private let service = CurrencyService()
    static let customView = ConverterView()
    private let calculateService = CalculateService()
    var storageForVariable = ""
        
    override func loadView() {
        view = ConverterViewController.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Конвертер"
        
        let leftLabelTapped = UIAction(handler: { _ in
            ConverterViewController.customView.tableFrom.isHidden.toggle()
        })
        let rightLabelTapped = UIAction(handler: { _ in
            ConverterViewController.customView.tableTo.isHidden.toggle()
        })
        let calculateConversion = UIAction(handler: { _ in
            self.calculateService.calculateConversionForConverter()
        })
        let openHistory = UIAction(handler: { _ in
            self.present(ConversionsHistoryViewController(), animated: true)
        })
        let swapCurrency = UIAction(handler: { _ in
            guard ConverterViewController.customView.buttonFrom.titleLabel?.text != "Choose currency from:",
                  ConverterViewController.customView.buttonTo.titleLabel?.text != "Choose currency to:" else { return }
            
            self.storageForVariable = ConverterViewController.customView.buttonFrom.titleLabel?.text ?? ""
            ConverterViewController.customView.buttonFrom.setTitle(ConverterViewController.customView.buttonTo.titleLabel?.text, for: .normal)
            ConverterViewController.customView.buttonTo.setTitle(self.storageForVariable, for: .normal)
            
            self.calculateService.calculateConversionForConverter()
        })
        let recognizerHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizerHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizerHideKeyboard)
        
        ConverterViewController.customView.buttonFrom.addAction(leftLabelTapped, for: .touchUpInside)
        ConverterViewController.customView.buttonTo.addAction(rightLabelTapped, for: .touchUpInside)
        ConverterViewController.customView.swapButton.addAction(swapCurrency, for: .touchUpInside)
        ConverterViewController.customView.historyButton.addAction(openHistory, for: .touchUpInside)
        ConverterViewController.customView.textField.addAction(calculateConversion, for: .editingChanged)
        
        ConverterViewController.customView.tableFrom.delegate = self
        ConverterViewController.customView.tableFrom.dataSource = self
        ConverterViewController.customView.tableTo.delegate = self
        ConverterViewController.customView.tableTo.dataSource = self
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
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
            
            guard let title = ConverterViewController.customView.buttonTo.title(for: .normal),
                  title != "Choose currency to:",
                  ConverterViewController.customView.textField.text != "" else { return }
            
                    calculateService.calculateConversionForConverter()
            
        } else if tableView == ConverterViewController.customView.tableTo {
            ConverterViewController.customView.buttonTo.setTitle(DashboardViewController.currencyCodes[indexPath.row], for: .normal)
            ConverterViewController.customView.tableTo.isHidden = true
            
            guard let title = ConverterViewController.customView.buttonFrom.title(for: .normal),
                  title != "Choose currency from:",
                  ConverterViewController.customView.textField.text != "" else { return }
            
                    calculateService.calculateConversionForConverter()
        }
        
    }
}

