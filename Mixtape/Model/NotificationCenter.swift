import Foundation

//Generic notification center class for creating diferent types of notifications
class ModelNotificationBase{
    let name:String
    init(_ name:String){
        self.name=name
    }
    func observe(callback:@escaping ()->Void){
        NotificationCenter.default.addObserver(forName: Notification.Name(name), object: nil, queue: nil){ data in
            NSLog("TAG NotificationCenter - got notify \(data)")
            callback()
        }
    }
    func post(){
        NotificationCenter.default.post(name: Notification.Name(name), object: self)
        NSLog("TAG NotificationCenter - post notify \(self)")
    }
}


