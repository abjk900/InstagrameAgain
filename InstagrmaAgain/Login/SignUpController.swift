//
//  SignUpController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/2/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var plusPhotoButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //예상, 수정된이미지, 원본이미지 두 번 다 클릭해서 사진이 바뀌어야 함으로 그냥 임의로 이프문과 이프엘스 문을 만들면 컴퓨터는 0,1 값등으로 받아드리므로 두 경우에 대해서 허용한다. 가독성 때문에 이렇게 이름을 정해 놓은듯 하다.
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && usernameTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }
    
    let signUpButton : UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        button.isEnabled = false
        return button
    }()
    
    
    @objc func handleSignUp() {
        
        //Making ID using blow things. // guard let is helping maintain clarity in view controllers
        guard let email = emailTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
    
        Auth.auth().createUser(withEmail: email, password: password) { (user, error : Error?) in
            
            if let err = error {
                print("Failed to create user", err)
                return
            }
            
            print("Successfully created user", user?.uid ?? "")
            
            //Saving datas in Db storage
            
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else {return}
            
            let filename = NSUUID().uuidString
            
            Storage.storage().reference().child("profileImage").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err{
                    print("Failed to upload profile image", err)
                    return
                }
                
                guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {return}
                
                print("Successfully uploaded profile image", profileImageUrl)
                
                //Saving informathing that typed when user signup in db
                
                guard let uid = user?.uid else {return}
                
                let dictuonaryValues = ["username" : username, "email" : email, "profileImageUrl" : profileImageUrl]
                
                let values = [uid : dictuonaryValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if let err = err {
                        print("Failed to save user info into db", err)
                        return
                    }
                    
                    print("Successfully saved user info to db")
                    
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTapBarController else {return}
                    
                    mainTabBarController.setUpViewController()
                    
                    self.dismiss(animated: true, completion: nil)
                })
            })
            
        }
    }
    
    let alreadyHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Login", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlredayHaveAccount), for: .touchUpInside)
        
        
        return button
    }()
    
    @objc func handleAlredayHaveAccount() {
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }

    
}
