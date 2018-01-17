//
//  UserProfileHeader.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/4/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

//*2. 가져온 정보를 이곳에서 다시 가져와 작동시켜준다.
import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    //didSet을 해주면 값이 갱신될 때 마다 업데이트 시켜준다. 여기서는, user 안의 imageUrl 이 바뀔때마다 갱신해 주어 그걸 타고가서 imageUrl이 image 화 되도록 도와주는 것이다.
    var user : User?{
        didSet {
        // "userId" 의 새로운 "uid" 에서 유저 정보가 넘어오면 서치 뷰에서 넘어온것
    
            //image
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            //userName
            usernameLabel.text = user?.username
    
            setupEditFollowButton()
            
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        //UserProfileController 에서 userId 로 넘어온 것은 searchView에서 넘어 온 uid
        guard let userId = user?.uid else {return}
        
        if currentLoggedInUserId == userId{
            //edit Profile
        } else {
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                //2.if snapshot.value == 1 은 정수가 안된다니까 이런식으로 다시 써줘야함. value == 1 이라는 건 follow 했다는것 그래서 재클릭시 unfollow 로 넘어가게
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    //isFollowing == 1 이라는 건 이미 팔로우 했다는 것 이므로, 그다음 선택지는 Unfollow
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    //그 밖에는 unfollow 아니면
                    //아마도 한 두겹까지는 self 를 안붙여도 되는데 너무 그 이하의 부분에서 사용하려면 self 를 붙여줘야하나?
                    self.setupFollowStyle()
                }
                
                
            }, withCancel: { (err) in
                print("Failed to check if following", err)
            })
            
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    
    let gridButton : UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel : UILabel = {
       let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel : UILabel = {
       let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "20\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followerLabel : UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel : UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    //why use the lazy bar?
    lazy var editProfileFollowButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile /follow / unfollow logic")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        
        guard let userId = user?.uid else {return}
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow"{
            //unfollow //언팔되어있다는것 -> 이미팔로우했다는것 -> 언팔버튼을누른다는것 -> 데이타베이스에서 팔로우한유저를 지운다는것.
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user", err)
                    return
                }
                
                print("Successfully unfollowed user:", self.user?.username ?? "")
                
                self.setupFollowStyle()
            })
            
        } else {
            //follow //팔로우버튼이 있다는것 -> 팔로우를 안했다는것 -> 팔로우버튼을 누른다는것 -> 데이타베이스에 팔로우 유저를 넣는다는것.
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            let value = [userId : 1]
            ref.updateChildValues(value) {(err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                
                print("Successfully followed user", self.user?.username ?? "")
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setupBottomToolbar()
        
        setupUserStackView()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUserStackView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followerLabel, followingLabel])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDivederView = UIView()
        bottomDivederView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(topDividerView)
        addSubview(stackView)
        addSubview(bottomDivederView)
        
        topDividerView.anchor(top: nil, left: leftAnchor, bottom: stackView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        bottomDivederView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
}
