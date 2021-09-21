//
//  ServerLocation.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit
import CoreData

@objc(ServerLocation)
class ServerLocation: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var dnsHostname: String?
    @NSManaged public var nodes: NSOrderedSet?
    var isExpaned: Bool = false
}

extension ServerLocation {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ServerLocation> {
    return NSFetchRequest<ServerLocation>(entityName: "ServerLocation")
  }
}
