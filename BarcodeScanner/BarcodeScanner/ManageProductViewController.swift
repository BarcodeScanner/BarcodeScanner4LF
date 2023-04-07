import UIKit
import RealmSwift

class ManageProductViewController: UIViewController {
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var barcode: UILabel!
    
    var productModel: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productName.delegate = self
        quantityTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let product = productModel else { return }
        self.barcode.text = product.barcode
        self.productName.text = product.name
        self.quantityTextField.text = "\(product.quantity)"
    }

    @IBAction func didTouchAddToDatabase(_ sender: UIButton) {

    }
}

extension ManageProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}