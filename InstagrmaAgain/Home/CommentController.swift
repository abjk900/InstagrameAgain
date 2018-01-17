//
//  CummonController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/11/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class CommentController: UICollectionViewController {
    
    override func viewDidLoad() {
         super.viewDidLoad()

        collectionView?.backgroundColor = .red

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
    
    var containerView : UIView = {
        
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
        
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        
        containerView.addSubview(textField)
        textField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return containerView
        
    }()
    
    //뷰가 넘어올 때 이곳의 뷰를 먼저 반응시켜줌
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    @objc func handleSubmit() {
        print("Handling Submit")
    }
    
    //뷰가 넘어올 때 이곳으로 처음으로 반응시켜줌
    override var canBecomeFirstResponder: Bool{
        return true
    }

    
    
}
