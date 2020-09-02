//
//  GuidesEntity+CoreDataProperties.swift
//  
//
//  Created by developer on 9/1/20.
//
//

import Foundation
import CoreData


extension GuidesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GuidesEntity> {
        return NSFetchRequest<GuidesEntity>(entityName: "GuidesEntity")
    }

    @NSManaged public var icon: String?
    @NSManaged public var objType: String?
    @NSManaged public var name: String?
    @NSManaged public var endDate: String?
    @NSManaged public var loginRequired: Bool
    @NSManaged public var startDate: String?
    @NSManaged public var url: String?

}
