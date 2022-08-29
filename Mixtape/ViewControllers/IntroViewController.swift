import UIKit
import SwiftyGif

class IntroViewController: UIViewController {
    
    //MARK: View references
    @IBOutlet weak var introGif: UIImageView!
    
    //MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        introGif.delegate = self
        do {
            let gif = try UIImage(gifName: "mixtape_loader.gif", levelOfIntegrity:0.05)
            introGif.setGifImage(gif, loopCount: 1)
        } catch { NSLog("IntroViewController - error loading gif \(error)") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var targetStoryboard = UIStoryboard()
        
        switch segue.identifier {
        case "toMain":
            targetStoryboard = UIStoryboard(name: "Main", bundle: nil)
        case "toLogin":
            targetStoryboard = UIStoryboard(name: "Login", bundle: nil)
        default:
            targetStoryboard = self.storyboard!
        }
        
        //Replace root view controller to the target storyboard entry point controller
        if let targetViewController = targetStoryboard.instantiateInitialViewController() {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
        }
    }

}

extension IntroViewController: SwiftyGifDelegate {
    //Wait for gif loop to end
    func gifDidStop(sender: UIImageView) {
        if Model.instance.isSignedIn(){
            performSegue(withIdentifier: "toMain", sender: self)
        } else {
            performSegue(withIdentifier: "toLogin", sender: self)
        }
    }
}
