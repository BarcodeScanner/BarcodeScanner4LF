import UIKit
import RealmSwift

class ApplicationManager {
    static var shared = ApplicationManager()
    var realmConfiguration: Realm.Configuration?
    var user: User?
    var realm: Realm?
    
    private init() {
        
    }
}

class LoginScreenViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func didTouchLogin(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Task.init {
            do {
                ApplicationManager.shared.user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
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
                ApplicationManager.shared.user =  try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
                goToFirstScreen()
            } catch {
                print("Failed to register user: \(error.localizedDescription)")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = app.currentUser {
            let config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                subs.remove(named: Constants.allItems)
                if let _ = subs.first(named: Constants.myItems) {
                    // Existing subscription found - do nothing
                    return
                } else {
                    // No subscription - create it
                    subs.append(QuerySubscription<Product>(name: Constants.myItems) {
                        $0.owner_id == user.id
                    })
                }
            }, rerunOnOpen: true)
            ApplicationManager.shared.realmConfiguration = config
            self.goToFirstScreen()
        } else {
            emailTextField.delegate = self
            passwordTextField.delegate = self
        }
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
