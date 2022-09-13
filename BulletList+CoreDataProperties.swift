//
//  BulletList+CoreDataProperties.swift
//  
//
//  Created by Enrico on 21/03/2020.
//
//

import Foundation
import CoreData


extension BulletList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BulletList> {
        return NSFetchRequest<BulletList>(entityName: "BulletList")
    }

    @NSManaged public var idOfBullet: UUID?
    @NSManaged public var date: String?
    @NSManaged public var actualContent: [String]
    @NSManaged public var doneList: [Bool]
}
