//
//  ScannedProductDetailsViewController.swift
//  BarcodeScanner
//
//  Created by Crina Ciobotaru on 22.04.2023.
//

import UIKit

class ScannedProductDetailsViewController: UIViewController {
    var product: Product?
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var barcode: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let product = product else { return }
        self.productName.text = product.name
        self.barcode.text = product.barcode
        self.quantity.text = "\(product.quantity)"
    }
}
