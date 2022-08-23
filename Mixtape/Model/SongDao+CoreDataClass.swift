import Foundation
import CoreData
import UIKit

@objc(SongDao)
public class SongDao: NSManagedObject {
    
    //App Local DB Context
    static var context:NSManagedObjectContext? = { () -> NSManagedObjectContext? in
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return nil }
        return appDelegate.persistentContainer.viewContext
    }()
    
    /*______________________________________ GET ______________________________________*/
    
    static func getOne(byId:String)->Song?{
        guard let context = context else { return nil }
        
        //Setup query
        let fetchRequest = SongDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "songId == %@", byId)
        
        //Perform fetch
        do{
            if let object = try context.fetch(fetchRequest).first {
            return Song(song:object)
            }
        }catch let error as NSError{ NSLog("TAG SongDao - fetch error \(error) \(error.userInfo)")}
        
        return nil
    }
    
    static func getAll()->[Song]{
        guard let context = context else { return [] }
        
        //Setup query
        let fetchRequest = SongDao.fetchRequest()
        
        //Perform fetch
        do{
            var results:[Song] = []
            (try context.fetch(fetchRequest)).forEach{ object in results.append(Song(song:object)) }
            return results
        }catch let error as NSError{ NSLog("TAG SongDao - fetch error \(error) \(error.userInfo)"); return []; }
    }
    
    static func getMany(byMixtapeId:String)->[Song]{
        return self.getAll().filter({ $0.mixtapeId == byMixtapeId })
    }
    
    static func getMany(byUserId:String)->[Song]{
        return self.getAll().filter({ $0.userId == byUserId })
    }
    
    /*______________________________________ INSERT ______________________________________*/
    
    static func insert(song:Song){
        if (song.deleted) { return }
        guard let context = context else { return }
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        //Create the Dao object
        let object = SongDao(context: context)
        object.songId = song.songId
        object.name = song.name
        object.artist = song.artist
        object.caption = song.caption
        object.imageUrl = song.imageUrl
        object.timeModified = song.timeModified
        object.timeCreated = song.timeCreated
        object.userId = song.userId
        object.mixtapeId = song.mixtapeId
        
        //Save
        do{
            try context.save()
        }catch let error as NSError{ NSLog("TAG SongDao - insert error \(error) \(error.userInfo)") }
    }
    
    static func insertMany(songs:[Song]){
        var lastUpdate = self.getLocalLastUpdated()
        
        for song in songs {
            self.insert(song: song)
            if song.timeModified > lastUpdate { lastUpdate = song.timeModified }
        }
        self.setLocalLastUpdated(date: lastUpdate)
    }
    
    /*______________________________________ DELETE ______________________________________*/
    
    static func delete(song:Song){
        guard let context = context else { return }
        
        //Setup query
        let fetchRequest = SongDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "songId == %@", song.songId!)
        
        //Perform fetch and delete object
        do{
            if let object = try context.fetch(fetchRequest).first{
                context.delete(object)
                try context.save()
            }
        }catch let error as NSError{ NSLog("TAG SongDao - delete error \(error) \(error.userInfo)") }
    }
    
    static func deleteMany(songs:[Song]){
        for song in songs {
            self.delete(song: song)
        }
    }
    
    /*______________________________________ LAST UPDATE ______________________________________*/

    static func getLocalLastUpdated() -> Int64{
        return Int64(UserDefaults.standard.integer(forKey: "SONGDAO_LAST_UPDATE"))
    }
    
    static func setLocalLastUpdated(date:Int64){
        UserDefaults.standard.set(date, forKey: "SONGDAO_LAST_UPDATE")
    }
}
