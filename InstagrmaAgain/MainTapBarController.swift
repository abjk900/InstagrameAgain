//
//  MainTapBarController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/3/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Firebase

class MainTapBarController: UITabBarController, UITabBarControllerDelegate {
    
    //it is in the UITabBarControllerDelegate
    //for connecting "AddPhoto group"
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let photSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photSelectorController)
            
            present(navController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate 은 무언가를 클릭후 그것이 작동하게 도와줄때 그것이 뭔가에 연결되 있을 때 작동시켜주고 반드시 delegate 를 불러와 주어야한다.
        self.delegate = self

        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setUpViewController()
    }
    
    func setUpViewController() {
        
        //home
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        
        //user profile
        /*Navgation 순서
         1. 다음으로 이동할 컨트롤러를 선언한다.
         2. 네비게이션컨트롤러를 선언하고 그 안에 루트뷰에 1.에 선언한 컨트롤러를 입력한다.
        */
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let userProfilenavController = UINavigationController(rootViewController: userProfileController)
        
        userProfilenavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfilenavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        //UITabBarController class. it is navigationBar in bottom
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfilenavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }

    fileprivate func templateNavController(unselectedImage : UIImage, selectedImage : UIImage, rootViewController : UIViewController = UIViewController()) -> UINavigationController{
        
//        let viewController = rootViewController
        //굳이 viewController 를 안만들고 rootViewcontroller 를 연결해주는게 더 간편하지 않을까..
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
        
    }



}

