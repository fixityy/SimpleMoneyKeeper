//
//  Spent+CoreDataProperties.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 27.10.2022.
//
//

import Foundation
import CoreData


extension Spent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Spent> {
        return NSFetchRequest<Spent>(entityName: "Spent")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dateStr: String?
    @NSManaged public var dateSort: String?
    @NSManaged public var category: String?
    @NSManaged public var categoryIconStr: String?
    @NSManaged public var spentAmount: Int64
    @NSManaged public var note: String?
    @NSManaged public var uuid: String?

}

extension Spent : Identifiable {

}
