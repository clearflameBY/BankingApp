//
//  ChartScreenForCrypto.swift
//  Banking application
//
//  Created by Илья Степаненко on 15.09.25.
//
import SwiftUI
import Charts

struct ChartScreenForCrypto: View {
    @State private var cryptoData: [CryptosPricePoint] = []
    private let service = CurrencyServiceForCharts()
    let currencyName: String
    let currencyFullName: String

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("📈 \(currencyFullName) (\(currencyName))")
                    .font(.headline)

                Chart(cryptoData) {
                    LineMark(
                        x: .value("Дата", $0.date),
                        y: .value("Цена", $0.price)
                    )
                    .foregroundStyle(.orange)
                }
                .frame(height: 300)
            }
            .padding()
        }
        .onAppear {
            service.fetchHistoryForCryptos(for: currencyFullName) { data in
                self.cryptoData = data
            }
        }
    }
}
