//
//  CameraController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/7/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    //AVCapturePhotoCaptureDelegate receiving results from a photo capture output.
    
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
    
    //capturing photo
    @objc func handleCapturePhoto() {
        print("Captureing photo")
        
        let setting = AVCapturePhotoSettings()
        //phto type
        guard let previewFormatType = setting.availablePreviewPhotoPixelFormatTypes.first else {return}
        //setting photo type
        setting.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        //output 에출력 되어있는 사진을 세팅값으로
        output.capturePhoto(with: setting, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for animation
        transitioningDelegate = self
        
        //must be first layer then add the buttons otherwise the buttons were hided.
        setupCaptureSession()
        
        //buttons
        setupHUD()
        
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationDismisser
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    fileprivate func setupHUD() {
        
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }
    
    
    //jpeg 파일로 capture file 제공해주는?
    //아마도 캡쳐포토 액션 다음에?
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        //output 에서 나오는 이미지
        let imageDate = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        
        //프리뷰에 저장
        let previewImage = UIImage(data: imageDate!)
        //지금 컨트롤러의 뷰
        let containerView = PreviewPhotoContainerView()
        //컨트롤러 안에 이미지뷰 에 저장
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
//        //프리뷰 이미지 뷰에 보여줌
//        let previewImageView = UIImageView(image: previewImage)
//        view.addSubview(previewImageView)
//        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        print("Finish processing photo sample buffer..")
    }
    
    let output = AVCapturePhotoOutput()
    
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
        
        //2. setup outputs
            //output in photo
//        let output = AVCapturePhotoOutput()
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
