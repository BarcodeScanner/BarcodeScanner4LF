import UIKit
import RealmSwift
import Combine
import SwiftUI

class FirstScreenViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var scanBarcode: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let config = ApplicationManager.shared.realmConfiguration else { return }
        Realm.asyncOpen(configuration: config) { result in
            switch result {
            case .success(let realm):
                ApplicationManager.shared.realm = realm
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
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
}

extension FirstScreenViewController {
    
    func didReadBarcodeWithValue(_ stringValue: String?) {
        guard let stringValue = stringValue, let realm = ApplicationManager.shared.realm else { return }
        let products = realm.objects(Product.self)
        let productsByBarcode = products.where {
            print($0.barcode)
            return $0.barcode == stringValue
        }
        if productsByBarcode.isEmpty {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let manageProductViewController = storyboard.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
            manageProductViewController.productModel = Product(name: "", barcode: stringValue, quantity: 0)
            self.navigationController?.pushViewController(manageProductViewController, animated: true)
            
        } else {
            guard let product = productsByBarcode.first, let manageProductViewController = self.storyboard?.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
            manageProductViewController.productModel = product
            self.navigationController?.pushViewController(manageProductViewController, animated: true)
        }
  
    }
}
