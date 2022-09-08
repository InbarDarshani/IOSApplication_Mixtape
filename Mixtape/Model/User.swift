import Foundation
import Firebase

class User{
    //Remote db collection name
    public static var COLLECTION_NAME = "users"
    //Keys names for shared prefrences
    public static var KEYNAME_CURRENT_USER_ID = "currentUserId"
    public static var KEYNAME_CURRENT_USER_EMAIL = "currentUserEmail"
    public static var KEYNAME_CURRENT_USER_NAME = "currentUserName"
    public static var KEYNAME_CURRENT_USER_IMAGE = "currentUserImageUrl"
    
    public var userId: String? = ""
    public var email: String? = ""
    public var displayName: String? = ""
    public var imageUrl: String? = ""
    public var timeModified: Int64 = 0
    public var timeCreated: Int64 = 0
        
    init(){}
    
    init(userId: String, email: String, displayName: String, imageUrl: String = "", timeModified: Int64 = 0, timeCreated: Int64 = 0){
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.imageUrl = imageUrl
        self.timeModified = timeModified
        self.timeCreated = timeCreated
    }
    
    init(user:UserDao){
        self.userId = user.userId
        self.email = user.email
        self.displayName = user.displayName
        self.imageUrl = user.imageUrl
        self.timeModified = user.timeModified
        self.timeCreated = user.timeCreated
    }
}
    
extension User{
    static func fromJson(json:[String:Any])->User{
        let u = User()
        u.userId = json["userId"] as? String
        u.email = json["email"] as? String
        u.displayName = json["displayName"] as? String
        u.imageUrl = json["image"] as? String
        if let tm = json["timeModified"] as? Timestamp{ u.timeModified = tm.seconds }
        if let tc = json["timeCreated"] as? Timestamp{ u.timeCreated = tc.seconds }
        return u
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
