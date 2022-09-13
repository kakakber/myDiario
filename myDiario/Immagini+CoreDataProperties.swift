//
//  Immagini+CoreDataProperties.swift
//  
//
//  Created by Enrico on 05/10/2019.
//
//

import Foundation
import CoreData


extension Immagini {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Immagini> {
        return NSFetchRequest<Immagini>(entityName: "Immagini")
    }

    @NSManaged public var data: String?
    @NSManaged public var descrizione: String?
    @NSManaged public var idOfImage: String?
    @NSManaged public var idOfImpegno: String?
    @NSManaged public var image: String?
    @NSManaged public var materia: String?

}
