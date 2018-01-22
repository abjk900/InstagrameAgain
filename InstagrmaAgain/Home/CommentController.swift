//
//  CummonController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/11/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post : Post?
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .red
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        cell.backgroundColor = .yellow
        
        return cell
    }
    
        // 스와이프로 밑에레이블로 가다가 반쯤 가서 다시 놓았을때 다시 상태바가 생기는.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }
        // 다음 뷰로 넘어갔을 때 행동되는 일.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
    }
    
   lazy var containerView : UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 12, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return containerView
    }()
    
    let commentTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    
    @objc func handleSubmit() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        print("post id:", self.post?.id ?? "")
        
        print("Inserting comment", commentTextField.text ?? "")
        
        let postId = self.post?.id ?? ""
        // 댓글, 댓글날짜, 댓글남긴 사람의 유아이디
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid" : uid] as [String : Any]
        
        //"users/(FIRAuth.auth()!.currentUser!.u‌​id)/userBio"
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed to insert comment", err)
                return
            }
            
            print("Successfully inserted comment.")
        }
        
    }
    
    //뷰가 넘어올 때 이곳의 뷰를 먼저 반응시켜줌
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    //뷰가 넘어올 때 이곳으로 처음으로 반응시켜줌
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    
}
