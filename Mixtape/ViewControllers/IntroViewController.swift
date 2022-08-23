import UIKit
import SwiftyGif

class IntroViewController: UIViewController {
    
    @IBOutlet weak var introGif: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        introGif.delegate = self
        introGif.clear()
        do {
            let gif = try UIImage(gifName: "mixtape_loader.gif", levelOfIntegrity:0.2)
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
        
        if let targetViewController = targetStoryboard.instantiateInitialViewController() {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
        }
    }
}

extension IntroViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        if Model.instance.isSignedIn(){
            print("User connected")
            performSegue(withIdentifier: "toMain", sender: self)
        } else {
            print("No User connected")
            performSegue(withIdentifier: "toLogin", sender: self)
        }
    }
}
