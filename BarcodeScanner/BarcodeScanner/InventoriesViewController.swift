import UIKit
import RealmSwift

class InventoriesViewController: UIViewController {
   
    @IBOutlet weak var inventoriesTableView: UITableView!
    @IBOutlet weak var showMyTaskSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        let logOutBarButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(didTouchLogOut))
        navigationItem.leftBarButtonItem = logOutBarButton
        // Do any additional setup after loading the view.
    }
    
    @objc func didTouchLogOut() {
        guard let user = ApplicationManager.shared.user else { return }
        Task.init {
            do {
                try await user.logOut()
                print("Successfully logged user out")
                goToLoginScreen()
            } catch {
                print("Failed to log user out: \(error.localizedDescription)")
            }
        }
    }

    func goToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
}
