//
//  Post+CoreDataProperties.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//
//

import Foundation
import CoreData


extension PostCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostCD> {
        return NSFetchRequest<PostCD>(entityName: "PostCD")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var postId: Int16
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var body: String?
    @NSManaged public var isFavorite: Bool

}

extension PostCD : Identifiable {
    func asPostModel() -> PostModel {
        PostModel(postId: Int(self.postId),
                  id: Int(self.id),
                  name: self.name ?? "",
                  email: self.email ?? "",
                  body: self.body ?? "")
    }
}
