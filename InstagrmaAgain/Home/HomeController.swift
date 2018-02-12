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
        //it goes to remove "unfollow" post 1.posts의 어레이를 전부 지워주고 fetchAllPosts로 posts의 어레이를 재생산
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
            //데이타베이스에서 유아디 안까지 접근해서 팔로우 한 유아이디 와 벨류 를 저장할 딕셔너리 벨류를 선언
            guard let userIdsDictionary = snapshot.value as? [String : Any] else {return}
            //딕셔너리벨류에 루프로 하나씩 넣음
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
    
   fileprivate func fetchPostsWithUser(user : User) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            //왜 여기다 할까? post 를 add 한 다음에 하지 않고. 이유는 이미 처음에 한번 fetchAllPosts() 를 했고 refresing 으로 한번 더 돌려서 fetchAllPosts() 할 때 reloadDate 후에 한다면 한번 더 중복되서 붙여진다. 여기서 멈춰야 중복되서 붙여지지 않는다.
            self.collectionView?.refreshControl?.endRefreshing()
            //bring
            guard let dictionaries = snapshot.value as? [String : Any] else {return}
            //key = postId, value post values
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String : Any] else {return}
                
                var post = Post(user: user, dictionary: dictionary)
                //post 마다의 고유 코드 를 post 안에 id 로 넣어준다.
                post.id = key
                //포스트에 유저값, 포스트아이디, 유저아이디 값 모두 입력되어 있음 추가만 하면 되는 상태
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    //posts 라는 array 의 안에있는 값들을 비교하는것.
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()
                    
                    //****여기서 멈추면 포스트가 한번씩 중복해서 더 붙여진다.****
                    //          self.collectionView?.refreshControl?.endRefreshing()
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post", err)
                })
            })
            
            
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
        let commentsController = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post //본 페이지 에서 데이터를 Post에 보내줘도 본 페이지와 그 다음 페이지와 연결을 안해주면 데이터가 흘러가지 않는다.
        navigationController?.pushViewController(commentsController, animated: true)
        
    }
    
    func didLike(for cell: HomePostCell) {
        print("handling like inside of controller")
        
        //어느 포스트(cell)을 눌렀나
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        //해당 indexPath(cell)의 포스트 정보
        var post = self.posts[indexPath.item]
        print(post.caption)
        
        guard let postId = post.id else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //해당 cell 의 포스트의 hasLiked == true(=1) 이면 0으로 변경, 0 이면 1로 변경
        let value = [uid : post.hasLiked == true ? 0 : 1]
        
        //한개의 포스트에 여러유저가 좋아요 버튼을 누를 수 있다 : 하나의 postid  <- 여러 유저의 유아이디
        //해당 cell 의 포스트의 hasLiked == true(=1) 이면 0으로 변경, 0 이면 1로 변경되는 값으 데이터 베이스에 업데이트
        Database.database().reference().child("likes").child(postId).updateChildValues(value) { (err, _) in
            if let err = err {
                print("faile to upload user likes")
            }
            
            print("Suceesfully uploaded user likes")
            
            //post.hasLiked = false 에서 변경된 값으로 !post.hasLiked 으로 다시 넣어주는 것
            post.hasLiked = !post.hasLiked
            //posts 중에 해당 indexPath.item 을 = 수정된 indexPath.item으로 바꿔준다.
            self.posts[indexPath.item] = post
            //리로드 indexPath
            self.collectionView?.reloadItems(at: [indexPath])
            
        }
        
    }

    
}
