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
                goToFirstScreen()
            } catch {
                print("Failed to login user: \(error.localizedDescription)")
            }
        }
        
    }
    @IBAction func didTouchCreateAccount(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Task.init {
            do {
                try await app.emailPasswordAuth.registerUser(email: email, password: password)
                print("Successfully registered user")
                try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
            } catch {
                print("Failed to register user: \(error.localizedDescription)")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func goToFirstScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let firstScreenViewController = storyboard.instantiateViewController(withIdentifier: "FirstScreenViewController") as? FirstScreenViewController else { return }
        self.navigationController?.setViewControllers([firstScreenViewController], animated: true)
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
