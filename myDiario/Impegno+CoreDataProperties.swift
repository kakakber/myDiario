//
//  Impegno+CoreDataProperties.swift
//  
//
//  Created by Enrico on 05/10/2019.
//
//

import Foundation
import CoreData


extension Impegno {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Impegno> {
        return NSFetchRequest<Impegno>(entityName: "Impegno")
    }

    @NSManaged public var colore: String?
    @NSManaged public var completato: Bool
    @NSManaged public var descrizione: String?
    @NSManaged public var id: String?
    @NSManaged public var materia: String?
    @NSManaged public var perData: String?
    @NSManaged public var tipo: String?

}
