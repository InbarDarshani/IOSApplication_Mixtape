import Foundation
import CoreData
import UIKit

@objc(MixtapeDao)
public class MixtapeDao: NSManagedObject {
    
    //App Local DB Context
    static var context:NSManagedObjectContext? = { () -> NSManagedObjectContext? in
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return nil }
        return appDelegate.persistentContainer.viewContext
    }()
    
    /*______________________________________ GET ______________________________________*/
    
    static func getOne(byId:String)->Mixtape?{
        guard let context = context else { return nil }
        
        //Setup query
        let fetchRequest = MixtapeDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mixtapeId == %@", byId)
        
        //Perform fetch
        do{
            if let object = (try context.fetch(fetchRequest)).first {
                return Mixtape(mixtape:object)
            }
        }catch let error as NSError{ NSLog("TAG MixtapeDao - fetch error \(error) \(error.userInfo)") }
        
        return nil
    }
    
    static func getAll()->[Mixtape]{
        guard let context = context else { return [] }
        
        //Setup query
        let fetchRequest = MixtapeDao.fetchRequest()
        
        //Perform fetch
        do{
            var results:[Mixtape] = []
            (try context.fetch(fetchRequest)).forEach{ object in results.append(Mixtape(mixtape:object)) }
            return results
        }catch let error as NSError{ NSLog("TAG MixtapeDao - fetch error \(error) \(error.userInfo)"); return []; }
    }
    
    static func getMany(byUserId:String)->[Mixtape]{
        return self.getAll().filter({ $0.userId == byUserId })
    }
    
    /*______________________________________ INSERT ______________________________________*/
    
    static func insert(mixtape:Mixtape){
        if (mixtape.deleted) { return }
        guard let context = context else { return }
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        //Create the Dao object
        let object = MixtapeDao(context: context)
        object.mixtapeId = mixtape.mixtapeId
        object.name = mixtape.name
        object.descrip = mixtape.description
        object.timeModified = mixtape.timeModified
        object.timeCreated = mixtape.timeCreated
        object.userId = mixtape.userId
        
        //Save
        do{
            try context.save()
        }catch let error as NSError{ NSLog("TAG MixtapeDao - insert error \(error) \(error.userInfo)") }
    }
    
    static func insertMany(mixtapes:[Mixtape]){
        var lastUpdate = self.getLocalLastUpdated()
        
        for mixtape in mixtapes {
            self.insert(mixtape: mixtape)
            if mixtape.timeModified > lastUpdate { lastUpdate = mixtape.timeModified }
        }
        self.setLocalLastUpdated(date: lastUpdate)
    }
    
    /*______________________________________ DELETE ______________________________________*/
    
    static func delete(mixtape:Mixtape){
        guard let context = context else { return }
        
        //Setup query
        let fetchRequest = MixtapeDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mixtapeId == %@", mixtape.mixtapeId!)
        
        //Perform fetch and delete object
        do{
            if let object = try context.fetch(fetchRequest).first{                
                context.delete(object)
                try context.save()
            }
        }catch let error as NSError{ NSLog("TAG MixtapeDao - delete error \(error) \(error.userInfo)") }
    }
    
    /*______________________________________ LAST UPDATE ______________________________________*/
    
    static func getLocalLastUpdated() -> Int64{
        return Int64(UserDefaults.standard.integer(forKey: "MIXTAPEDAO_LAST_UPDATE"))
    }
    
    static func setLocalLastUpdated(date:Int64){
        UserDefaults.standard.set(date, forKey: "MIXTAPEDAO_LAST_UPDATE")
    }
}


