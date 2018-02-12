//
//  PhotoSelectorController.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 12/6/17.
//  Copyright © 2017 Jae Ki LeeJae. All rights reserved.
//

import UIKit
import Photos

//UICollectionViewDelegateFlowLayout : for making size of cell
class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        //header
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        //cell
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        
        //NavigationBar
        setupNavigationButtons()
        
        //Fetching Photos
        fetchPhotos()
    }
    
    
    // Fetch Photos from cellPhone photolibrary
    var selectedImage : UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]() //need "import Photos"
    
    fileprivate func assetFetchOption() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
//        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        //사진들
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOption())
         
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects {(asset, count, stop) in
                print(count)
                
                //예상컨데, 핸드폰에서 사진이 패치가 안되는것은 여기서 고치면 될 듯 함.
                
                //bringing image
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        //adding images
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        //when selectedImage is nill than the first image going to be "selectedImage"
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    //beacus computer count from 0
                    if count == allPhotos.count - 1  {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                    
                })
            }
        }
        
    }
    
    //Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4 //"-3" 을 빼준 이유는 셀이 4개 한줄로 꽉차게 만드는데 셀 간의 간격을 1씩 띄어주어야 하므로 미리 3 의 간격을 빼준다.
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    /*
     3. var selectedImage : UIImage? 저장된 이미지 들을 셀에 뿌려준다.
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]
        
        return cell
    }

    // Inseting spacing between header section and cell section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    /*
     4. 셀에서 클릭한 이미지를 선택된 이미지로 설정해준다
     - 여기서 "var selectedImage"  에 사진이 저장됨
     */
    //Image that clicked in cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.selectedImage = images[indexPath.item]
        self.collectionView?.reloadData()
        //after click the photo scroll go to up
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    // header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    //1.*header 를 밖으로 뽑아준다
    var header : PhotoSelectorHeader?

    /*
     5. var selectedImage 에 저장된 이미지를 header 에 뿌려준다.
     */
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        //1-1 상위 header와 펑션 안의 header 를 같게 만들어주고
        self.header = header
        //1-2 펑션안의 header 의 이미지를 선택한 이미지와 같게 하면, 이 이미지는 자동으로 상위의 header파일에도 저장이된다.
        header.photoImageView.image = self.selectedImage
        
        //bring image and image assets and then makeing it fitly in header imageView
        if let selectedImage = self.selectedImage {
            if let index = self.images.index(of: selectedImage){
                let selectedAsset = self.assets[index]

                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                //image 를 불러오는것
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in

                    header.photoImageView.image = image

                })
            }
        }
        
        
        return header
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //NavigationBar
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    /*
     6. header 에 뿌려진 이미지를 그 다음 뷰로 넘겨준다.
     */
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
