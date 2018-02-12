//
//  Post.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/11/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import Foundation

struct Post {
    
    var id : String?
    var hasLiked : Bool
    
    let imageUrl : String
    let caption : String
    let user : User
    let creationDate : Date
    
    init(user : User, dictionary : [String : Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.user = user
        self.hasLiked = false
        
        let secondFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondFrom1970)
    }
}
