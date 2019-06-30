//
//  ViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [UIImage]!
    
    var selectedIndexPath: IndexPath!
    
    //These variables are used to hold any updates to the safeAreaInsets
    //that might not have been propagated to this ViewController. This is required
    //for supporting devices running on >= iOS 11. These will be set manually from
    //PhotoZoomViewController.swift to ensure any changes to the safeAreaInsets
    //after the device rotates are pushed to this ViewController. This is required
    //to ensure the collectionView.convert() function calculates the proper
    //frame result inside referenceImageViewFrameInTransitioningView()
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photos = [
            #imageLiteral(resourceName: "1"),
            #imageLiteral(resourceName: "2"),
            #imageLiteral(resourceName: "3"),
            #imageLiteral(resourceName: "4"),
            #imageLiteral(resourceName: "5"),
            #imageLiteral(resourceName: "6"),
            #imageLiteral(resourceName: "7"),
            #imageLiteral(resourceName: "8"),
            #imageLiteral(resourceName: "9"),
            #imageLiteral(resourceName: "10"),
            #imageLiteral(resourceName: "11"),
            #imageLiteral(resourceName: "12"),
            #imageLiteral(resourceName: "13"),
            #imageLiteral(resourceName: "14"),
            #imageLiteral(resourceName: "15"),
            #imageLiteral(resourceName: "16"),
            #imageLiteral(resourceName: "17"),
            #imageLiteral(resourceName: "18"),
            #imageLiteral(resourceName: "1"),
            #imageLiteral(resourceName: "2"),
            #imageLiteral(resourceName: "3"),
            #imageLiteral(resourceName: "4"),
            #imageLiteral(resourceName: "5"),
            #imageLiteral(resourceName: "6"),
            #imageLiteral(resourceName: "7"),
            #imageLiteral(resourceName: "8"),
            #imageLiteral(resourceName: "9"),
            #imageLiteral(resourceName: "10"),
            #imageLiteral(resourceName: "11"),
            #imageLiteral(resourceName: "12"),
            #imageLiteral(resourceName: "13"),
            #imageLiteral(resourceName: "14"),
            #imageLiteral(resourceName: "15"),
            #imageLiteral(resourceName: "16"),
            #imageLiteral(resourceName: "17"),
            #imageLiteral(resourceName: "18")
        ]
        
        //Manually set the collectionView frame to the size of the view bounds
        //(this is required to support iOS 10 devices and earlier)
        self.collectionView.frame = self.view.bounds
    }



    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11, *) {
            self.currentLeftSafeAreaInset = self.view.safeAreaInsets.left
            self.currentRightSafeAreaInset = self.view.safeAreaInsets.right
        }
        
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = self.navigationController
            let vc = segue.destination as! PhotoPageContainerViewController
            nav?.delegate = vc.transitionController
            vc.transitionController.fromDelegate = self
            vc.transitionController.toDelegate = vc
            vc.photos = self.photos
        }
	}
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PhotoCollectionViewCell.self)", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = self.photos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
		guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath)
			as? PhotoCollectionViewCell else {
			return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX,
											 y: UIScreen.main.bounds.midY,
											 width: 100.0,
											 height: 100.0))
		}
		return guardedCell.imageView
    }

    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
		guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
			return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
		}
		return guardedCell.frame
    }
}



extension ViewController: ZoomAnimatorDelegate {
    
    func referenceView(for zoomAnimator: ZoomAnimator) -> UIView? {
		let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
		return referenceImageView
    }
	
	
	
    func getFromCellFrame(for zoomAnimator: ZoomAnimator) -> CGRect? {
        self.view.layoutIfNeeded()
        self.collectionView.layoutIfNeeded()
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        return self.collectionView.convert(unconvertedFrame, to: self.view)
    }
}
