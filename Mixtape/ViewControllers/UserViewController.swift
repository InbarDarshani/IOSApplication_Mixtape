//
//  UserViewController.swift
//  Mixtape
//
//  Created by Inbar on 25/08/2022.
//

import UIKit

class UserViewController: UIViewController {

    @IBAction func logout(_ sender: Any) {
        Model.instance.signOut()
        //Replace root view controller to the login storyboard entry point controller
        if let targetViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogin" {
            //Replace root view controller to the main storyboard entry point controller
            if let targetViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
            }
        }
    }
    

}
