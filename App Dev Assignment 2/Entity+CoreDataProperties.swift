//
//  Entity+CoreDataProperties.swift
//  App Dev Assignment 2
//
//  Created by Vương Satiroglu on 1/16/21.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var yearOfWork: String?
    @NSManaged public var type: String?
    @NSManaged public var attribute: String?
    @NSManaged public var information: String?
    @NSManaged public var lat: String?
    @NSManaged public var long: String?
    @NSManaged public var location: String?
    @NSManaged public var locationNotes: String?
    @NSManaged public var fileName: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var enabled: String?

}

extension Entity : Identifiable {

}
