import UIKit
import AVFoundation

class BarcodeReaderViewController: CameraBarcodeReaderViewController {
    // MARK: - Instance Properties -
    var closeAfterFirstRead: Bool = true
    var lastScannedEntry: String?
    var scannedEntries = [String]()
    
    var barcodeScannedSuccessMessage: String?
    var barcodeScannedDuplicateMessage: String?
    var shouldReturn = true
    @Published var scannedBarcode: String?
    
    // MARK: - IBoutlets -
    
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var numberOfScannedBarcodesLabel: UILabel!
    
    // MARK: - Application Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.barcodeScannedSuccessMessage = "Barcode Scanned"
        self.barcodeScannedDuplicateMessage = "Duplicate Barcode"
        
        // self.focusMarkLayer.strokeColor = UIColor.yellow.cgColor
        self.torchButton.isHidden = !self.hasTorch()
                
        self.barcodeHandler = { barcodeValue in
            
            if self.closeAfterFirstRead && self.shouldReturn {
                self.shouldReturn = false
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.scannedBarcode = barcodeValue
                    }
                }
            }
            
        }
    }
}
