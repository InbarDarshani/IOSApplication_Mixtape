import FirebaseFirestore
import Foundation
import FirebaseAuth
import FirebaseStorage
import UIKit

class ModelFirebase{
    
    let db = Firestore.firestore()          //For working with database
    let mAuth = Auth.auth()                 //For working with user authentication
    let storage = Storage.storage()         //For working with images storage
    
    init(){}
    
    /*______________________________________ AUTHENTICATION ______________________________________*/
    
    func isSignedIn()->Bool{ print("CURRENT USER \(mAuth.currentUser?.email)"); return mAuth.currentUser != nil; }
    
    func signIn(fullName:String, email:String, password: String, completion:@escaping (_ user:User?, _ error:String?)->Void){
        mAuth.signIn(withEmail: email, password: password) { authResult, error in
            guard let firebaseUser = authResult?.user, error == nil else {
                NSLog("TAG Firebase - sign-in failed")
                
#warning ("TODO:")
                print(error!.localizedDescription)
                completion(nil, error!.localizedDescription)
                return
            }
            NSLog("TAG Firebase - sign-in success")
            
            self.getUserById(userId: firebaseUser.uid){ user in completion(user, nil) }
        }
    }
    
    func signUp(fullName:String, email:String, password: String, completion:@escaping (_ user:User?, _ error:String?)->Void){
        mAuth.createUser(withEmail: email, password: password) { authResult, error in
            
            guard let firebaseUser = authResult?.user, error == nil else {
                NSLog("TAG Firebase - sign-up failed")
                
#warning ("TODO: ")
                print(error!.localizedDescription)
                completion(nil, error!.localizedDescription)
                return
            }
            NSLog("TAG Firebase - sign-up success")
            
            let u = User()
            u.userId = firebaseUser.uid
            u.displayName = fullName
            u.email = email
            u.imageUrl = ""
            
            self.addUser(user: u){ newUserId in
                u.userId = newUserId
                completion(u, nil)
            }
            
        }
    }
    
    //    func signInsignUpError(error:String) {
    //           Log.d("TAG", "Firebase - failed to sign-in " + task.getException());
    //
    //           //Get error
    //           Exception e = task.getException();
    //           if (e instanceof FirebaseAuthInvalidCredentialsException) {
    //               Model.instance.authError = "Invalid password";
    //           } else if (e instanceof FirebaseAuthInvalidUserException) {
    //               String errorCode = ((FirebaseAuthInvalidUserException) e).getErrorCode();
    //               switch (errorCode) {
    //                   case "ERROR_USER_NOT_FOUND":
    //                       Model.instance.authError = "No matching account found";
    //                       break;
    //                   case "ERROR_USER_DISABLED":
    //                       Model.instance.authError = "User account has been disabled";
    //                       break;
    //                   case "ERROR_EMAIL_ALREADY_IN_USE":
    //                       Model.instance.authError = "Email is already in use";
    //                       break;
    //                   default:
    //                       Model.instance.authError = e.getMessage();
    //                       break;
    //               }
    //           }
    //       }
    
    func signOut(){
        do {
            try mAuth.signOut()
        } catch let signOutError as NSError {
            NSLog("Firebase - sign-out faild \(signOutError)")
        }
    }
    
    /*__________________________________________ STORAGE _________________________________________*/
    
    func uploadImage(imageName:String, folder:String, image:UIImage, completion: @escaping (_ url:String)->Void){
        let storageRef = storage.reference()
        let imageRef = storageRef.child(folder + "/" + imageName)
        let data = image.jpegData(compressionQuality: 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(data!, metadata: metaData){(metaData,error) in
            imageRef.downloadURL { (url, error) in
                let urlString = url?.absoluteString
                completion(urlString!)
            }
        }
    }
    
    /*___________________________________________ DATA ___________________________________________*/
    
#warning ("TODO:")
    //https://firebase.google.com/docs/firestore/query-data/listen#swift
    //    func songsRealTimeUpdate() {
    //        db.collection(Song.COLLECTION_NAME)
    //            .addSnapshotListener { documentSnapshot, error in
    //                  guard let document = documentSnapshot else {
    //                    NSLog("TAG Firebase - Songs Listen failed \(error!)")
    //                    return
    //                  }
    //                  guard let data = document.data() else {
    //                    NSLog("Document data was empty.")
    //                    return
    //                  }
    
    //    }
    //     func userRealTimeUpdate() {}
    
    
    //_________ New Documents Fetching _________
    
    func getFeedSongs(since:Int64, completion:@escaping ([Song])->Void){
        db.collection(Song.COLLECTION_NAME)
            .whereField("deleted", isEqualTo: false)
            .whereField("timeModified", isGreaterThanOrEqualTo: Timestamp(seconds: since, nanoseconds: 0))
            .getDocuments(){ querySnapshot, error in
                var songs = [Song]()
                if let error = error { NSLog("TAG Firebase - failed to get feed songs \(error)")} else {
                    for document in querySnapshot!.documents {
                        let s = Song.fromJson(json: document.data())
                        songs.append(s)
                    }
                }
                completion(songs)
            }
    }
    
    func getUserMixtapes(since:Int64, userId:String, completion:@escaping ([Mixtape])->Void){
        db.collection(Mixtape.COLLECTION_NAME)
            .whereField("userId", isEqualTo: userId)
            .whereField("deleted", isEqualTo: false)
            .whereField("timeModified", isGreaterThanOrEqualTo: Timestamp(seconds: since, nanoseconds: 0))
            .getDocuments(){ querySnapshot, error in
                var mixtapes = [Mixtape]()
                if let error = error {NSLog("TAG Firebase - failed to get user mixtapes \(error)") } else {
                    for document in querySnapshot!.documents {
                        let m = Mixtape.fromJson(json: document.data())
                        mixtapes.append(m)
                    }
                }
                completion(mixtapes)
            }
    }
    
    func getUserSongs(since:Int64, userId:String, completion:@escaping ([Song])->Void){
        db.collection(Song.COLLECTION_NAME)
            .whereField("userId", isEqualTo: userId)
            .whereField("deleted", isEqualTo: false)
            .whereField("timeModified", isGreaterThanOrEqualTo: Timestamp(seconds: since, nanoseconds: 0))
            .getDocuments(){ querySnapshot, error in
                var songs = [Song]()
                if let error = error { NSLog("TAG Firebase - failed to get user songs \(error)")} else {
                    for document in querySnapshot!.documents {
                        let s = Song.fromJson(json: document.data())
                        songs.append(s)
                    }
                }
                completion(songs)
            }
    }
    
    func getFeedDeletedSongs(since:Int64, completion:@escaping ([Song])->Void){
        db.collection(Song.COLLECTION_NAME)
            .whereField("deleted", isEqualTo: true)
            .whereField("timeModified", isGreaterThanOrEqualTo: Timestamp(seconds: since, nanoseconds: 0))
            .getDocuments(){ querySnapshot, error in
                var songsToRemove = [Song]()
                if let error = error { NSLog("TAG Firebase - failed to get feed songs \(error)")} else {
                    for document in querySnapshot!.documents {
                        let s = Song.fromJson(json: document.data())
                        songsToRemove.append(s)
                    }
                }
                completion(songsToRemove)
            }
    }
    
    //_________ Multiple Documents Fetching _________
    
    func getMixtapesByIds(mixtapeIds:[String], completion:@escaping ([Mixtape])->Void){
        //'in' filters support a maximum of 10 elements in the value array
        
        if mixtapeIds.count > 10{
            db.collection(Mixtape.COLLECTION_NAME)
                .whereField("deleted", isEqualTo: false)
                .getDocuments(){ querySnapshot, error in
                    var mixtapes = [Mixtape]()
                    if let error = error { NSLog("TAG Firebase - failed to get mixtapes \(error)") } else {
                        for document in querySnapshot!.documents {
                            if mixtapeIds.contains(document.documentID){
                                let m = Mixtape.fromJson(json: document.data())
                                mixtapes.append(m)
                            }
                        }
                    }
                    completion(mixtapes)
                }
        } else {
            db.collection(Mixtape.COLLECTION_NAME)
                .whereField("mixtapeId", in: mixtapeIds)
                .getDocuments(){ querySnapshot, error in
                    var mixtapes = [Mixtape]()
                    if let error = error { NSLog("TAG Firebase - failed to get mixtapes \(error)") } else {
                        for document in querySnapshot!.documents {
                            let m = Mixtape.fromJson(json: document.data())
                            mixtapes.append(m)
                        }
                    }
                    completion(mixtapes)
                }
        }
    }
    
    func getUsersByIds(userIds:[String], completion:@escaping ([User])->Void){
        //'in' filters support a maximum of 10 elements in the value array
        
        if userIds.count > 10{
            db.collection(User.COLLECTION_NAME)
                .whereField("deleted", isEqualTo: false)
                .getDocuments(){ querySnapshot, error in
                    var users = [User]()
                    if let error = error { NSLog("TAG Firebase - failed to get users \(error)") } else {
                        for document in querySnapshot!.documents {
                            if userIds.contains(document.documentID){
                                let u = User.fromJson(json: document.data())
                                users.append(u)
                            }
                        }
                    }
                    completion(users)
                }
        }else{
            db.collection(User.COLLECTION_NAME)
                .whereField("userId", in: userIds)
                .getDocuments(){ querySnapshot, error in
                    var users = [User]()
                    if let error = error { NSLog("TAG Firebase - failed to get users \(error)") } else {
                        for document in querySnapshot!.documents {
                            let u = User.fromJson(json: document.data())
                            users.append(u)
                        }
                    }
                    completion(users)
                }
        }
    }
    
    //_________ Single Document Fetching _________
    
    func getSongById(songId:String, completion:@escaping (Song)->Void ){
        db.collection(Song.COLLECTION_NAME)
            .whereField("songId", isEqualTo: songId)
            .getDocuments(){ querySnapshot, error in
                var song = Song()
                if let error = error { NSLog("TAG Firebase - failed to get song \(error)")} else {
                    for document in querySnapshot!.documents {
                        song = Song.fromJson(json: document.data())
                    }
                }
                completion(song)
            }
    }
    
    func getMixtapeById(mixtapeId:String, completion:@escaping (Mixtape)->Void ){
        db.collection(Mixtape.COLLECTION_NAME)
            .whereField("mixtapeId", isEqualTo: mixtapeId)
            .getDocuments(){ querySnapshot, error in
                var mixtape = Mixtape()
                if let error = error { NSLog("TAG Firebase - failed to get mixtape \(error)")} else {
                    for document in querySnapshot!.documents {
                        mixtape = Mixtape.fromJson(json: document.data())
                    }
                }
                completion(mixtape)
            }
    }
    
    func getUserById(userId:String, completion:@escaping (User)->Void ){
        db.collection(User.COLLECTION_NAME)
            .whereField("userId", isEqualTo: userId)
            .getDocuments(){ querySnapshot, error in
                var user = User()
                if let error = error { NSLog("TAG Firebase - failed to get mixtape \(error)")} else {
                    for document in querySnapshot!.documents {
                        user = User.fromJson(json: document.data())
                    }
                }
                completion(user)
            }
    }
    
    
    //_________ Document Creation _________
    
    func addSong(song:Song, completion:@escaping (_ newSongId:String)->Void){
        let addedDocRef:DocumentReference = db.collection(Song.COLLECTION_NAME).document()
        song.songId = addedDocRef.documentID
        addedDocRef.setData(song.toJson()) { error in
            if let error = error { NSLog("TAG Firebase - failed to add song \(error)") }
            else { completion(song.songId!) }
        }
    }
    
    func addMixtape(mixtape:Mixtape, completion:@escaping (_ newMixtapeId:String)->Void){
        let addedDocRef:DocumentReference = db.collection(Mixtape.COLLECTION_NAME).document()
        mixtape.mixtapeId = addedDocRef.documentID
        addedDocRef.setData(mixtape.toJson()) { error in
            if let error = error { NSLog("TAG Firebase - failed to add mixtape \(error)") }
            else { completion(mixtape.mixtapeId!) }
        }
    }
    
    func addUser(user:User, completion:@escaping (_ newUserId:String)->Void){
        let addedDocRef:DocumentReference = db.collection(User.COLLECTION_NAME).document()
        user.userId = addedDocRef.documentID
        addedDocRef.setData(user.toJson()) { error in
            if let error = error { NSLog("TAG Firebase - failed to add user \(error)") }
            else { completion(user.userId!) }
        }
    }
    
    //_________ Document Updating _________
    
    func updateSong(song:Song, completion:@escaping ()->Void){
        var json = song.toJson()
        json["timeModified"] =  FieldValue.serverTimestamp()
        db.collection(Song.COLLECTION_NAME).document(song.songId!).setData(json){ error in
            if let error = error { NSLog("TAG Firebase - failed to upate song \(error)") }
            completion()
        }
    }
    
    func updateSongs(songs:[Song], completion:@escaping ()->Void){
        //Get a new write batch
        let batch = db.batch();
        
        for song in songs {
            var json = song.toJson()
            json["timeModified"] =  FieldValue.serverTimestamp()
            let documentReference:DocumentReference = db.collection(Song.COLLECTION_NAME).document(song.songId!)
            batch.updateData(json, forDocument: documentReference)
        }
        
        batch.commit(){ error in
            if let error = error { NSLog("TAG Firebase - failed to update songs \(error)") }
            completion()
        }
    }
    
    func updateMixtape(mixtape:Mixtape, completion:@escaping ()->Void){
        var json = mixtape.toJson()
        json["timeModified"] =  FieldValue.serverTimestamp()
        db.collection(Mixtape.COLLECTION_NAME).document(mixtape.mixtapeId!).setData(json){ error in
            if let error = error { NSLog("TAG Firebase - failed to upate mixtape \(error)") }
            completion()
        }
    }
    
    func updateUser(user:User, completion:@escaping ()->Void){
        var json = user.toJson()
        json["timeModified"] =  FieldValue.serverTimestamp()
        db.collection(User.COLLECTION_NAME).document(user.userId!).setData(json){ error in
            if let error = error { NSLog("TAG Firebase - failed to upate user \(error)") }
            completion()
        }
    }
    
    
}
