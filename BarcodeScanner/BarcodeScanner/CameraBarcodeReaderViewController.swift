import UIKit
import AVFoundation
import Vision

class CameraBarcodeReaderViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()

    private let captureSession = AVCaptureSession()
    private let sequenceHandler = VNSequenceRequestHandler()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let device = AVCaptureDevice.default(for: .video)
    var barcodeHandler: ((String) -> Void)?

    @IBOutlet weak var cameraPreview: UIView!

    @IBOutlet weak var torchSwitch: UIButton!
    
    @IBAction func didTouchDone(_ sender: UIButton) {

    }
    
    @objc open func hasTorch() -> Bool {
        if let device = self.device {
            return device.hasTorch
        }
        return false
    }

    @discardableResult
    @objc open func toggleTorch() -> Bool {
        if self.hasTorch() {
            self.captureSession.beginConfiguration()
            if let device = self.device {
                do {
                    try device.lockForConfiguration()
                } catch _ {}

                if device.torchMode == .off {
                    device.torchMode = .on
                } else if device.torchMode == .on {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
                self.captureSession.commitConfiguration()

                return device.torchMode == .on
            }
        }
        return false
    }

    private func addCameraInput() {
        guard let device = self.device,
        let cameraInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.captureSession.addInput(cameraInput)
    }

    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        if let barcode = self.extractQRCode(fromFrame: frame) {
            print("did extract barcode \(barcode)")
            self.barcodeHandler?(barcode)
        }
    }

    private func extractQRCode(fromFrame frame: CVImageBuffer) -> String? {
        let barcodeRequest = VNDetectBarcodesRequest()
        try? self.sequenceHandler.perform([barcodeRequest], on: frame)
        guard let results = barcodeRequest.results, let firstBarcode = results.first?.payloadStringValue else {
            return nil
        }
        return firstBarcode
    }

    // MARK: - Aplication livecycle -
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = self.view.bounds
        self.previewLayer.frame = frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.view.layer.insertSublayer(self.previewLayer, at: 0)
        self.addVideoOutput()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.captureSession.stopRunning()
    }

    @objc func onApplicationWillEnterForeground() {
        self.captureSession.startRunning()
    }

    @objc func onApplicationDidEnterBackground() {
        self.captureSession.stopRunning()
    }
}
