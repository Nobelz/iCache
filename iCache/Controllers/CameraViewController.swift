//
//  CameraViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/12/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import AVFoundation
import UIKit
import Firebase

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var geocache: Geocache?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func found(code: String) {
        if code == geocache?.id {
            let usersRef = db.collection("users")
            
            usersRef.whereField("email", isEqualTo: Auth.auth().currentUser!.email!)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print(error)
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let log = data["log"] as? String {
                                let logs = Log.parseLog(log: log)
                                
                                if Log.checkGeocache(geocache: self.geocache!, logs: logs) {
                                    let geocachesFound = data["geocachesFound"] as! Int
                                    
                                    let newLog = Log.addGeocacheToLog(log: log, geocache: self.geocache!, isSuccess: true)
                                    let ref = self.db.collection("users").document(document.documentID)
                                    ref.updateData([
                                        "log": newLog,
                                        "geocachesFound": geocachesFound + 1
                                    ])
                                    
                                    let alertController = UIAlertController(title: "Success!", message: "Geocache successfully logged!", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    
                                    self.present(alertController, animated: true)
                                } else {
                                    let alertController = UIAlertController(title: "Geocache already logged today", message: "Please try again tomorrow!", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    
                                    self.present(alertController, animated: true)
                                }
                            } else {
                                let geocachesFound = data["geocachesFound"] as! Int
                                
                                let newLog = Log.addGeocacheToLog(log: nil, geocache: self.geocache!, isSuccess: true)
                                let ref = self.db.collection("users").document(document.documentID)
                                ref.updateData([
                                    "log": newLog,
                                    "geocachesFound": geocachesFound + 1
                                ])
                                
                                let alertController = UIAlertController(title: "Success!", message: "Geocache successfully logged!", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                
                                self.present(alertController, animated: true)
                            }
                        }
                    }
            }
        } else {
            let alertController = UIAlertController(title: "Incorrect Code", message: "Please scan the code on the geocache.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                self.captureSession.startRunning()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alertAction) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            present(alertController, animated: true)
        }
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
