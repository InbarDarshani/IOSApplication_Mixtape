import Foundation
import CoreData

extension UserDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDao> {
        return NSFetchRequest<UserDao>(entityName: "UserDao")
    }

    @NSManaged public var displayName: String?
    @NSManaged public var email: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var userId: String?
    @NSManaged public var timeModified: Int64
    @NSManaged public var timeCreated: Int64

}

extension UserDao : Identifiable {

}
