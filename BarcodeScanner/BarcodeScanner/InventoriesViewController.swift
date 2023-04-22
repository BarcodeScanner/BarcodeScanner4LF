import UIKit
import RealmSwift

class InventoriesViewController: UIViewController {
    @IBOutlet weak var inventoriesTableView: UITableView!
    @IBOutlet weak var showMyTaskSwitch: UISwitch!

    private var inventories = ApplicationManager.shared.realm?.objects(Inventory.self)
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inventoriesTableView.delegate = self
        self.inventoriesTableView.dataSource = self
        
        let logOutBarButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(didTouchLogOut))
        navigationItem.leftBarButtonItem = logOutBarButton
        let newinventoryImage = UIImage(systemName: "plus")
        let newInventoryButton = UIBarButtonItem(image: newinventoryImage, style: .plain, target: self, action: #selector(goToNewInventoryScreen))
        navigationItem.rightBarButtonItem = newInventoryButton
        self.notificationToken = inventories?.observe { changes in
            switch changes {
                case .initial: break
                    // Results are now populated and can be accessed without blocking the UI
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed.
                    print("Deleted indices: ", deletions)
                    print("Inserted indices: ", insertions)
                    print("Modified modifications: ", modifications)
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inventoriesTableView.reloadData()
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
    }

    func goToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
}

extension InventoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inventories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let inventoryCell = tableView.dequeueReusableCell(withIdentifier: "inventoryTableViewCell") as? InventoryTableViewCell else { return UITableViewCell() }
        inventoryCell.inventoryName.text = self.inventories?[indexPath.row].name
        return inventoryCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let inventoryDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "InventoryDetailsViewController") as? InventoryDetailsViewController, let inventory = self.inventories?[indexPath.row] else { return }
        inventoryDetailsViewController.inventory = inventory
        
        self.navigationController?.pushViewController(inventoryDetailsViewController, animated: true)
    }
}
