import UIKit
import RealmSwift
import Combine

class FirstScreenViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var scanBarcode: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTouchScanBarcode(_ sender: UIButton) {
        if let readerVC = BarcodeReaderViewController.getBarcodeReaderViewController() {
            readerVC.closeAfterFirstRead = true
        }
    }
    
    func didReadBarcodeWithValue(_ stringValue: String?) {
        guard let stringValue = stringValue else { return }
        do {
            
            let realm = try Realm()
            let products = realm.objects(Product.self)
            let productsByBarcode = products.where { $0.barcode == stringValue }
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
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
