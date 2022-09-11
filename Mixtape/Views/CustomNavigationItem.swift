import UIKit

class CustomNavigationItem: UINavigationItem {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Add App brand to top bar in addition to default back button and page title
        let label = UILabel()
        label.text =  "Mixtape"
        label.font = UIFont(name: "storytime", size: 30)
        label.textColor = UIColor(named: "white")
        self.leftBarButtonItem = UIBarButtonItem(customView: label)
        self.leftItemsSupplementBackButton = true
        
        //Remove back button title
        self.backButtonTitle = ""
        
        //Set menu button
        let logout = UIAction(title: "Logout", image: nil){ action in
            Model.instance.signOut()
            //Replace root view controller to the login storyboard entry point controller
            if let targetViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
            }
            
        }
        
        let barButtonMenu = UIMenu(title: "User Actions", children: [logout])
        rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), primaryAction: nil, menu: barButtonMenu)
    }
}

