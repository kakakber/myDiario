//
//  OrarioD+CoreDataProperties.swift
//  
//
//  Created by Enrico on 13/10/2019.
//
//

import Foundation
import CoreData


extension OrarioD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrarioD> {
        return NSFetchRequest<OrarioD>(entityName: "OrarioD")
    }

    @NSManaged public var colore: String?
    @NSManaged public var descrizione: String?
    @NSManaged public var from: String?
    @NSManaged public var giorno: String?
    @NSManaged public var id: String?
    @NSManaged public var materia: String?
    @NSManaged public var to: String?

}
