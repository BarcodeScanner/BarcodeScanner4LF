import UIKit
import SQFeedbackGenerator
import AVFoundation

class BarcodeReaderViewController: CameraBarcodeReaderViewController {
    static func getBarcodeReaderViewController() -> BarcodeReaderViewController? {
        if let barcodeReaderVC = UIViewController.getScreen(name: "BarcodeReaderViewControllerID", fromStoryboard: "Main") as? BarcodeReaderViewController {
            return barcodeReaderVC
        }
        return nil
    }
    // MARK: - Instance Properties -
    var closeAfterFirstRead: Bool = true
    var lastScannedEntry: String?
    var scannedEntries = [String]()
    
    var barcodeScannedSuccessMessage: String?
    var barcodeScannedDuplicateMessage: String?
    var shouldReturn = true
    @Published var scannedBarcode: String?
    
    @IBAction func didPressTorchButton(_ sender: UIButton) {
        let isTorchOn = self.toggleTorch()
        let torchButtonImage = isTorchOn ? UIImage(named: "forms-barcode-torch-off") : UIImage(named: "forms-barcode-torch-on")
        self.torchButton.setImage(torchButtonImage, for: .normal)
    }
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
            self.playSoundNamed("new_barcode_read")
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

extension UIViewController {
    func playSoundNamed(_ soundName: String) {
        var soundID: SystemSoundID = 0
        let soundNameCFString = soundName as CFString
        let soundFileExtension = "caf" as CFString
        if let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), soundNameCFString, soundFileExtension, nil) {
            AudioServicesCreateSystemSoundID(soundURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    static func getScreen(name: String, fromStoryboard storyboardName: String) -> UIViewController {
        // Get the storyboard
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        // Instantiate the required ViewController
        let viewController = storyboard.instantiateViewController(withIdentifier: name)
        // Return it
        return viewController
    }
    
    func presentModalViewController(_ viewController: UIViewController, isFullScreen: Bool = false, showNavigationBar: Bool = true) {
        // Embed self in a new navigation controller
        let navController = UINavigationController(rootViewController: viewController)
        // Set the navigation bar visibility
        navController.setNavigationBarHidden(!showNavigationBar, animated: false)
        // Set the modal presentation style to fullScreen if required
        if isFullScreen {
            navController.modalPresentationStyle = .fullScreen
        }
        // Set the modal transition style
        navController.modalTransitionStyle = .coverVertical
        // Present the new navigation controller
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
}
