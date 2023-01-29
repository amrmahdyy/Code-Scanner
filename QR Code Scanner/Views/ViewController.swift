//
//  ViewController.swift
//  QR Code Scanner
//
//  Created by amrmahdy on 30/12/2022.
//

import UIKit
import Vision
import AVFoundation
class ViewController: UIViewController {
    //    MARK: Private Properties
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var photoOutput: AVCapturePhotoOutput?
    private var session: AVCaptureSession?
    private var device: AVCaptureDevice?
    private var torchStatus : Bool = false {
        didSet {
            if torchStatus {
                torchButton.setImage(UIImage(systemName: "flashlight.on.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .bold, scale: .large)), for: .normal)
            } else {
                torchButton.setImage(UIImage(systemName: "flashlight.off.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .bold, scale: .large)), for: .normal)
            }
        }
    }
    
    private lazy var snapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 5
       return button
    }()

    private lazy var torchButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "flashlight.off.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36, weight: .bold, scale: .large)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(toggleTorch(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var historyButton: UIButton = {
       let button = UIButton()
       let configuration = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        button.transform  = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        button.addTarget(self, action: #selector(openScannedCodes(_:)), for: .touchUpInside)
        return button
    }()
    // Create a barcode detection-request
    let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
        
        guard let results = request.results else { return }
        print(results.count)
        // Loopm through the found results
        for result in results {
            
            // Cast the result to a barcode-observation
            if let barcode = result as? VNBarcodeObservation {
                
                // Print barcode-values
                print("Symbology: \(barcode.symbology.rawValue)")
                print(barcode.payloadStringValue!)
                
//                if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
//                    let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
//
//                    // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
//                    print("Payload: \(String(describing: content))")
//                    print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
//                    print("Symbol-Version: \(desc.symbolVersion)")
//                }
            }
        }
    })
    @objc private func takePhoto(_ sender: Any) {
        guard let photoOutput = photoOutput else { return }
        print("Photo pressed")
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        makeVibration(with: .light)
    }
    @objc private func shutDown() {
        torchStatus = false
    }
    private func instanciateVC(data: ScannedCodesViewModel?)-> ScannedCodesViewController {
        let scannedCodesVC = ScannedCodesViewController()
        scannedCodesVC.modalPresentationStyle = .automatic
        scannedCodesVC.newScannedCode = data
        return scannedCodesVC
    }
    @objc private func openScannedCodes(_ sender: Any) {
        makeVibration(with: .soft)
       
        present(instanciateVC(data: nil), animated: true)
    }
//    MARK: View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        self.device = device
        snapButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(shutDown), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    private func setupCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    print("Authorized1")
                }
            }
            return
        case .restricted:
            return
        case .denied:
            return
        case .authorized:
            DispatchQueue.global().async {
                self.makeDeviceCameraConnection()
            }
            print("Authorized")
        @unknown default:
            fatalError()
        }
    }
    
    private func setupUI() {
        previewLayer.frame = view.bounds
        previewLayer.backgroundColor = UIColor.systemRed.cgColor
        view.layer.addSublayer(previewLayer)
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.spacing = 16
        sv.alignment = .center
        view.addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            sv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        sv.addArrangedSubview(torchButton)
        sv.addArrangedSubview(snapButton)
        sv.addArrangedSubview(historyButton)
        let constant = 70.0
        snapButton.widthAnchor.constraint(equalToConstant: constant).isActive = true
        snapButton.heightAnchor.constraint(equalToConstant: constant).isActive = true
        snapButton.layer.cornerRadius = snapButton.frame.width / 2
    }
    
    @objc func toggleTorch(_ sender: Any) {
        torchStatus.toggle()
        configureTorch(with: torchStatus)
        makeVibration(with: .medium)
    }
    private func makeVibration(with style : UIImpactFeedbackGenerator.FeedbackStyle ) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    private func configureTorch(with status: Bool) {
        guard let device = device else { return }
        if device.isTorchModeSupported(.on), device.hasTorch {
            do {
                try device.lockForConfiguration()
                if status {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    func makeDeviceCameraConnection() {
        let avCaptureSession = AVCaptureSession()
        avCaptureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: device!) else { return print("ERROR INPUT") }
        if avCaptureSession.canAddInput(cameraInput) {
            avCaptureSession.addInput(cameraInput)
        }
        let photoOutput = AVCapturePhotoOutput()
        
        guard avCaptureSession.canAddOutput(photoOutput) else { return print("CANNOT ADD OUTPUT")}
        avCaptureSession.addOutput(photoOutput)
        
        previewLayer.session = avCaptureSession
        previewLayer.videoGravity = .resizeAspectFill
        
        self.photoOutput = photoOutput
        self.session = avCaptureSession
        avCaptureSession.commitConfiguration()
        avCaptureSession.startRunning()
        
    }
    
    private func showAlert() {
        let alertVC = UIAlertController(title: "", message: "No code found, please try to scan another code", preferredStyle: .alert)
        let alert =  UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(alert)
        present(alertVC, animated: true)
    }
    func requestHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNBarcodeObservation], results.count > 0 else { DispatchQueue.main.async {
            self.showAlert();
        }; return }
        print(results.count)
        makeVibration(with: .rigid)
        guard let firstResult = results.first else {  return }
        DispatchQueue.main.async {
            let vc = self.instanciateVC(data: ScannedCodesViewModel(information: firstResult.payloadStringValue!, date: ""))
            self.present(vc, animated: true)
        }
    }
    func qrCodeScanRequest(with image: UIImage) {
        guard let image = image.cgImage else { return }
        let vnImageRequest = VNImageRequestHandler(cgImage: image, options: [:])
        barcodeRequest.revision = VNDetectBarcodesRequestRevision1
        let request: VNDetectBarcodesRequest = {
            let request = VNDetectBarcodesRequest(completionHandler: requestHandler)
            request.symbologies = [.qr, .codabar, .aztec, .upce]
            request.revision = VNDetectBarcodesRequestRevision1
            return request
        }()
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try vnImageRequest.perform([request])
            } catch {
                print(error, "Error")
            }

        }
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("Image captured")
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
       qrCodeScanRequest(with: image)
    }
}
