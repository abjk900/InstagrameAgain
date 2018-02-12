//
//  Comment.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/27/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import Foundation

struct Comment {
    
//    var user : User?
    let user : User
    
    let text : String
    let uid : String
    
    init(user : User ,dictionary : [String : Any]) {
        
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
