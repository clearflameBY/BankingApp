//
//  CoreDataManager.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.10.25.
//
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ConversionsHistoryDataModel")
        
        // Explicitly specify the SQLite file store and the path to it
        let storeURL: URL = {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            // Make sure the folder exists
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            return appSupport.appendingPathComponent("ConversionsHistoryDataModel.sqlite")
        }()
        
        if let description = container.persistentStoreDescriptions.first {
            description.type = NSSQLiteStoreType
            description.url = storeURL
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        } else {
            let description = NSPersistentStoreDescription(url: storeURL)
            description.type = NSSQLiteStoreType
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func createContribution(valueFrom: Double, valueTo: Double, currencyFrom: String, currencyTo: String, date: Date) {
        let note = ConversionsHistoryModel(context: context)
        note.id = UUID()
        note.valueTo = valueTo
        note.valueFrom = valueFrom
        note.currencyFrom = currencyFrom
        note.currencyTo = currencyTo
        note.date = date

        saveContext()
    }

    func getContributions() -> [ConversionsHistoryModel] {
        let request: NSFetchRequest<ConversionsHistoryModel> = ConversionsHistoryModel.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch contributions failed: \(error.localizedDescription)")
            return []
        }
    }

    func getContribution(id: UUID) -> ConversionsHistoryModel? {
        let request: NSFetchRequest<ConversionsHistoryModel> = ConversionsHistoryModel.fetchRequest()
        request.fetchLimit = 1
        // the id attribute is of type UUID - we compare the UUID, not the string
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(request).first
        } catch {
            print("Fetch contribution by id failed: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteContribution(id: UUID) {
        guard let note = getContribution(id: id) else { return }
        context.delete(note)
        saveContext()
    }
    
    // Public method to save changes when going to background
    func saveIfNeeded() {
        saveContext()
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save context failed: \(error.localizedDescription)")
        }
    }
}
