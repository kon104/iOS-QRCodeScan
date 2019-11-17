//
//  ScanViewController.swift
//  QRCodeScan
//
//  Created by kon104 on 2019/11/10.
//  Copyright © 2019 kon104. All rights reserved.
//

import AVFoundation
import UIKit

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        log(1, #function)
        super.viewDidLoad()

        setupScan()
        putCloseButton()

        log(2, #function)
    }

    func setupScan() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .back)
        let devices = discoverySession.devices

        // Set up to scan
        if let backCamera = devices.first {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    let metadataOutput = AVCaptureMetadataOutput()
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
                        
                        // Create a layer to show the back camera view
                        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        self.previewLayer?.frame = self.view.bounds
                        self.previewLayer?.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(self.previewLayer!)

                        // Start to scan
                        self.session.startRunning()
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }

    func putCloseButton() {
        // Add the close button
        let closeBtn:UIButton = UIButton()
        closeBtn.setTitle("Close", for: UIControl.State.normal)
        closeBtn.frame = CGRect(x: 10, y: 10, width: 60, height: 25)
        closeBtn.backgroundColor = UIColor.lightGray
        closeBtn.layer.cornerRadius = 7.0
        closeBtn.addTarget(self, action: #selector(closeTaped(sender:)), for: .touchUpInside)
        self.view.addSubview(closeBtn)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        log(1, #function)

        log(0, String(metadataObjects.count))

        let preVC = self.presentingViewController as! ViewController
        preVC.aryTypes = []
        preVC.aryValues = []

        if (metadataObjects is [AVMetadataFaceObject])
        {
            // It isn't still going well to show detection about face.
            for metadata in metadataObjects as! [AVMetadataFaceObject] {
                let bounds = metadata.bounds
                var face = CGRect()
                face.origin.x = bounds.origin.y * self.view.bounds.width
                face.origin.y = bounds.origin.x * self.view.bounds.height
                face.size.width = bounds.size.width * self.view.bounds.height
                face.size.height = bounds.size.height * self.view.bounds.width

                let detectionView = addDetectionView()
                detectionView.frame = face

                let ctype = metadata.type
                preVC.aryTypes.append(ctype)
                preVC.aryValues.append(NSCoder.string(for: bounds))
            }
        } else
//        if (metadataObjects is [AVMetadataMachineReadableCodeObject])
        {
            for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {

                // Draw a point where a code is detected.
                let barCode = self.previewLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                let detectionView = addDetectionView()
                detectionView.frame = barCode.bounds
                
                let ctype = metadata.type
                var cvalue = metadata.stringValue
                if (cvalue == nil) {
                    cvalue = "{null}"
                }
                preVC.aryTypes.append(ctype)
                preVC.aryValues.append(cvalue!)
            }
        }

        self.session.stopRunning()

        preVC.tblDetactions.reloadData()
        preVC.tblDetactions.selectRow(at: IndexPath(row:0, section: 0), animated: false, scrollPosition: .none)
        preVC.activeTableRow(0)

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.dismiss(animated: true, completion: nil)
        }
        print("[End]" + #function)
    }
    
    func addDetectionView() -> UIView {
        let view = UIView()
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.red.cgColor
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.view.addSubview(view)
        return view
    }
    
    @objc func closeTaped(sender: UIButton) {
        log(1, #function)
        self.dismiss(animated: true, completion: nil)
        log(2, #function)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func log(_ mode: Int, _ msg: String) {
        var tag: String = ""
        if (mode == 1) {
            tag = "[Start]"
        } else if (mode == 2) {
            tag = "[End]"
        }
        print(tag + msg)
    }

}
