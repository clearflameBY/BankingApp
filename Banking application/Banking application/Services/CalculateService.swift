//
//  CalculateService.swift
//  Banking application
//
//  Created by Илья Степаненко on 19.09.25.
//

class CalculateService {
    
    func calculateConversionForDashboard() {
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
        guard
            let fromCode = DashboardViewController.currencyCodes.first(where: { $0 == ConverterViewController.customView.buttonFrom.currentTitle}),
            let toCode = DashboardViewController.currencyCodes.first(where: { $0 == ConverterViewController.customView.buttonTo.currentTitle}),
            let amount = Double(ConverterViewController.customView.textField.text ?? ""),
            let fromRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == fromCode }),
            let toRateData = DashboardViewController.rates.first(where: { $0.curAbbreviation == toCode })
        else { return }
        
        let fromRatePerOne = fromRateData.curOfficialRate / Double(fromRateData.curScale)
        let toRatePerOne = toRateData.curOfficialRate / Double(toRateData.curScale)
        
        let result = amount * (fromRatePerOne / toRatePerOne)
        ConverterViewController.customView.labelResult.text = String(format: "%.2f", result)
    }
}
