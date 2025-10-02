//
//  UserRepository.swift
//  Banking application
//
//  Created by Илья Степаненко on 01.10.25.
//
import Foundation

protocol ConversionsHistoryRepositoryProtocol {
    func getAllContributions() -> [ConversionHistoryModel]
    func getContribution(id: UUID) -> ConversionHistoryModel?
    func createContribution(conversionHistory: ConversionHistoryModel)
}

final class ConversionsHistoryRepository: ConversionsHistoryRepositoryProtocol {

    private let cacheService = CoreDataManager.shared

    func getAllContributions() -> [ConversionHistoryModel] {
        cacheService.getContributions().map { $0.toDomain() }
    }

    func getContribution(id: UUID) -> ConversionHistoryModel? {
        cacheService.getContribution(id: id).map { $0.toDomain() }
    }

    func createContribution(conversionHistory: ConversionHistoryModel) {
        cacheService.createContribution(valueFrom: conversionHistory.valueFrom, valueTo: conversionHistory.valueTo, currencyFrom: conversionHistory.currencyFrom, currencyTo: conversionHistory.currencyTo, date: conversionHistory.date)
    }
}

extension ConversionsHistoryModel {

    func toDomain() -> ConversionHistoryModel {
        ConversionHistoryModel(id: id,
             valueFrom: valueFrom,
             valueTo: valueTo,
             currencyFrom: currencyFrom,
             currencyTo: currencyTo,
             date: date)
    }
}
