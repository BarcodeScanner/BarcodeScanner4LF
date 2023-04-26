import UIKit
import RealmSwift

class ManageProductViewController: UIViewController {
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var barcode: UILabel!
    
    var productModel: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productName.delegate = self
        productPrice.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let product = productModel else { return }
        self.barcode.text = "Barcode: \(product.barcode)"
        self.productName.text = product.name
        self.productPrice.text = product.price
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
                self.addToDatabase()
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
                product.price = self.productPrice.text ?? ""
               // product.price = Int(self.quantityTextField.text ?? "1") ?? 0
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func refresh() {
        // productModel?.quantity = Int(self.quantityTextField.text ?? "1") ?? 0
        productModel?.price = self.productPrice.text ?? ""
        productModel?.name = self.productName.text ?? ""
        productModel?.owner_id = app.currentUser?.id ?? ""
    }
    
    func addToDatabase() {
        let alert = UIAlertController(title: nil, message: "The product was added", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
            self.goToFirstScreen()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func goToFirstScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let firstScreenViewController = storyboard.instantiateViewController(withIdentifier: "FirstScreenViewController") as? FirstScreenViewController else { return }
        
        self.navigationController?.setViewControllers([firstScreenViewController], animated: true)
    }
}

extension ManageProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.productName {
            self.productPrice.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
