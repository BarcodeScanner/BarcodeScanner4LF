import UIKit
import RealmSwift

class LoginScreenViewController: UIViewController {
    
    let minPasswordLength = 6

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func didTouchLogin(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Task.init {
            do {
                let user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
                UserDefaults.standard.set(email, forKey: "useremail")
                ApplicationManager.shared.user = user
                self.continueApp(with: user)
            } catch {
                print("Failed to login user: \(error.localizedDescription)")
                self.invalidEmailOrPasswordAlert()
            }
        }
    }
    @IBAction func didTouchCreateAccount(_ sender: UIButton) {
        self.createAccount()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        if let user = app.currentUser {
            ApplicationManager.shared.user = user
            self.continueApp(with: user)
        }
    }
    
    func createAccount() {
        guard let emailAddress = self.emailTextField.text, let password = self.passwordTextField.text else { return }
        var errorMessage = ""

        if emailAddress.isEmpty {
            errorMessage.append("Please enter your account email address.")
        } else if self.validateEmail(enteredEmail: emailAddress) == false {
            errorMessage.append("Please enter a valid email address.")
        }

        let inputPasswordLength = password.count

        if password.isEmpty {
            errorMessage.append("\n")
            errorMessage.append("Please enter a password.")
        } else if self.isValidPassword(enteredPassword: password) == false {
            if(!NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: password)){
                errorMessage.append("\n")
                errorMessage.append("Your password must have at least one uppercase")
            }
            
            if(!NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: password)){
                errorMessage.append("\n")
                errorMessage.append("Your password must have at least one digit")
            }
            
            if(!NSPredicate(format:"SELF MATCHES %@", ".*[!&^%$#@()/]+.*").evaluate(with: password)){
                errorMessage.append("\n")
                errorMessage.append("Your password must have at least one symbol")
            }
            
            if(!NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: password)){
                errorMessage.append("\n")
                errorMessage.append("Your password must have at least one lowercase.")
            }
            
            if inputPasswordLength < minPasswordLength {
                errorMessage.append("\n")
                errorMessage.append("Your password must have 8 characters or more.")
            }
        }
        
        if !errorMessage.isEmpty {
            self.errorCreateAccount(errorMessage: errorMessage)
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Task.init {
            do {
                try await app.emailPasswordAuth.registerUser(email: email, password: password)
                print("Successfully registered user")
                let user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
                ApplicationManager.shared.user = user
                UserDefaults.standard.set(email, forKey: "useremail")
                self.continueApp(with: user)
            } catch {
                print("Failed to register user: \(error.localizedDescription)")
                self.errorCreateAccount()
            }
        }

    }
    public func isValidPassword(enteredPassword: String) -> Bool {
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: enteredPassword)
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    func continueApp(with user: User) {
        guard let usermail = UserDefaults.standard.string(forKey: "useremail") else { return }
        if usermail.hasPrefix("admin@") {
            self.goToFirstScreen()
        } else {
            guard let loadingViewController = self.storyboard?.instantiateViewController(withIdentifier: "PleaseWaitViewController") as? PleaseWaitViewController else { return }
            self.navigationController?.setViewControllers([loadingViewController], animated: false)
        }
    }
    
    func goToFirstScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let firstScreenViewController = storyboard.instantiateViewController(withIdentifier: "FirstScreenViewController") as? FirstScreenViewController else { return }
        
        self.navigationController?.setViewControllers([firstScreenViewController], animated: true)
    }
    
    func invalidEmailOrPasswordAlert() {
        let alert = UIAlertController(title: "Error", message: "Invalid Email or Password", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorCreateAccount(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorCreateAccount() {
        let alert = UIAlertController(title: "Error", message: "Failed to register user", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginScreenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
