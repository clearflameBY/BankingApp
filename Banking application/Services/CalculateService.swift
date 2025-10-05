//
//  CalculateService.swift
//  Banking application
//
//  Created by Илья Степаненко on 19.09.25.
//

import UIKit

class CalculateService {
    
    private let conversionsHistoryRepository: ConversionsHistoryRepositoryProtocol

    init(conversionsHistoryRepository: ConversionsHistoryRepositoryProtocol = ConversionsHistoryRepository()) {
        self.conversionsHistoryRepository = conversionsHistoryRepository
    }
    
    func calculateConversionForDashboard() {
        // Безопасно читаем ввод, убираем пробелы и трактуем пустое/некорректное как 0
        let rawText = DashboardViewController.customView.amountField.text ?? ""
        let amountText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Double(amountText) ?? 0
        
        // Если пользователь очистил поле — сразу показываем 0
        if amount == 0 {
            DashboardViewController.customView.resultLabel.text = "Результат 0.00"
            return
        }
        
        // Дальше считаем только если выбраны валюты и есть курсы
        guard
            let fromCode = DashboardViewController.currencyCodes[safe: DashboardViewController.customView.fromCurrencyPicker.selectedRow(inComponent: 0)],
            let toCode = DashboardViewController.currencyCodes[safe: DashboardViewController.customView.toCurrencyPicker.selectedRow(inComponent: 0)],
            let amountText = DashboardViewController.customView.amountField.text,
            let amount = Double(amountText),
            let fromRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == fromCode }),
            let toRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == toCode })
        else { return }
        
        let fromRatePerOne = fromRateData.curOfficialRate / Double(fromRateData.curScale)
        let toRatePerOne = toRateData.curOfficialRate / Double(toRateData.curScale)
        
        let result = amount * (fromRatePerOne / toRatePerOne)
        DashboardViewController.customView.resultLabel.text = String(format: "Результат: %.2f", result)
    }
    
    func calculateConversionForConverter() {
        // Безопасно читаем ввод, убираем пробелы и трактуем пустое/некорректное как 0
        let rawText = ConverterViewController.customView.textField.text ?? ""
        let amountText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Double(amountText) ?? 0
        
        // Если пользователь очистил поле — сразу показываем 0
        if amount == 0 {
            ConverterViewController.customView.labelResult.text = "0.00"
            return
        }
        
        // Дальше считаем только если выбраны валюты и есть курсы
        guard
            let fromCode = DashboardViewController.currencyCodes.first(where: { $0 == ConverterViewController.customView.buttonFrom.currentTitle }),
            let toCode = DashboardViewController.currencyCodes.first(where: { $0 == ConverterViewController.customView.buttonTo.currentTitle }),
            let fromRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == fromCode }),
            let toRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == toCode })
        else { return }
        
        let fromRatePerOne = fromRateData.curOfficialRate / Double(fromRateData.curScale)
        let toRatePerOne = toRateData.curOfficialRate / Double(toRateData.curScale)
        
        let result = amount * (fromRatePerOne / toRatePerOne)
        ConverterViewController.customView.labelResult.text = String(format: "%.2f", result)
        saveConversion()
    }
    
    private func saveConversion() {
        // Parse input amount safely
        let rawFromText = ConverterViewController.customView.textField.text ?? ""
        let valueFrom = Double(rawFromText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        // Parse calculated result safely (label contains plain number like "123.45")
        let rawToText = ConverterViewController.customView.labelResult.text ?? ""
        let valueTo = Double(rawToText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        
        conversionsHistoryRepository.createContribution(
            conversionHistory: .init(
                id: .init(),
                valueFrom: valueFrom,
                valueTo: valueTo,
                currencyFrom: ConverterViewController.customView.buttonFrom.currentTitle ?? "",
                currencyTo: ConverterViewController.customView.buttonTo.currentTitle ?? "",
                date: Date()
            )
        )
    }
}
