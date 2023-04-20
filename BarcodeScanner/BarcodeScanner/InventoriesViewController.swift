import UIKit
import RealmSwift

class InventoriesViewController: UIViewController {
   
    @IBOutlet weak var inventoriesTableView: UITableView!
    @IBOutlet weak var showMyTaskSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        let logOutBarButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(didTouchLogOut))
        navigationItem.leftBarButtonItem = logOutBarButton
        let newinventoryImage = UIImage(systemName: "plus")
        let newInventoryButton = UIBarButtonItem(image: newinventoryImage, style: .plain, target: self, action: #selector(goToNewInventoryScreen))
        navigationItem.rightBarButtonItem = newInventoryButton
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
    
    @objc func goToNewInventoryScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let newInventoryScreenViewController = storyboard.instantiateViewController(withIdentifier: "CreateInventoryViewController") as? CreateInventoryViewController else { return }
        self.navigationController?.pushViewController(newInventoryScreenViewController, animated: true)
        
        // self.navigationController?.setViewControllers([newInventoryScreenViewController], animated: true)
    }

    func goToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
}
