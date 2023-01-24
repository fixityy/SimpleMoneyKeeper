//
//  DataStoreManager.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 24.10.2022.
//

import Foundation
import CoreData

class DataStoreManager {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SimpleMoneyKeeper")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addNewSpent(date: Date, category: String, categoryIcon: String, spentAmount: Int64, note: String) {
        let spent = Spent(context: context)
        
        spent.date = date
        spent.dateStr = {
            var calendar = Calendar.current
            if let timeZone = TimeZone(identifier: "UTC") {
                calendar.timeZone = timeZone
            }
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let date = calendar.date(from: components)
            return date ?? Date()
        }()
        spent.dateSort = date.formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        spent.category = category
        spent.categoryIconStr = categoryIcon
        spent.spentAmount = spentAmount
        spent.uuid = UUID().uuidString
        spent.note = note
        saveContext()
    }
}
