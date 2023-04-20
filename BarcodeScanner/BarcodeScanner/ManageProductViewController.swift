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
        self.barcode.text = "Barcode: \(product.barcode)"
        self.productName.text = product.name
        self.quantityTextField.text = "\(product.quantity)"
    }

    @IBAction func didTouchAddToDatabase(_ sender: UIButton) {
        guard let product = productModel else { return }
       
        if product.name.isEmpty {
            self.add()
        } else {
            self.update()
        }
      
    }
    
    func add() {
        guard let product = productModel, let realm = ApplicationManager.shared.realm else { return }
        self.refresh()
        do {
            try realm.write {
                realm.add(product)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func update() {
        guard let product = productModel, let realm = ApplicationManager.shared.realm else { return }
        do {
            try realm.write {
                product.name = self.productName.text ?? ""
                product.quantity = Int(self.quantityTextField.text ?? "1") ?? 0
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func refresh() {
        productModel?.quantity = Int(self.quantityTextField.text ?? "1") ?? 0
        productModel?.name = self.productName.text ?? ""
        productModel?.owner_id = app.currentUser?.id ?? ""
    }
}

extension ManageProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
