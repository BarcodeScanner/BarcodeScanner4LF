import UIKit
import Combine

class FirstScreenViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var scanBarcode: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTouchScanBarcode(_ sender: UIButton) {
        if let readerVC = BarcodeReaderViewController.getBarcodeReaderViewController() {
            readerVC.closeAfterFirstRead = true
    }
}
