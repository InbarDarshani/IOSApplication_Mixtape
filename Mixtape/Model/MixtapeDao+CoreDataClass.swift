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
    
    /*-------------------------------------- GET --------------------------------------*/
    
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
        }catch let error as NSError{ NSLog("TAG MixtapeDao - fetch error \(error)") }
        
        return nil
    }
        
    static func getOne(byName:String)->Mixtape?{
        guard let context = context else { return nil }
        
        //Setup query
        let fetchRequest = MixtapeDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", byName)
        
        //Perform fetch
        do{
            if let object = (try context.fetch(fetchRequest)).first {
                return Mixtape(mixtape:object)
            }
        }catch let error as NSError{ NSLog("TAG MixtapeDao - fetch error \(error)") }
        
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
        }catch let error as NSError{ NSLog("TAG MixtapeDao - fetch error \(error)"); return []; }
    }
    
    static func getMany(byUserId:String)->[Mixtape]{
        return self.getAll().filter({ $0.userId == byUserId })
    }
    
    /*-------------------------------------- INSERT --------------------------------------*/
    
    static func insert(mixtape:Mixtape){
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
        }catch let error as NSError{ NSLog("TAG MixtapeDao - insert error \(error)") }
    }
    
    static func insertMany(mixtapes:[Mixtape]){
        var lastUpdate = self.getLocalLastUpdated()
        
        for mixtape in mixtapes {
            self.insert(mixtape: mixtape)
            if mixtape.timeModified > lastUpdate { lastUpdate = mixtape.timeModified }
        }
        self.setLocalLastUpdated(date: lastUpdate)
    }
    
    /*-------------------------------------- DELETE --------------------------------------*/
    
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
        }catch let error as NSError{ NSLog("TAG MixtapeDao - delete error \(error)") }
    }
    
    static func deleteMany(mixtapes:[Mixtape]){
        for mixtape in mixtapes {
            self.delete(mixtape: mixtape)
        }
    }
    
    /*-------------------------------------- LAST UPDATE --------------------------------------*/
    
    static func getLocalLastUpdated() -> Int64{
        return Int64(UserDefaults.standard.integer(forKey: "MIXTAPEDAO_LAST_UPDATE"))
    }
    
    static func setLocalLastUpdated(date:Int64){
        UserDefaults.standard.set(date, forKey: "MIXTAPEDAO_LAST_UPDATE")
    }
}


