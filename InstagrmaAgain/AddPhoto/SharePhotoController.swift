//
//  SharePhotoController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/11/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import Foundation
import Firebase

class SharePhotoController: UIViewController {
    
    //getthing selecteImage
    var selectedImage : UIImage?{
        didSet{
            self.thumbImageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let thumbImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(thumbImageView)
        thumbImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: thumbImageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleShare() {
        guard let caption = textView.text, caption.characters.count > 0 else {return}
        guard let image = selectedImage else {return}

        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            
            //need to use downloadURL for sharing pictures at Db
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
            
            print("Succesfully uploade post image:", imageUrl)
            
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
        
    }
    
    //the imageUrl is the downloadUrl already
    fileprivate func saveToDatabaseWithImageUrl(imageUrl : String) {
        guard let postImage = selectedImage else {return}
        guard let caption = textView.text else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl":imageUrl, "caption": caption, "imageWidth":postImage.size.width, "imageHeight":postImage.size.height, "creationDate":Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image", err)
                return
            }
            
            print("Suceesfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            //변경된 사항을 보내준다(방송국) - HomeConetoller와 연결되어 있다.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateFeed"), object: nil)
        }
    }
    
}
