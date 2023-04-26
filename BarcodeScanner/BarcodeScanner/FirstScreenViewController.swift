import UIKit
import RealmSwift
import Combine
import SwiftUI

class FirstScreenViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var scanBarcode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logOutBarButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(didTouchLogOut))
        navigationItem.leftBarButtonItem = logOutBarButton
    }
    
    @IBAction func didTouchScanBarcode(_ sender: UIButton) {
        if let readerVC = BarcodeReaderViewController.getBarcodeReaderViewController() {
            readerVC.closeAfterFirstRead = true
            readerVC.$scannedBarcode.sink { scanned in
                self.didReadBarcodeWithValue(scanned)
            }.store(in: &self.cancellables)
            self.presentModalViewController(readerVC)
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
    
    func logoutAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            self.goToLoginScreen()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func goToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let inventoriesScreenViewController = storyboard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController else { return }
        
        self.navigationController?.setViewControllers([inventoriesScreenViewController], animated: true)
    }
}

extension FirstScreenViewController {
    
    func didReadBarcodeWithValue(_ stringValue: String?) {
        guard let stringValue = stringValue else { return }
        guard let existingProduct = ApplicationManager.shared.realm?.objects(Product.self).first(where: { print($0.barcode)
            return $0.barcode == stringValue }) else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let manageProductViewController = storyboard.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
            manageProductViewController.productModel = Product(name: "", barcode: stringValue, price: "", quantity: 0)
            self.navigationController?.pushViewController(manageProductViewController, animated: true)
            return
        }
        guard let manageProductViewController = self.storyboard?.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
        manageProductViewController.productModel = existingProduct
        self.navigationController?.pushViewController(manageProductViewController, animated: true)
        
        
    }
}
