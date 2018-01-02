//
//  CustomImageView.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/12/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage : String?
    
    func loadImage(urlString : String) {
        print("Loading image...")
        
        lastURLUsedToLoadImage = urlString
        
        //string url -> URL 로 변환
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            
            //URL 로 변환한 urlString != urlString 이 맞지 않는다면 멈춘다??
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            //date 받아옴
            guard let imageData = data else {return}
            //date 를 Image로 변경
            let photoImage = UIImage(data: imageData)
            //image 나열
            DispatchQueue.main.async {
                self.image = photoImage
            }
            
            }.resume()
    }
}
