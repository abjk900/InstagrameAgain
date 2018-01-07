//
//  CameraController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/7/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    
    let dismissButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCapturePhoto() {
        print("Captureing photo")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //must be first layer then add the buttons otherwise the buttons were hided.
        setupCaptureSession()
        //buttons
        setupHUD()
        
    }
    
    fileprivate func setupHUD() {
        
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        //1. setup inputs
            //accessing to take picture
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
                print("Succesfully input something.")
            }
        }
            
        catch let err {
            print("Could not setup camera input:", err)
        }
        
        //2. setup outpurs
            //output in photo?
        let output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }

        //3. setup output preview
            //connecting output with capture session
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            //size
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
            //it is kind of pipe to connect between output and capturesession
        captureSession.startRunning()
    }
    
}
