import UIKit
import RealmSwift

class ApplicationManager {
    static var shared = ApplicationManager()
    var realmConfiguration: Realm.Configuration?
    var user: User?
    var realm: Realm?
    @ObservedResults(Product.self) var products
    
    private init() {
        app.syncManager.errorHandler = { syncError, session in
            if let thisError = syncError as? SyncError {
                switch thisError.code {
                    
                case .clientSessionError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientUserError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientInternalError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientResetError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .underlyingAuthError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .permissionDeniedError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .invalidFlexibleSyncSubscriptions:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .writeRejected:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                @unknown default:
                    break
                }
            }
        }
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
                goToInventoriesScreen()
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
                goToInventoriesScreen()
            } catch {
                print("Failed to register user: \(error.localizedDescription)")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = app.currentUser {
            ApplicationManager.shared.user = user
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
    
    func goToInventoriesScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "InventoriesViewController") as? InventoriesViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
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
