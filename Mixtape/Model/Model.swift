import Foundation
import UIKit
import CoreData

class Model{
    static let instance = Model()
    let firebase = ModelFirebase()
    let dispatchQueue = DispatchQueue(label:"com.inbar-darshani.mixtape")
    
    //Create data update notifications
    static let feedDataNotification = ModelNotificationBase("com.inbar-darshani.mixtape.feedDataNotification")
    static let profileDataNotification = ModelNotificationBase("com.inbar-darshani.mixtape.profileDataNotification")
    
    private init(){}
    
    //MARK: ------------------------------------------------ AUTHENTICATION ------------------------------------------------
    
    func isSignedIn()->Bool{
        return UserDefaults.standard.bool(forKey: "isSignedIn") && firebase.isSignedIn()
    }
    
    func signInsignUp(newUser:Bool, fullName:String, email:String, password:String, completion:@escaping (_ user:User?, _ error:String?)->Void){
        if newUser {
            firebase.signUp(fullName:fullName, email:email, password:password){ user, error  in
                guard let user = user , error == nil else { completion(nil, error); return; }
                self.saveCurrentUser(user)
                completion(user, nil)
            }
        } else{
            firebase.signIn(fullName:fullName, email:email, password:password){ user, error  in
                guard let user = user , error == nil else { completion(nil, error); return; }
                self.saveCurrentUser(user)
                completion(user, nil)
            }
        }
    }
    
    func signOut(){ clearCurrentUser(); firebase.signOut(); }
    
    private func saveCurrentUser(_ user:User){
        UserDefaults.standard.set(true,forKey: "isSignedIn")
        //Save user data to app shared preferences
        UserDefaults.standard.set(user.userId, forKey:User.KEYNAME_CURRENT_USER_ID)
        UserDefaults.standard.set(user.email, forKey:User.KEYNAME_CURRENT_USER_EMAIL)
        UserDefaults.standard.set(user.displayName, forKey:User.KEYNAME_CURRENT_USER_NAME)
        UserDefaults.standard.set(user.imageUrl, forKey:User.KEYNAME_CURRENT_USER_IMAGE)
        
        //Save to local DB
        dispatchQueue.async{ UserDao.insert(user: user) }
    }
    
    private func clearCurrentUser(){
        UserDefaults.standard.set(false,forKey: "isSignedIn")
        //Clear user data in app shared preferences
        UserDefaults.standard.removeObject(forKey:User.KEYNAME_CURRENT_USER_ID)
        UserDefaults.standard.removeObject(forKey:User.KEYNAME_CURRENT_USER_EMAIL)
        UserDefaults.standard.removeObject(forKey:User.KEYNAME_CURRENT_USER_NAME)
        UserDefaults.standard.removeObject(forKey:User.KEYNAME_CURRENT_USER_IMAGE)
    }
    
    func getCurrentUser() -> User{
        //guard self.isSignedIn() else { return nil }
        let u = User()
        u.userId = UserDefaults.standard.string(forKey: User.KEYNAME_CURRENT_USER_ID)
        u.email = UserDefaults.standard.string(forKey: User.KEYNAME_CURRENT_USER_EMAIL)
        u.displayName = UserDefaults.standard.string(forKey: User.KEYNAME_CURRENT_USER_NAME)
        u.imageUrl = UserDefaults.standard.string(forKey: User.KEYNAME_CURRENT_USER_IMAGE)
        return u
    }
    
    //MARK: -------------------------------------------------- STORAGE --------------------------------------------------
    
    private func uploadImage(imageName:String, folder:String, image:UIImage, completion:@escaping(_ url:String)->Void){
        firebase.uploadImage(imageName: imageName, folder: folder, image: image, completion: completion)
    }
    
    func uploadSongImage(image:UIImage, song:Song, completion:@escaping()->Void){
        uploadImage(imageName: song.songId!, folder: Song.COLLECTION_NAME, image: image) { url in
            song.imageUrl = url
            self.updateSong(song: song, completion: completion)
        }
    }
    
//    func uploadUserImage(image:UIImage, user:User, completion:@escaping()->Void){
//        uploadImage(imageName: user.userId!, folder: User.COLLECTION_NAME, image: image) { url in
//            user.imageUrl = url
//            self.updateUser(user: user, completion: completion)
//        }
//    }
    
    //MARK: ------------------------------------------------ DATA ------------------------------------------------
    
    //MARK: -------------------- Local Objects Saving and Updating --------------------
    
    private func saveSong(song:Song){
        dispatchQueue.async{
            SongDao.insert(song: song)
            Model.feedDataNotification.post()
        }
    }
    
    private func saveMixtape(mixtape:Mixtape){
        dispatchQueue.async{
            MixtapeDao.insert(mixtape: mixtape)
            Model.profileDataNotification.post()
        }
    }
    
    private func saveUser(user:User){
        dispatchQueue.async{
            UserDao.insert(user: user)
        }
    }
    
    //MARK: -------------------- Objects Binding --------------------
    
    //Construct feed song items objects from local db
    private func constructFeedItems() -> [SongItem]{
        var items:[SongItem] = []
        let localSongs = SongDao.getAll()
        
        for localSong in localSongs{
            guard !localSong.deleted else { break }
            
            let localMixtape = MixtapeDao.getOne(byId: localSong.mixtapeId!)
            let localUser = UserDao.getOne(byId: localSong.userId!)
            
            if localMixtape != nil && localUser != nil{
                let songItem = SongItem()
                songItem.song = localSong
                songItem.mixtape = localMixtape!
                songItem.user = localUser!
                items.append(songItem)
            }
            else {
                NSLog("TAG Model - error fetching localSong \(localSong.songId) with localMixtape \(localSong.mixtapeId) and localUser \(localSong.userId)")
            }
        }
        
        //Sort by TimeModified
        items.sort{ $0.song.timeModified > $1.song.timeModified }
        NSLog("TAG Model - feed items \(items.count)")
        return items
    }
    
    //Construct user mixtape items objects from local db
    private func constructProfileItems(userId:String) -> [MixtapeItem]{
        var items:[MixtapeItem] = []
        let localMixtapes = MixtapeDao.getMany(byUserId: userId)
        
        for localMixtape in localMixtapes{
            guard !localMixtape.deleted else { break }
            
            let localUser = UserDao.getOne(byId: userId)
            let localMixtapeSongs = SongDao.getMany(byMixtapeId: localMixtape.mixtapeId!)
            
            if localUser != nil{
                let mixtapeItem = MixtapeItem()
                mixtapeItem.mixtape = localMixtape
                mixtapeItem.songs = localMixtapeSongs
                mixtapeItem.user = localUser!
                items.append(mixtapeItem)
            }
        }
        
        //Sort by TimeModified
        items.sort{ $0.mixtape.timeModified > $1.mixtape.timeModified }
        NSLog("TAG Model - profile items \(items.count)")
        return items
    }
    
    //Construct mixtape's song items objects from local db
    private func constructMixtapeSongItems(mixtapeId:String) -> [SongItem]{
        var items:[SongItem] = []
        let localMixtape = MixtapeDao.getOne(byId: mixtapeId)
        let localMixtapeSongs = SongDao.getMany(byMixtapeId: mixtapeId)

        if localMixtape != nil {
            for localSong in localMixtapeSongs {
                guard !localSong.deleted else { break }
                let localMixtape = MixtapeDao.getOne(byId: localSong.mixtapeId!)
                let localUser = UserDao.getOne(byId: localSong.userId!)
                
                if localMixtape != nil && localUser != nil{
                    let songItem = SongItem()
                    songItem.song = localSong
                    songItem.mixtape = localMixtape!
                    songItem.user = localUser!
                    items.append(songItem)
                }
            }
        }

        //Sort by TimeModified
        items.sort{ $0.song.timeModified > $1.song.timeModified }
        return items
    }
    
    //Construct a song item from local db
    private func constructSongItem(songId:String) -> SongItem?{
        let localSong = SongDao.getOne(byId: songId)
        
        if localSong != nil {
            let localMixtape = MixtapeDao.getOne(byId: localSong!.mixtapeId!)
            let localUser = UserDao.getOne(byId: localSong!.userId!)
            
            if localMixtape != nil && localUser != nil{
                let songItem = SongItem()
                songItem.song = localSong!
                songItem.mixtape = localMixtape!
                songItem.user = localUser!
                return songItem
            }
        }
        
        return nil
    }
    
    //Construct a mixtape items objects from local db
    private func constructMixtapeItem(mixtapeId:String) -> MixtapeItem?{
        let localMixtape = MixtapeDao.getOne(byId: mixtapeId)
        
        if localMixtape != nil {
            let localUser = UserDao.getOne(byId: localMixtape!.userId!)
            let localMixtapeSongs = SongDao.getMany(byMixtapeId: localMixtape!.mixtapeId!)
            
            if localUser != nil {
                let mixtapeItem = MixtapeItem()
                mixtapeItem.mixtape = localMixtape!
                mixtapeItem.songs = localMixtapeSongs
                mixtapeItem.user = localUser!
                return mixtapeItem
            }
        }
        
        return nil
    }
    
    //MARK: -------------------- Multiple Objects Fetching --------------------
    
    func getFeed(completion:@escaping ([SongItem])->Void) {
        fetchFeedData(){
            DispatchQueue.main.async {
                let results = self.constructFeedItems()
                completion(results)
            }
        }
    }
    
    func getProfile(completion:@escaping ([MixtapeItem])->Void) {
        let currentUserId = getCurrentUser().userId!
        fetchProfileData(userId: currentUserId){
            self.dispatchQueue.async {
                let results = self.constructProfileItems(userId: currentUserId)
                completion(results)
            }
        }
    }
    
    //Fetch feed data from remote db and save to local db
    private func fetchFeedData(completion:@escaping ()->Void) {
        //Get the Local Last Update time
        let lastUpdate = SongDao.getLocalLastUpdated()
        NSLog("TAG Model - SongDao last update is \(lastUpdate)")
        
        //Remove recently deleted songs
        firebase.getDeletedSongs(since: lastUpdate){ songsToRemove in
            NSLog("TAG Model - firebase returned \(songsToRemove.count) songs to remove")
            self.dispatchQueue.async{ SongDao.deleteMany(songs: songsToRemove) }
        }
        
        //Get new songs
        firebase.getFeedSongs(since: lastUpdate){ newSongs in
            NSLog("TAG Model - firebase returned \(newSongs.count) songs to feed")
            
            if newSongs.isEmpty { completion(); return; }
            
            self.dispatchQueue.async{
                //Save new feed songs to local db
                SongDao.insertMany(songs: newSongs)
                
                //Get required mixtapes and user ids
                let newMixtapeIds = newSongs.map{ $0.mixtapeId! }
                let newUserIds = newSongs.map{ $0.userId! }
                
                //Get and save feed mixtapes and users
                self.firebase.getUsersByIds(userIds: newUserIds){ newUsers in
                    NSLog("TAG Model - firebase returned \(newUsers.count) newUsers to feed")
                    
                    //Save feed users to local db
                    UserDao.insertMany(users: newUsers)
                    
                    self.firebase.getMixtapesByIds(mixtapeIds: newMixtapeIds){ newMixtapes in
                        NSLog("TAG Model - firebase returned \(newMixtapes.count) newMixtapes to feed")
                        
                        //Save feed mixtapes to local db
                        MixtapeDao.insertMany(mixtapes: newMixtapes)
                        completion()
                    }
                }
                
            }
        }
    }
    
    //Fetch user's profile data from remote db and save to local db
    private func fetchProfileData(userId:String, completion:@escaping ()->Void) {
        //Get the Local Last Update time
        let lastUpdate = MixtapeDao.getLocalLastUpdated()
        NSLog("TAG Model - MixtapeDao last update is \(lastUpdate)")
        
        //Remove recently deleted mixtapes
        firebase.getDeletedMixtapes(since: lastUpdate){ mixtapesToRemove in
            NSLog("TAG Model - firebase returned \(mixtapesToRemove.count) mixtapes to remove")
            self.dispatchQueue.async{ MixtapeDao.deleteMany(mixtapes: mixtapesToRemove) }
        }
        
        //Get profile new mixtapes
        firebase.getUserMixtapes(since: 0, userId: userId){ newMixtapes in
            NSLog("TAG Model - firebase returned \(newMixtapes.count) mixtapes to profile")
            
            if newMixtapes.isEmpty { completion(); return; }
            //Save profile mixtapes to local db
            self.dispatchQueue.async{
                MixtapeDao.insertMany(mixtapes: newMixtapes)
                completion()
            }
        }
    }
    
    //Get user mixtapes from local db
    func getUserMixtapes(userId:String, completion:@escaping ([Mixtape])->Void){
        dispatchQueue.async {
            var result:[Mixtape] = MixtapeDao.getMany(byUserId: userId)
            //Sort by TimeModified
            result.sort{ $0.timeModified > $1.timeModified }
            //return to caller
            completion(result)
        }
    }
    
    //Get mixtapes songs from local db
    func getMixtapeSongItems(mixtapeId:String, completion:@escaping ([SongItem])->Void){
        dispatchQueue.async {
            var result:[SongItem] = self.constructMixtapeSongItems(mixtapeId: mixtapeId)
            //Sort by TimeModified
            result.sort{ $0.song.timeModified > $1.song.timeModified }
            //return to caller
            completion(result)
        }
    }
    
    //MARK: -------------------- Single Objects Fetching --------------------
       
    func getSongItem(songId:String) -> SongItem?{
        //First search if already exists in local db
        var result = constructSongItem(songId: songId)
        
        if result == nil {
            firebase.getSongById(songId:songId){ song in
                self.saveSong(song: song)
                result = self.constructSongItem(songId: songId)
            }
        }
        
        return result
    }
    
    func getMixtapeItem(mixtapeId:String) -> MixtapeItem?{
        //First search if already exists in local db
        var result = constructMixtapeItem(mixtapeId: mixtapeId)
        
        if result == nil {
            firebase.getMixtapeById(mixtapeId: mixtapeId){ mixtape in
                self.saveMixtape(mixtape: mixtape)
                result = self.constructMixtapeItem(mixtapeId: mixtapeId)
            }
        }
        
        return result
    }
    
    func getUser(userId:String) -> User?{
        //First search if already exists in local db
        var result = UserDao.getOne(byId: userId)
        
        if result == nil {
            firebase.getUserById(userId: userId){ user in
                self.saveUser(user: user)
                result = UserDao.getOne(byId: userId)
            }
        }
        
        return result
    }
    
//    func getMixtapeByName(mixtapeName:String)->Mixtape?{
//        //First search if already exists in local db
//        var result = MixtapeDao.getOne(byName: mixtapeName)
//        
//        if result == nil {
//            firebase.getMixtapeByName(mixtapeName: mixtapeName){ mixtape in
//                self.saveMixtape(mixtape: mixtape)
//                result = mixtape
//            }
//        }
//        
//        return result
//    }
    
    //MARK: -------------------- Object Creation --------------------
    
    //Add Song with no image and existing mixtape
    func addSong(song:Song, completion:@escaping ()->Void){
        firebase.addSong(song:song){ newSongId in
            self.saveSong(song: song)
            completion()
        }
    }
    
    //Add Song with no image and new mixtape
    func addSong(song:Song, mixtape:Mixtape, completion:@escaping ()->Void){
        firebase.addMixtape(mixtape: mixtape){ newMixtapeId in
            self.saveMixtape(mixtape: mixtape)
            song.mixtapeId = newMixtapeId
            
            self.firebase.addSong(song:song){ newSongId in
                song.songId = newSongId
                self.saveSong(song: song)
                completion()
            }
        }
    }
    
    //Add Song with image and existing mixtape
    func addSong(song:Song, image:UIImage, completion:@escaping ()->Void){
        firebase.addSong(song:song){ newSongId in
            song.songId = newSongId
            
            self.uploadSongImage(image: image, song: song){
                self.saveSong(song: song)
                completion()
            }
        }
    }
    
    //Add Song with image and new mixtape
    func addSong(song:Song, mixtape:Mixtape, image:UIImage, completion:@escaping ()->Void){
        firebase.addMixtape(mixtape: mixtape){ newMixtapeId in
            song.mixtapeId = newMixtapeId
            self.saveMixtape(mixtape: mixtape)
            
            self.firebase.addSong(song:song){ newSongId in
                song.songId = newSongId
                
                self.uploadSongImage(image: image, song: song){
                    self.saveSong(song: song)
                    completion()
                }
            }
        }
    }
    
//    func addMixtape(mixtape:Mixtape, completion:@escaping (_ newMixtapeId:String)->Void){
//        firebase.addMixtape(mixtape: mixtape, completion: completion)
//    }
    
    //MARK: -------------------- Object Updating --------------------
    
    //Update Song
    func updateSong(song:Song, completion:@escaping ()->Void){
        firebase.updateSong(song: song){
            self.saveSong(song: song)
            completion()
        }
    }
    
    //Update Song with new mixtape
    func updateSong(song:Song, mixtape:Mixtape, completion:@escaping ()->Void){
        firebase.addMixtape(mixtape: mixtape){ newMixtapeId in
            self.saveMixtape(mixtape: mixtape)
            song.mixtapeId = newMixtapeId
            
            self.firebase.updateSong(song: song){
                self.saveSong(song: song)
                completion()
            }
        }
    }
    
    //Update Song with new image
    func updateSong(song:Song, image:UIImage, completion:@escaping ()->Void){
        uploadSongImage(image: image, song: song){
            self.firebase.updateSong(song: song){
                self.saveSong(song: song)
                completion()
            }
        }
    }
    
    //Update Song with new image and new mixtape
    func updateSong(song:Song, mixtape:Mixtape, image:UIImage, completion:@escaping ()->Void){
        firebase.addMixtape(mixtape: mixtape){ newMixtapeId in
            song.mixtapeId = newMixtapeId
            self.saveMixtape(mixtape: mixtape)
            
            self.uploadSongImage(image: image, song: song){
                self.firebase.updateSong(song: song){
                    self.saveSong(song: song)
                    completion()
                }
            }
        }
    }
    
    func updateSongs(songs:[Song], completion:@escaping ()->Void){
        firebase.updateSongs(songs: songs, completion: completion)
    }
    
//    func updateMixtape(mixtape:Mixtape, completion:@escaping ()->Void){
//        firebase.updateMixtape(mixtape: mixtape){
//            self.saveMixtape(mixtape: mixtape)
//            completion()
//        }
//    }
    
//    func updateUser(user:User, completion:@escaping ()->Void){
//        firebase.updateUser(user: user){
//            self.saveUser(user: user)
//            completion()
//        }
//    }
    
    //MARK: -------------------- Object Deleting --------------------
    
    func deleteSong(song:Song, completion:@escaping ()->Void){
        song.deleted = true
        firebase.updateSong(song: song){
            Model.feedDataNotification.post()
            completion()
        }
    }
    
//    func deleteMixtape(mixtape:Mixtape, completion:@escaping ()->Void){
//        mixtape.deleted = true
//        firebase.updateMixtape(mixtape: mixtape){
//            self.dispatchQueue.async {
//                MixtapeDao.delete(mixtape: mixtape)
//                Model.feedDataNotification.post()
//                completion()
//            }
//        }
//    }
    
}


