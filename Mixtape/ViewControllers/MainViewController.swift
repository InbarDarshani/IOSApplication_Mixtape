import UIKit

class MainAppViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

#warning("TODO: main theme")
        //Set app font
        guard let quicksandFont = UIFont(name:"quicksand", size: UIFont.labelFontSize)
        else { fatalError("Failed to load custom font - quicksand") }
        let font = UIFontMetrics.default.scaledFont(for: quicksandFont)

        UILabel.appearance().font = font
        
        
    }
    


}
