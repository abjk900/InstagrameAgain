//
//  HomeController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/15/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        //cell
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        //navigation title
        setupNavigationItems()
        
        //refreshingControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        //fetch all of posts
        fetchAllPosts()
        
        //AddPhoto 에서 변경된 것을 가져온다(텔레비젼)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: NSNotification.Name(rawValue: "UpdateFeed"), object: nil)
        
    }
    
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh")
        //it goes to remove "unfollow" post
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        print("Handling refresh")
        //fetch currently user posts
        fetchPosts()
        //fetch following user posts
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
            //왜 여기다 할까? post 를 add 한 다음에 하지 않고. 이유는 이미 처음에 한번 fetchAllPosts() 를 했고 refresing 으로 한번 더 돌려서 fetchAllPosts() 할 때 reloadDate 후에 한다면 한번 더 중복되서 붙여진다. 여기서 멈춰야 중복되서 붙여지지 않는다.
            self.collectionView?.refreshControl?.endRefreshing()
            //bring
            guard let dictionaries = snapshot.value as? [String : Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else {return}
                
                var post = Post(user: user, dictionary: dictionary)
                //post 마다의 고유 코드 를 post 안에 id 로 넣어준다.
                post.id = key
                
                //save at "Post" file
                self.posts.append(post)
            })
            
            //posts 라는 array 의 안에있는 값들을 비교하는것.
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            
            //****여기서 멈추면 포스트가 한번씩 중복해서 더 붙여진다.****
//          self.collectionView?.refreshControl?.endRefreshing()
            
        }) { (err) in
            print("Failed to fetch posts", err)
        }
        
    }
    
    //Navigation title
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        print("Showing camera")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
        
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
        
        //err solve when post.removeall and clush err
        
        if indexPath.item < posts.count - 1 {
            cell.post = posts[indexPath.item]
        }
        
        cell.delegate = self //?
        
        return cell
    }
    
    func didTapComment(post : Post){
        print("Message coming from HomeController")
        print(post.caption)
        print(post.id)
        let commentsController = CommentController(collectionViewLayout: UICollectionViewLayout())
        commentsController.post = post //본 페이지 에서 데이터를 Post에 보내줘도 본 페이지와 그 다음 페이지와 연결을 안해주면 데이터가 흘러가지 않는다.
        navigationController?.pushViewController(commentsController, animated: true)
        
    }
    
}
