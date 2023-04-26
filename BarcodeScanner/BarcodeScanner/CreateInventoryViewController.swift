import UIKit

class CreateInventoryViewController: UIViewController {

    @IBOutlet weak var inventoryName: UITextField!
    
    @IBAction func didTouchCreate(_ sender: UIButton) {
        guard let name = self.inventoryName.text,
              let realm = ApplicationManager.shared.realm else {
            return
        }
        if name.isEmpty {
            self.missingInventoryName()
            return
        }
        let inventory = Inventory(name: name)
        do {
            try realm.write {
                realm.add(inventory)
            }
            self.inventoryCreated()
            
        } catch let error {
            print(error.localizedDescription)
        }

    }
    
    @IBAction func didTouchCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func missingInventoryName() {
        let alert = UIAlertController(title: nil, message: "Please, add a name for Inventory", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func inventoryCreated() {
        let alert = UIAlertController(title: nil, message: "Inventory was created", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {_ in
            self.navigationController?.popViewController(animated: true)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
