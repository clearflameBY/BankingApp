//
//  ConversionsHistory+CoreDataProperties.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.10.25.
//
//

import Foundation
import CoreData

public typealias ConversionsHistoryCoreDataPropertiesSet = NSSet

extension ConversionsHistoryModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversionsHistoryModel> {
        return NSFetchRequest<ConversionsHistoryModel>(entityName: "ConversionsHistoryModel")
    }

    @NSManaged public var id: UUID
    @NSManaged public var currencyFrom: String
    @NSManaged public var currencyTo: String
    @NSManaged public var valueFrom: Double
    @NSManaged public var valueTo: Double
    @NSManaged public var date: Date

}

extension ConversionsHistoryModel: Identifiable { }

