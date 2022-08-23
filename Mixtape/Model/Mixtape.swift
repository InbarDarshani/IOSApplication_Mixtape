import Foundation
import Firebase

class Mixtape{
    public static var COLLECTION_NAME = "mixtapes"
    
    public var mixtapeId: String? = ""
    public var name: String? = ""
    public var description: String? = ""
    public var timeModified: Int64 = 0
    public var timeCreated: Int64 = 0
    public var deleted: Bool = false
    
    //Relations
    public var userId: String? = ""      //The User created this mixtape
    
    init(){}
    
    init(mixtape:MixtapeDao){
        mixtapeId = mixtape.mixtapeId
        name = mixtape.name
        description = mixtape.description
        timeModified = mixtape.timeModified
        timeCreated = mixtape.timeCreated
        deleted = mixtape.isDeleted
        userId = mixtape.userId
    }
}
    
extension Mixtape{
    static func fromJson(json:[String:Any])->Mixtape{
        let m = Mixtape()
        m.mixtapeId = json["mixtapeId"] as? String
        m.name = json["name"] as? String
        m.description = json["description"] as? String
        if let tm = json["timeModified"] as? Timestamp{
            m.timeModified = tm.seconds
        }
        if let tc = json["timeCreated"] as? Timestamp{
            m.timeCreated = tc.seconds
        }
        m.deleted = (json["deleted"] as? String == "true")
        m.userId = json["userId"] as? String
        return m
    }
    
    func toJson()->[String:Any]{
        var json = [String:Any]()
        json["mixtapeId"] = self.mixtapeId!
        json["name"] = self.name!
        json["description"] = self.description!
        json["timeModified"] = FieldValue.serverTimestamp()
        json["timeCreated"] = FieldValue.serverTimestamp()
        json["deleted"] = String(self.deleted)
        json["userId"] = self.userId!
        return json
    }
}
