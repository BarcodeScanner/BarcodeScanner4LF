import UIKit
import RealmSwift

class LoginScreenViewController: UIViewController {

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
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Task.init {
            do {
                try await app.emailPasswordAuth.registerUser(email: email, password: password)
                print("Successfully registered user")
                let user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
                ApplicationManager.shared.user = user
                self.continueApp(with: user)
            } catch {
                print("Failed to register user: \(error.localizedDescription)")
            }
        }
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
