import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        #warning("TODO: main theme")
        //Set app font
        guard let quicksandFont = UIFont(name:"quicksand", size: UIFont.labelFontSize)
        else { fatalError("Failed to load custom font - quicksand") }
        let font = UIFontMetrics.default.scaledFont(for: quicksandFont)

        UILabel.appearance().font = font
            
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
