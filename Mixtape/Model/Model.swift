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
    
    //MARK: -------------------------------------- AUTHENTICATION --------------------------------------
    
    func isSignedIn()->Bool{ return firebase.isSignedIn() }
    
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
        //Save user id to app shared preferences
        UserDefaults.standard.set(user.userId, forKey:"CURRENT_USER_ID")
        UserDefaults.standard.set(user.email, forKey:"CURRENT_USER_EMAIL")
        UserDefaults.standard.set(user.displayName, forKey:"CURRENT_USER_NAME")
        UserDefaults.standard.set(user.imageUrl, forKey:"CURRENT_USER_IMAGE")
        
        //Save to local DB
        dispatchQueue.async{ UserDao.insert(user: user) }
    }
    
    private func clearCurrentUser(){
        //Clear user id in app shared preferences
        UserDefaults.standard.removeObject(forKey:"CURRENT_USER_ID")
        UserDefaults.standard.removeObject(forKey:"CURRENT_USER_EMAIL")
        UserDefaults.standard.removeObject(forKey:"CURRENT_USER_NAME")
        UserDefaults.standard.removeObject(forKey:"CURRENT_USER_IMAGE")
    }
    
    func getCurrentUser() -> User{
        let u = User()
        u.userId = UserDefaults.standard.string(forKey: "CURRENT_USER_ID")
        u.email = UserDefaults.standard.string(forKey: "CURRENT_USER_EMAIL")
        u.displayName = UserDefaults.standard.string(forKey: "CURRENT_USER_NAME")
        u.imageUrl = UserDefaults.standard.string(forKey: "CURRENT_USER_IMAGE")
        return u
    }
    
    //MARK: ---------------------------------------- STORAGE ----------------------------------------
    
    private func uploadImage(imageName:String, folder:String, image:UIImage, completion:@escaping(_ url:String)->Void){
        firebase.uploadImage(imageName: imageName, folder: folder, image: image, completion: completion)
    }
    
    func uploadSongImage(image:UIImage, song:Song, completion:@escaping(_ url:String)->Void){
        uploadImage(imageName: song.songId!, folder: Song.COLLECTION_NAME, image: image, completion:completion)
    }
    
    func uploadUserImage(image:UIImage, user:User, completion:@escaping(_ url:String)->Void){
        uploadImage(imageName: user.userId!, folder: User.COLLECTION_NAME, image: image, completion: completion)
    }
    
    //MARK: -------------------------------------- DATA --------------------------------------
    
    //MARK: ---------- Local Objects Saving and Updating ----------
    
    private func saveSong(song:Song){
        dispatchQueue.async{
            SongDao.insert(song: song)
            Model.feedDataNotification.post()
            self.getFeedData(){}
        }
    }
    
    private func saveMixtape(mixtape:Mixtape){
        dispatchQueue.async{
            MixtapeDao.insert(mixtape: mixtape)
            self.getFeedData(){}
        }
    }
    
    private func saveUser(user:User){
        dispatchQueue.async{
            UserDao.insert(user: user)
        }
        getFeedData(){}
    }
    
    //MARK: ---------- Objects Binding ----------
    
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
                items.insert(songItem, at: items.endIndex)
            }
        }
        
        //Sort by TimeModified
        items.sort{ $0.song.timeModified > $1.song.timeModified }
        return items
    }
    
    //Construct user mixtape items objects from local db
    private func constructUserMixtapeItems(userId:String) -> [MixtapeItem]{
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
                items.insert(mixtapeItem, at: items.endIndex)
            }
        }
        
        //Sort by TimeModified
        items.sort{ $0.mixtape.timeModified > $1.mixtape.timeModified }
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
            
            if localUser != nil{
                let mixtapeItem = MixtapeItem()
                mixtapeItem.mixtape = localMixtape!
                mixtapeItem.songs = localMixtapeSongs
                mixtapeItem.user = localUser!
                return mixtapeItem
            }
        }
        return nil
    }
    
    //MARK: ---------- Multiple Objects Fetching ----------
    
    func getFeed(completion:@escaping ([SongItem])->Void) {
        getFeedData(){
            let results = self.constructFeedItems()
            NSLog("TAG Model - firebase returned \(results.count) songItems to feed")
            DispatchQueue.main.async { completion(results) }
        }
    }
    
    func getProfile(completion:@escaping ([MixtapeItem])->Void) {
        let userId = getCurrentUser().userId!
        getProfileData(userId: userId){
            let results = self.constructUserMixtapeItems(userId: userId)
            NSLog("TAG Model - firebase returned \(results.count) mixtapeItems to profile")
            DispatchQueue.main.async { completion(results) }
        }
    }
    
    private func getFeedData(completion:@escaping ()->Void) {
        //Get the Local Last Update time
        let lastUpdate = SongDao.getLocalLastUpdated()
        NSLog("TAG Model - local last update is \(lastUpdate)")
        
        //Remove recently deleted songs
        firebase.getFeedDeletedSongs(since: lastUpdate){ songsToRemove in
            self.dispatchQueue.async{ SongDao.deleteMany(songs: songsToRemove) }
        }
        
        firebase.getFeedSongs(since: lastUpdate){ newSongs in
            
            if newSongs.count == 0 {
                completion()
                return
            }
            
            //Save new feed songs to local db
            self.dispatchQueue.async{ SongDao.insertMany(songs: newSongs) }
            
            //Get required mixtapes and user ids
            let newMixtapeIds = newSongs.map{ $0.mixtapeId! }
            let newUserIds = newSongs.map{ $0.userId! }
            
            //Get and save feed mixtapes and users
            self.firebase.getUsersByIds(userIds: newUserIds){ newUsers in
                //Save feed users to local db
                self.dispatchQueue.async{ UserDao.insertMany(users: newUsers) }
                
                self.firebase.getMixtapesByIds(mixtapeIds: newMixtapeIds){ newMixtapes in
                    //Save feed mixtapes to local db
                    self.dispatchQueue.async{
                        MixtapeDao.insertMany(mixtapes: newMixtapes)
                        completion()
                    }
                }
            }
        }
    }
    
    private func getProfileData(userId:String, completion:@escaping ()->Void) {
        firebase.getUserMixtapes(since: 0, userId: userId){ mixtapes in
            if mixtapes.isEmpty { return }
            //Save profile mixtapes to local db
            self.dispatchQueue.async{
                MixtapeDao.insertMany(mixtapes: mixtapes)
                completion()
            }
        }
    }
    
    //MARK: ---------- Single Objects Fetching ----------
    
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
    
    //MARK: ---------- Object Creation ----------
    
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
            
            self.uploadSongImage(image: image, song: song){ url in
                song.imageUrl = url
                
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
                
                self.uploadSongImage(image: image, song: song){ url in
                    song.imageUrl = url
                    
                    self.saveSong(song: song)
                    completion()
                }
            }
        }
    }
    
    func addMixtape(mixtape:Mixtape, completion:@escaping (_ newMixtapeId:String)->Void){
        firebase.addMixtape(mixtape: mixtape, completion: completion)
    }
    
    //MARK: ---------- Object Updating ----------
    
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
        uploadSongImage(image: image, song: song){url in
            song.imageUrl = url
            
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
            
            self.uploadSongImage(image: image, song: song){ url in
                song.imageUrl = url
                
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
    
    func updateMixtape(mixtape:Mixtape, completion:@escaping ()->Void){
        firebase.updateMixtape(mixtape: mixtape){
            self.saveMixtape(mixtape: mixtape)
            completion()
        }
    }
    
    func updateUser(user:User, completion:@escaping ()->Void){
        firebase.updateUser(user: user){
            self.saveUser(user: user)
            completion()
        }
    }
    
    //MARK: ---------- Object Deleting ----------
    
    func deleteSong(song:Song, completion:@escaping ()->Void){
        song.deleted = true
        firebase.updateSong(song: song){
            self.dispatchQueue.async {
                SongDao.delete(song: song)
                self.getFeedData(completion: completion)
            }
        }
    }
    
    func deleteMixtape(mixtape:Mixtape, completion:@escaping ()->Void){
        mixtape.deleted = true
        firebase.updateMixtape(mixtape: mixtape){
            self.dispatchQueue.async {
                MixtapeDao.delete(mixtape: mixtape)
                self.getFeedData(completion: completion)
            }
        }
    }
    
}


