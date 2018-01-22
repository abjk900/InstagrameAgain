//
//  CommentCell.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/22/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

