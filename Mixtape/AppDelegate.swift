import UIKit
import CoreData
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    override init() {
        super.init()
        //Override systemfont
        UIFont.overrideInitialize()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Firebase init from GoogleService-Info file
        FirebaseApp.configure()
        
        //App theme setup
        UILabel.appearance().adjustsFontSizeToFitWidth = true                   //set font to resize automaticly
        
        UINavigationBar.appearance().tintColor = UIColor(named: "white")        //background color of the navigation bar
        UINavigationBar.appearance().barTintColor = UIColor(named: "beige")      //color of the back indicator image, button titles, button images
        UINavigationBar.appearance().isTranslucent = false
        let nabBarAppearance = UINavigationBarAppearance()
        nabBarAppearance.configureWithOpaqueBackground()
        nabBarAppearance.backgroundColor = UIColor(named: "beige")
        nabBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "white")!, .font: UIFont(name: "quicksand-light", size: 16)]
        UINavigationBar.appearance().standardAppearance = nabBarAppearance
        UINavigationBar.appearance().compactAppearance = nabBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = nabBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = nabBarAppearance
        
        UITabBar.appearance().tintColor = UIColor(named: "white")
        UITabBar.appearance().barTintColor = UIColor(named: "beige")
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "beige")
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

