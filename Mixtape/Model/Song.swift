import Foundation
import Firebase

class Song{
    public static var COLLECTION_NAME = "songs"
    
    public var songId: String? = ""
    public var name: String? = ""
    public var artist: String? = ""
    public var caption: String? = ""
    public var imageUrl: String? = ""
    public var timeModified: Int64 = 0
    public var timeCreated: Int64 = 0
    public var deleted: Bool = false
    
    //Relations
    public var userId: String? = ""      //The User created this song post
    public var mixtapeId: String? = ""   //The containing mixtape of this song
    
    init(){}
    
    init(song:SongDao){
        songId = song.songId
        name = song.name
        artist = song.artist
        caption = song.caption
        imageUrl = song.imageUrl
        timeModified = song.timeModified
        timeCreated = song.timeCreated
        deleted = song.isDeleted
        userId = song.userId
        mixtapeId = song.mixtapeId
    }
}
	
extension Song{
    static func fromJson(json:[String:Any])->Song{
        let s = Song()
        s.songId = json["songId"] as? String
        s.name = json["name"] as? String
        s.artist = json["artist"] as? String
        s.caption = json["caption"] as? String
        s.imageUrl = json["image"] as? String
        if let tm = json["timeModified"] as? Timestamp{
            s.timeModified = tm.seconds
        }
        if let tc = json["timeCreated"] as? Timestamp{
            s.timeCreated = tc.seconds
        }
        s.deleted = (json["deleted"] as? String == "true")
        s.userId = json["userId"] as? String
        s.mixtapeId = json["mixtapeId"] as? String
        return s
    }
    
    func toJson()->[String:Any]{
        var json = [String:Any]()
        json["songId"] = self.songId!
        json["name"] = self.name!
        json["artist"] = self.artist!
        json["caption"] = self.caption!
        json["image"] = self.imageUrl!
        json["timeModified"] = FieldValue.serverTimestamp()
        json["timeCreated"] = FieldValue.serverTimestamp()
        json["deleted"] = String(self.deleted)
        json["userId"] = self.userId!
        json["mixtapeId"] = self.mixtapeId!
        return json
    }
}
