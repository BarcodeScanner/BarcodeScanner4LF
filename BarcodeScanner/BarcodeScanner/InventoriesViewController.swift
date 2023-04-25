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
                if !deletions.isEmpty {
                    print("Deleted indices: ", deletions)
                    self.inventoriesTableView.deleteRows(at: deletions.compactMap { IndexPath(row: $0, section: 0) } , with: .fade)
                }
                if !insertions.isEmpty {
                    print("Inserted indices: ", insertions)
                    self.inventoriesTableView.reloadData()
                }
                print("Modified modifications: ", modifications)
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
        }
    }
    
    @objc func didTouchLogOut() {
        guard let user = ApplicationManager.shared.user else { return }
        Task.init {
            do {
                try await user.logOut()
                print("Successfully logged user out")
                logoutAlert()
            } catch {
                print("Failed to log user out: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func didChangeShowInventories(_ sender: UISwitch) {
        Task {
            await self.loadInventories()
        }
    }
    
    private func loadInventories() async {
        guard let subscriptions = ApplicationManager.shared.realm?.subscriptions, let user = ApplicationManager.shared.user else { return }
        
        try? await subscriptions.update {
            if !showMyTaskSwitch.isOn {
                if subscriptions.first(named: Constants.my_inventories) != nil {
                    subscriptions.remove(named: Constants.my_inventories)
                }
                if subscriptions.first(named: Constants.allInventories) == nil {
                    subscriptions.append(QuerySubscription<Inventory>(name: Constants.allInventories))
                }
            } else {
                if subscriptions.first(named: Constants.allInventories) != nil {
                    subscriptions.remove(named: Constants.allInventories)
                }
                if subscriptions.first(named: Constants.my_inventories) == nil {
                    subscriptions.append(QuerySubscription<Inventory>(name: Constants.my_inventories) {
                        $0.owner_id == user.id
                    })
                }
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
    
    func logoutAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            self.goToLoginScreen()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
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
        tableView.deselectRow(at: indexPath, animated: false)
        guard let inventoryDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "InventoryDetailsViewController") as? InventoryDetailsViewController, let inventory = self.inventories?[indexPath.row] else { return }
        inventoryDetailsViewController.inventory = inventory
        
        self.navigationController?.pushViewController(inventoryDetailsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                guard let inventory = self.inventories?[indexPath.row] else { return }
                ApplicationManager.shared.realm?.beginWrite()
                ApplicationManager.shared.realm?.delete(inventory)
                try ApplicationManager.shared.realm?.commitWrite()
               
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
