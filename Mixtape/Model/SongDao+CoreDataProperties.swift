import Foundation
import CoreData

extension SongDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SongDao> {
        return NSFetchRequest<SongDao>(entityName: "SongDao")
    }

    @NSManaged public var name: String?
    @NSManaged public var artist: String?
    @NSManaged public var caption: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var userId: String?
    @NSManaged public var timeModified: Int64
    @NSManaged public var timeCreated: Int64
    @NSManaged public var mixtapeId: String?
    @NSManaged public var songId: String?

}

extension SongDao : Identifiable {

}
