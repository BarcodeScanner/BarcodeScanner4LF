import UIKit
import SQFeedbackGenerator
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
        self.updateNrOfScannedBarcodesLabel()
                
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
    func handle(_ barcodeValue: String) {
        if !self.scannedEntries.contains(barcodeValue) {
            self.hasScannedNewBarcodeWithValue(barcodeValue)
        } else if self.lastScannedEntry != barcodeValue {
            self.hasScannedDuplicateBarcodeWithValue(barcodeValue)
        }
    }
    
    // MARK: - Instance methods -
    
    func hasScannedNewBarcodeWithValue(_ barcodeValue: String) {
        self.scannedEntries.append(barcodeValue)
        self.lastScannedEntry = barcodeValue
        
        DispatchQueue.main.async {
            SQFeedbackGenerator().generateFeedback(type: .notification)
            self.updateNrOfScannedBarcodesLabel()
        }
    }
    
    func hasScannedDuplicateBarcodeWithValue(_ barcodeValue: String) {
        self.lastScannedEntry = barcodeValue
        
        DispatchQueue.main.async {
            SQFeedbackGenerator().generateFeedback(type: .error)
        }
    }
    func updateNrOfScannedBarcodesLabel() {
        
        let nrOfEntries = self.scannedEntries.count
        var nrOfScannedBarcodesText = ""
        
        if nrOfEntries == 1 {
            nrOfScannedBarcodesText = NSLocalizedString("dvbarcodereaderviewcontroller.one_barcode_scanned", tableName: nil, bundle: Bundle.main, value: "1 Barcode Scanned", comment: "1 Barcode Scanned")
        } else {
            let strFormat = NSLocalizedString("dvbarcodereaderviewcontroller.multiple_barcodes_scanned_format", tableName: nil, bundle: Bundle.main, value: "%d Barcodes Scanned", comment: "{nr_of_barcodes} Barcodes Scanned")
            nrOfScannedBarcodesText = String.localizedStringWithFormat(strFormat, self.scannedEntries.count)
        }
        self.numberOfScannedBarcodesLabel.text = nrOfScannedBarcodesText
    }
}
