//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit



class PhotoPageContainerViewController: UIViewController, UIGestureRecognizerDelegate,
UITableViewDelegate, UITableViewDataSource {

    var photos: [UIImage]!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }
	
	

    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.tableView.isScrollEnabled = false
            self.transitionController.isInteractive = true
            let _ = self.navigationController?.popViewController(animated: true)
        case .ended:
            if self.transitionController.isInteractive {
                self.tableView.isScrollEnabled = true
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
	
	
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y < -100, !transitionController.isInteractive {
			self.transitionController.isInteractive = false
			self.tableView.isScrollEnabled = false
			_ = self.navigationController?.popViewController(animated: true)
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
	}
	
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.imageView?.image = photos[indexPath.row]
		return cell
	}
}



extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
    
    func referenceView(for zoomAnimator: ZoomAnimator) -> UIView? {
        return self.view
    }
    
    func getFromCellFrame(for zoomAnimator: ZoomAnimator) -> CGRect? {
		return self.view.frame
    }
}
