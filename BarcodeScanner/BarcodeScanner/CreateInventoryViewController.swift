import UIKit

class CreateInventoryViewController: UIViewController {

    @IBOutlet weak var inventoryName: UITextField!
    
    @IBAction func didTouchCreate(_ sender: UIButton) {
        guard let name = self.inventoryName.text,
              let realm = ApplicationManager.shared.realm else {
            // TODO: add message handling for case name is missing
            return
        }
        let inventory = Inventory(name: name)
        do {
            try realm.write {
                realm.add(inventory)
                self.navigationController?.popViewController(animated: true)
            }
            // TODO: add message for succes
            
        } catch let error {
            print(error.localizedDescription)
        }

    }
    
    @IBAction func didTouchCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
