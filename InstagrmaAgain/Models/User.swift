//
//  User.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/16/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import Foundation

//structure is automatically made available for other code to use
struct User {
    let uid : String
    let username : String
    let profileImageUrl : String
    
    init(uid : String, dictionary : [String : Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
