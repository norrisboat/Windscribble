//
//  ServerNode.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import Foundation
import CoreData

@objc(ServerNode)
class ServerNode: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var hostname: String?
    @NSManaged public var serverLocation: ServerLocation?
}

extension ServerNode {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServerNode> {
        return NSFetchRequest<ServerNode>(entityName: "ServerNode")
    }
}
