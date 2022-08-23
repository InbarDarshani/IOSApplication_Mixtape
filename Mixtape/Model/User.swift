import Foundation
import Firebase

class User{
    public static var COLLECTION_NAME = "users"
    
    public var userId: String? = ""
    public var email: String? = ""
    public var displayName: String? = ""
    public var imageUrl: String? = ""
    public var timeModified: Int64 = 0
    public var timeCreated: Int64 = 0
        
    init(){}
    
    init(user:UserDao){
        userId = user.userId
        email = user.email
        displayName = user.displayName
        imageUrl = user.imageUrl
        timeModified = user.timeModified
        timeCreated = user.timeCreated
    }
}
    
extension User{
    static func fromJson(json:[String:Any])->User{
        let m = User()
        m.userId = json["userId"] as? String
        m.email = json["email"] as? String
        m.displayName = json["displayName"] as? String
        m.imageUrl = json["image"] as? String
        if let tm = json["timeModified"] as? Timestamp{
            m.timeModified = tm.seconds
        }
        if let tc = json["timeCreated"] as? Timestamp{
            m.timeCreated = tc.seconds
        }
        return m
    }
    
    func toJson()->[String:Any]{
        var json = [String:Any]()
        json["userId"] = self.userId!
        json["email"] = self.email!
        json["displayName"] = self.displayName!
        json["image"] = self.imageUrl!
        json["timeModified"] = FieldValue.serverTimestamp()
        json["timeCreated"] = FieldValue.serverTimestamp()
        return json
    }
}
