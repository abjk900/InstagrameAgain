//
//  UserProfilePhotoCell.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/11/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class UserProfilePhotoCell : UICollectionViewCell {
    
    /*
     1. 외부 공정 클래스 파일을 만든다. (CustomImageView)
     최종 나오는 파일이 이미지라면 이미지 동영사이라면 동영상인.
     */
    var post : Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else {return}
            /*
             3. 셀 프로젝트 안에 유알엘 소스를 받는 변수 안에서, 공정클래스 타입으로 되어있는 변수를 불러와 공정소스(유알엘) 을 넣어준다.
             */
            photoImageView.loadImage(urlString: imageUrl)
        }
    }
    
    /*
     2. 공정클래스를 셀안에 보여줄 뷰의 변수의 타입으로 지정한다(그 이미지가 이미 그 변수안에 위치된다.)
     */
    let photoImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
