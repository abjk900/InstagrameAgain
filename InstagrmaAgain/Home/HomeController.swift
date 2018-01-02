//
//  HomeController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/15/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        //cell
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        //navigation title
        setupNavigationItems()
        
        //bring "post"
        fetchPosts()
        
        //fetchfollowUserspost
        fetchFollowingUserIds()
        
        
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String : Any] else {return}
            
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following user ids:",err)
        }
    }
    
    var posts = [Post]()
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //User
        //it goes to save user data which with specific uid at "User" file
        Database.fetchUserWithUID(uid: uid) {(user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    func fetchPostsWithUser(user : User) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            //bring
            guard let dictionaries = snapshot.value as? [String : Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else {return}
                
                let post = Post(user: user, dictionary: dictionary)
                //save at "Post" file
                self.posts.append(post)
            })
            
            //posts 라는 array 의 안에있는 값들을 비교하는것.
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch posts", err)
        }
    }
    
    //Navigation title
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    //Cell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 40 + 8 + 8 // userName and Profilepicture
        height += view.frame.width //photo
        height += 50 // icons
        height += 60 // Username and caption and postTime
        height += 20 // userProfileImage view extending
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
}
