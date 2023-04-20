import UIKit
import RealmSwift
import Combine
import SwiftUI

class FirstScreenViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var scanBarcode: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let stringValue = stringValue else { return }
        guard let existingProduct = ApplicationManager.shared.realm?.objects(Product.self).first(where: { print($0.barcode)
            return $0.barcode == stringValue }) else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let manageProductViewController = storyboard.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
            manageProductViewController.productModel = Product(name: "", barcode: stringValue, quantity: 0)
            self.navigationController?.pushViewController(manageProductViewController, animated: true)
            return
        }
        guard let manageProductViewController = self.storyboard?.instantiateViewController(withIdentifier: "ManageProductViewController") as? ManageProductViewController else { return }
        manageProductViewController.productModel = existingProduct
        self.navigationController?.pushViewController(manageProductViewController, animated: true)
        
        
    }
}
