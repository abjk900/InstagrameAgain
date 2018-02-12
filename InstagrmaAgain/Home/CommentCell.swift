//
//  CommentCell.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/22/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment : Comment? {
        didSet{
            guard let comment = comment else {return}
            
//            guard let profileImageUrl = comment.user.profileImageUrl else {return}
//
//            guard let username = comment.user?.username else {return}
            
            let attributedText = NSMutableAttributedString(string: comment.user.username
                , attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
            
//            textLabel.text = comment.text
            textView.attributedText = attributedText
            
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
        
    }
    
    let textView : UITextView = {
       let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 0
//        label.backgroundColor = .lightGray
        //disable to scroll down and up
        textView.isScrollEnabled = false
        return textView
    }()
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        return iv
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
//        backgroundColor = .yellow
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width:0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

