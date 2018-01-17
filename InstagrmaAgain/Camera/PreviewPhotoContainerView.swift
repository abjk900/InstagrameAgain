//
//  PreviewPhotoContainerView.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/9/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    let saveButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave() {
        print("Handling save..")
        
        guard let previewImage = previewImageView.image else {return}
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            
            //요청한 이미지에 대한 정보를 요청하고 포토라이블러리에 저장
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library", err)
                return
            }
            
            print("Sucessfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                //CATransform3DMakeScale 라벨이 통 통 튀어서 나오는 라벨의 애니메이션
                    //(1)처음 라벨이 팡하고 튀어나올때
                savedLabel.layer.transform = CATransform3DMakeScale(20, 10, 0)
                //처음 애니메이션
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    //(2)라벨이 처음부터 라벨의 사각박스가 화면에 안정적이게 보여질때까지의 애니메이션, 위의 시간만큼.
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    //끝나고 나서 애니메이션
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        //(3) 끝나고 사라질때 까지 애니메이션, 위의 시간만큼
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        
                    })
                })
                
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 24, paddingLeft: 24, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
