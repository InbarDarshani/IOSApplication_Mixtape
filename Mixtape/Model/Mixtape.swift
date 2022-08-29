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
    
    init(mixtapeId: String, name: String, description: String, userId: String,
         timeModified: Int64 = 0, timeCreated: Int64 = 0, deleted: Bool = false){
        self.mixtapeId = mixtapeId
        self.name = name
        self.description = description
        self.timeModified = timeModified
        self.timeCreated = timeCreated
        self.deleted = deleted
        self.userId = userId
    }
    
    init(mixtape:MixtapeDao){
        self.mixtapeId = mixtape.mixtapeId
        self.name = mixtape.name
        self.description = mixtape.description
        self.timeModified = mixtape.timeModified
        self.timeCreated = mixtape.timeCreated
        self.deleted = mixtape.isDeleted
        self.userId = mixtape.userId
    }
}
    
extension Mixtape{
    static func fromJson(json:[String:Any])->Mixtape{
        let m = Mixtape()
        m.mixtapeId = json["mixtapeId"] as? String
        m.name = json["name"] as? String
        m.description = json["description"] as? String
        if let tm = json["timeModified"] as? Timestamp{ m.timeModified = tm.seconds }
        if let tc = json["timeCreated"] as? Timestamp{ m.timeCreated = tc.seconds }
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
