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
                ApplicationManager.shared.user = user
                self.continueApp(with: user)
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

        if let user = app.currentUser {
            ApplicationManager.shared.user = user
            self.continueApp(with: user)
        } else {
            emailTextField.delegate = self
            passwordTextField.delegate = self
        }
    }
    
    func continueApp(with user: User) {
        Task {
            do {
                try await self.goToInventoriesScreen(with: user)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func goToFirstScreen(with user: User) async throws {
        ApplicationManager.shared.realm = try await ApplicationManager.shared.openFlexibleSyncRealm(for: user)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let firstScreenViewController = storyboard.instantiateViewController(withIdentifier: "FirstScreenViewController") as? FirstScreenViewController else { return }
        
        self.navigationController?.setViewControllers([firstScreenViewController], animated: true)
    }
    
    func goToInventoriesScreen(with user: User) async throws  {
        ApplicationManager.shared.realm = try await ApplicationManager.shared.openFlexibleSyncRealm(for: user)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "InventoriesViewController") as? InventoriesViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
        
    func openRealm(for user: User) async {
        do {
            
            /*
             print(ApplicationManager.shared.realm?.objects(Product.self).count)
             ApplicationManager.shared.realm?.beginWrite()
             ApplicationManager.shared.realm?.objects(Product.self).forEach({
             ApplicationManager.shared.realm?.delete($0)
             })
             try ApplicationManager.shared.realm?.commitWrite()
             */
        } catch {
            print(error.localizedDescription)
        }
        
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
