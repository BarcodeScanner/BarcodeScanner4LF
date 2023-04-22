//
//  PleaseWaitViewController.swift
//  BarcodeScanner
//
//  Created by Crina Ciobotaru on 22.04.2023.
//

import UIKit
import RealmSwift

class PleaseWaitViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.continueApp()
    }
    
    private func continueApp() {
        Task {
            guard let user = app.currentUser else { return }
            do {
                try await self.goToInventoriesScreen(with: user)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func goToInventoriesScreen(with user: User) async throws  {
        ApplicationManager.shared.realm = try await ApplicationManager.shared.openFlexibleSyncRealm(for: user)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "InventoriesViewController") as? InventoriesViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
    
}
