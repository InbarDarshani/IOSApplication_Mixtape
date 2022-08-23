import UIKit

class LoginViewController: UIViewController {
    //View variables
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    //Passed variables
    var email = "" { didSet{ if(emailField != nil){ emailField.text = email } } }
    var password = "" { didSet{ if(passwordField != nil){ passwordField.text = password } } }
    var firstName = "" { didSet{ if(firstNameField != nil){ firstNameField.text = firstName } } }
    var lastName = "" { didSet{ if(lastNameField != nil){ lastNameField.text = lastName } } }
    
    //Internal variables
    let alert = UIAlertController(title: "Login Error", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title:"OK", style: .default, handler: { (alert:UIAlertAction!)-> Void in } )
    var newUser = false
    var emailInput = ""
    var passwordInput = ""
    var firstNameInput = ""
    var lastNameInput = ""
        
    @IBAction func unwind(unwindSegue: UIStoryboardSegue){}
    
    @IBAction func signIn(_ sender: Any) {
        //print("SignIn \(emailField.text) and \(passwordField.text)")
        submit()
    }
    
    @IBAction func signUp(_ sender: Any) {
        //print("SignUp \(String(describing: emailField.text)) \(passwordField.text)")
        newUser = true
        submit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(emailField != nil){ emailField.text = email }
        if(passwordField != nil){ passwordField.text = password }
        if(firstNameField != nil){ firstNameField.text = firstName }
        if(lastNameField != nil){ lastNameField.text = lastName }
        alert.addAction(alertAction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp" || segue.identifier == "toSignIn"{
            let destination = segue.destination as! LoginViewController
            destination.email = self.emailField.text!
            destination.password = self.passwordField.text!
            destination.firstName = self.firstNameField?.text ?? ""
            destination.lastName = self.lastNameField?.text ?? ""
        }
        
        if segue.identifier == "toMain" {
            //Replace root view controller to the main storyboard entry point controller
            if let targetViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
            }
        }
    }
    
    func submit(){
        if validateInput(){
            Model.instance.signInsignUp(newUser: newUser, fullName: firstNameInput + " " + lastNameInput, email: emailInput, password: passwordInput){ user, error in
                guard error == nil else{
                    self.alert.message = error
                    return
                }
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
        self.present(alert, animated:true, completion:nil)
    }
    
//    func toMainStoryboard(){
//        //Replace root view controller to the main storyboard entry point controller
//        if let targetViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
//            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
//        }
//    }
    
    func validateInput() -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailValidator = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        let passwordPattern = "^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$"
        let passswordValidator = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        
        //Get and Set user inputs
        emailInput = emailField.text!.trimmingCharacters(in: .whitespaces)
        passwordInput = passwordField.text!
        firstNameInput = firstNameField?.text ?? ""
        lastNameInput = lastNameField?.text ?? ""
        
        if emailInput.isEmpty || passwordInput.isEmpty{
            alert.message = "Please fill both email and password"
            return false
        }
        
        if !emailValidator.evaluate(with: emailInput){
            alert.message = "Please fill proper email address"
            return false
        }
        
        if newUser{
            
            if firstNameInput.isEmpty || lastNameInput.isEmpty{
                alert.message = "Please fill first and last name"
                return false
            }
            
            if !passswordValidator.evaluate(with: passwordInput){
                alert.message = "Password must be at least 6 characters,\nmust contain at east one digit\nand at least one character"
                return false
            }
        }
        return true
    }
    
}
