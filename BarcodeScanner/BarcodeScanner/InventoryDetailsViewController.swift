import UIKit
import Combine
import RealmSwift

class InventoryDetailsViewController: UIViewController {

    @IBOutlet weak var productsInInventory: UITableView!
    @IBOutlet weak var totalCountOfProducts: UILabel!
    @IBAction func didTouchReportInventory(_ sender: UIButton) {
        self.goToReports()
    }
    
    var inventory: Inventory?
    private var cancellables = Set<AnyCancellable>()
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.productsInInventory.dataSource = self
        self.productsInInventory.delegate = self
        
        let newinventoryImage = UIImage(systemName: "plus")
        let newInventoryButton = UIBarButtonItem(image: newinventoryImage, style: .plain, target: self, action: #selector(goToAddProductsToInventory))
        navigationItem.rightBarButtonItem = newInventoryButton
        
        self.navigationItem.title = self.inventory?.name
    }
    
    func updateTotalCount() {
        let totalCount = self.inventory?.products.reduce(into: 0) { count, result in
            count += result.quantity
        }
        self.totalCountOfProducts.text = "Total scanned products: \(totalCount ?? 0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationToken = self.inventory?.products.observe { changes in
            switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    self.updateTotalCount()
                case .update(_, _,  let insertions, let modifications):
                    // Query results have changed.
                if !insertions.isEmpty {
                    self.productsInInventory.reloadData()
                }
                if !modifications.isEmpty {
                    self.updateTotalCount()
                }
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
        }
    }
    
    @objc func goToAddProductsToInventory() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let barcode = ApplicationManager.shared.realm?.objects(Product.self).randomElement()?.barcode
            self.didReadBarcodeWithValue(barcode)
            return }
        if let readerVC = BarcodeReaderViewController.getBarcodeReaderViewController() {
            readerVC.closeAfterFirstRead = true
            readerVC.$scannedBarcode.sink { scanned in
                self.didReadBarcodeWithValue(scanned)
            }.store(in: &self.cancellables)
            self.presentModalViewController(readerVC)
        }
    }
    
    func didReadBarcodeWithValue(_ stringValue: String?) {
        guard let stringValue = stringValue else { return }
        guard let realm = ApplicationManager.shared.realm else { return }
        guard let dbProduct = ApplicationManager.shared.realm?.objects(Product.self).first(where: { print($0.barcode)
            return $0.barcode == stringValue }) else {
            noBarcodeFounded()
            return }
        do {
            
            try realm.write {
                if let product = self.inventory?.products.first(where: { $0.barcode == stringValue } ) {
                    product.quantity += 1
                } else {
                    let product = Product(name: dbProduct.name, barcode: dbProduct.barcode, price: dbProduct.price, quantity: 1)
                    self.inventory?.products.append(product)
                }
            }
          } catch {
              print(error.localizedDescription)
          }
      }
      @objc func goToReports() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let newInventoryScreenViewController = storyboard.instantiateViewController(withIdentifier: "BarChartViewController") as? BarChartViewController else { return }
        newInventoryScreenViewController.inventory = self.inventory
        self.navigationController?.pushViewController(newInventoryScreenViewController, animated: true)
    }
    
    func noBarcodeFounded() {
        let alert = UIAlertController(title: nil, message: "Unregistered product", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}


extension InventoryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inventory?.products.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductInInventoryTableViewCell") as? ProductInInventoryTableViewCell, let inventory = self.inventory else { return UITableViewCell() }
        let product = inventory.products[indexPath.row]
        productCell.productName.text = product.name
        return productCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let productDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScannedProductDetailsViewController") as? ScannedProductDetailsViewController, let inventory = self.inventory else { return }
        let product = inventory.products[indexPath.row]
        productDetailsViewController.product = product
        
        self.navigationController?.pushViewController(productDetailsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                guard let product = self.inventory?.products[indexPath.row] else { return }
                ApplicationManager.shared.realm?.beginWrite()
                ApplicationManager.shared.realm?.delete(product)
                try ApplicationManager.shared.realm?.commitWrite()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
