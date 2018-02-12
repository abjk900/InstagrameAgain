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
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        //밖에 클릭하면 키보드 없어지는
        collectionView?.keyboardDismissMode = .interactive
        
        
        // 이 두개는, 커멘트를 입력학 창과 겹치지 않기위해 노란 컨테이너뷰와, 서브미트 공간을 띄어주고, 스클롤해도 겹치지 않게 스크롤뷰 사이즈를 조절한것 같은데, 업데이트 되면서 자동으로 되는듯 함.
//        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComment()
        
    }
    
    var comments = [Comment]()
    
    fileprivate func fetchComment() {
        guard let postId = self.post?.id else {return}
        
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            print(snapshot.value)
            
            guard let dictionary = snapshot.value as? [String : Any] else {return}
            
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                
                let userComment = Comment(user: user, dictionary: dictionary)
                self.comments.append(userComment)
                self.collectionView?.reloadData()
                
            })
            
        }) { (err) in
            print("Fetch comment is err")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //AutoLayOut of comment cell size
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        //Lays out the subviews immediately, if layout updates are pending.
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        //Returns the size of the view that satisfies the constraints it holds.
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        //x ~ y 의 범위 사이즈?
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        
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
    
    //=============ContainerView========================
    
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
    
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
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
