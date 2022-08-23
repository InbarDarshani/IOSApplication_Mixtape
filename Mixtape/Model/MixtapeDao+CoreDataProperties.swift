import Foundation
import CoreData

extension MixtapeDao {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MixtapeDao> {
        return NSFetchRequest<MixtapeDao>(entityName: "MixtapeDao")
    }

    @NSManaged public var descrip: String?
    @NSManaged public var mixtapeId: String?
    @NSManaged public var name: String?
    @NSManaged public var timeCreated: Int64
    @NSManaged public var timeModified: Int64
    @NSManaged public var userId: String?

}

extension MixtapeDao : Identifiable {

}
