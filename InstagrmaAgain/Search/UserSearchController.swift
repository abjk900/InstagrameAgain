//
//  UserSearchController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/21/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    lazy var searchBar : UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray
        sb.delegate = self
        sb.autocapitalizationType = .none
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return sb
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        let navBar = navigationController?.navigationBar
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
    
    //when text something in searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            filterdUsers = self.users
        } else {
            filterdUsers = self.users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }

        self.collectionView?.reloadData()
    }
    
    //showing after moving
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    //after selecting cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        //indexPath.item(item 이 콕 찝어주는것 같다.)
        let user = filterdUsers[indexPath.item]
        print(user.username)
        
        //when click the userprofile cell then it goes to userprofile that you clicked
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        //1. searchigViewCell 에서 선택된 user.uid 를 ProfileController의 userId 에 저장시킨다.
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    
    var filterdUsers = [User]()
    var users = [User]()
    
    fileprivate func fetchUsers() {
        //데이터 베이스에 유저까지 접근 그 안에 유아이디 값들이 나열 되어 있음
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            //나열되어 있는 유아디 값들을 저장할 변수를 선언
            guard let dictionaires = snapshot.value as? [String : Any] else {return}
            //딕셔너리 변수에, key = uids, value = 애니타입으로 딕셔너리로 되어있는 값들을 저장
            dictionaires.forEach({ (key, value) in
                
                if key == Auth.auth().currentUser?.uid{
                    print("Found myself, omit from list")
                    return
                }
                //각 유아이디 안에 있는 키와 벨류를 저장하기 위해 딕셔너리로 변수를 선언
                guard let userDictionary = value as? [String : Any] else {return}
                
                let user = User(uid: key, dictionary: userDictionary)
                
                self.users.append(user)
                
            })
            
            //arranging username in order to alpabet
            self.users.sort(by: { (u1, u2) -> Bool in
                //Ascending 오름차순
                return u1.username.compare(u2.username) == .orderedAscending
                
            })
            //user를 오름차순으로 정리 한 후 filteredUsers 에 저장.
            //Arragnged username be filtedUsers
            self.filterdUsers = self.users
            self.collectionView?.reloadData()
            
        }) {(err) in
            print("Failed to fetch users for search", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterdUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = filterdUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}
