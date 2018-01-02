//
//  FirebaseUtils.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/22/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    static func fetchUserWithUID(uid : String, completion : @escaping (User) -> ()){
            print("Fatcing user with uid", uid)
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let userDictionary = snapshot.value as? [String : Any] else {return}
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            //뭔지는 모르지만 반드시 해줘야한다.
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts", err)
        }
    
}
    
}
