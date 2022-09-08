import UIKit

//Same Controller for sign-in and sign-up pages
class LoginViewController: UIViewController {

    //MARK: View references
    @IBOutlet weak var email_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var firstname_tf: UITextField!
    @IBOutlet weak var lastname_tf: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Data holders
    var email = "" { didSet{ if(email_tf != nil){ email_tf.text = email } } }
    var password = "" { didSet{ if(password_tf != nil){ password_tf.text = password } } }
    var firstName = "" { didSet{ if(firstname_tf != nil){ firstname_tf.text = firstName } } }
    var lastName = "" { didSet{ if(lastname_tf != nil){ lastname_tf.text = lastName } } }
    
    //MARK: Internal variables
    let alert = UIAlertController(title: "Login Error", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title:"OK", style: .default, handler: { (alert:UIAlertAction!)-> Void in } )
    var newUser = false
    var emailInput = ""
    var passwordInput = ""
    var firstnameInput = ""
    var lastnameInput = ""
    
    //MARK: View Actions
    @IBAction func unwind(unwindSegue: UIStoryboardSegue){}
    @IBAction func signIn(_ sender: Any) { submit() }
    @IBAction func signUp(_ sender: Any) {
        newUser = true
        submit()
    }
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if(email_tf != nil){ email_tf.text = email }
        if(password_tf != nil){ password_tf.text = password }
        if(firstname_tf != nil){ firstname_tf.text = firstName }
        if(lastname_tf != nil){ lastname_tf.text = lastName }
        alert.addAction(alertAction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp" || segue.identifier == "toSignIn"{
            let destination = segue.destination as! LoginViewController
            destination.email = self.email_tf.text!
            destination.password = self.password_tf.text!
            destination.firstName = self.firstname_tf?.text ?? ""
            destination.lastName = self.lastname_tf?.text ?? ""
        }
        
        if segue.identifier == "toMain" {
            //Replace root view controller to the main storyboard entry point controller
            if let targetViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(targetViewController)
            }
        }
    }
    
    //MARK: Internal functions
    func submit(){
        activityIndicator.startAnimating()
        if validateInput(){
            Model.instance.signInsignUp(newUser: newUser, fullName: firstnameInput + " " + lastnameInput, email: emailInput, password: passwordInput){ user, error in
                guard error == nil else{
                    self.activityIndicator.stopAnimating()
                    self.alert.message = error
                    self.present(self.alert, animated:true, completion:nil)
                    return
                }
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        } else {
            activityIndicator.stopAnimating()
            self.present(alert, animated:true, completion:nil)
        }
    }
    
    func validateInput() -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailValidator = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        let passwordPattern = "^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$"
        let passswordValidator = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        
        //Get and Set user inputs
        emailInput = email_tf.text!.trimmingCharacters(in: .whitespaces)
        passwordInput = password_tf.text!
        firstnameInput = firstname_tf?.text ?? ""
        lastnameInput = lastname_tf?.text ?? ""
        
        if emailInput.isEmpty || passwordInput.isEmpty{
            alert.message = "Please fill both email and password"
            return false
        }
        
        if !emailValidator.evaluate(with: emailInput){
            alert.message = "Please fill proper email address"
            return false
        }
        
        if newUser{
            if firstnameInput.isEmpty || lastnameInput.isEmpty{
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
