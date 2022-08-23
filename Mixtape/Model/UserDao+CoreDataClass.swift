import Foundation
import CoreData
import UIKit

@objc(UserDao)
public class UserDao: NSManagedObject {
    
    //App Local DB Context
    static var context:NSManagedObjectContext? = { () -> NSManagedObjectContext? in
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return nil }
        return appDelegate.persistentContainer.viewContext
    }()
    
    /*______________________________________ GET ______________________________________*/
    
    static func getOne(byId:String)->User?{
        guard let context = context else { return nil }
        
        //Setup query
        let fetchRequest = UserDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", byId)
        
        //Perform fetch
        do{
            if let object = try context.fetch(fetchRequest).first {
                return User(user:object)
            }
        }catch let error as NSError{ NSLog("TAG UserDao - fetch error \(error) \(error.userInfo)") }
        
        return nil
    }
    
    static func getAll()->[User]{
        guard let context = context else { return [] }
        
        //Setup query
        let fetchRequest = UserDao.fetchRequest()
        
        //Perform fetch
        do{
            var results:[User] = []
            (try context.fetch(fetchRequest)).forEach{ object in results.append(User(user:object)) }
            return results
        }catch let error as NSError{ NSLog("TAG UserDao - fetch error \(error) \(error.userInfo)"); return []; }
    }
    
    /*______________________________________ INSERT ______________________________________*/
    
    static func insert(user:User){
        guard let context = context else { return }
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        //Create the Dao object
        let object = UserDao(context: context)
        object.userId = user.userId
        object.email = user.email
        object.displayName = user.displayName
        object.imageUrl = user.imageUrl
        
        //Save
        do{
            try context.save()
        }catch let error as NSError{ NSLog("TAG UserDao - insert error \(error) \(error.userInfo)") }
    }
    
    static func insertMany(users:[User]){
        var lastUpdate = self.getLocalLastUpdated()
        
        for user in users {
            self.insert(user: user)
            if user.timeModified > lastUpdate { lastUpdate = user.timeModified }
        }
        self.setLocalLastUpdated(date: lastUpdate)
    }
    
    /*______________________________________ DELETE ______________________________________*/
    
    static func delete(user:User){
        guard let context = context else { return }
        
        //Setup query
        let fetchRequest = UserDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", user.userId!)
        
        //Perform fetch and delete object
        do{
            if let object = try context.fetch(fetchRequest).first{                
                context.delete(object)
                try context.save()
            }
        }catch let error as NSError{ NSLog("TAG UserDao - delete error \(error) \(error.userInfo)") }
    }
    
    /*______________________________________ LAST UPDATE ______________________________________*/
    
    static func getLocalLastUpdated() -> Int64{
        return Int64(UserDefaults.standard.integer(forKey: "USERDAO_LAST_UPDATE"))
    }
    
    static func setLocalLastUpdated(date:Int64){
        UserDefaults.standard.set(date, forKey: "USERDAO_LAST_UPDATE")
    }
}
