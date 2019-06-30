//
//  ZoomAnimator.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol ZoomAnimatorDelegate: class {
    func referenceView(for zoomAnimator: ZoomAnimator) -> UIView?
    func getFromCellFrame(for zoomAnimator: ZoomAnimator) -> CGRect?
}

class ZoomAnimator: NSObject {
    
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?

    var transitionImageView: UIView?
	var transitionView: UIView?
    var isPresenting: Bool = true
    
    fileprivate func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageViewFrame = self.fromDelegate?.getFromCellFrame(for: self)
            else {
                return
        }
        
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
		
		if self.transitionView == nil {
			let transitionView = UIView(frame: fromReferenceImageViewFrame)
			self.transitionView = transitionView
			containerView.addSubview(transitionView)
		}
		
		UIView.animate(
				withDuration: transitionDuration(using: transitionContext),
				delay: 0,
				usingSpringWithDamping: 0.8,
				initialSpringVelocity: 0,
				options: [UIView.AnimationOptions.transitionCrossDissolve],
				animations: {
			self.transitionView?.frame = UIScreen.main.bounds
			self.transitionView?.backgroundColor = UIColor.green
			toVC.view.alpha = 1.0
		}, completion: { completed in
			self.transitionView?.removeFromSuperview()
			self.transitionView = nil
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
    }
    
	fileprivate func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		
		guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
			let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
			let fromReferenceImageView = self.fromDelegate?.referenceView(for: self),
			let toReferenceImageView = self.toDelegate?.referenceView(for: self),
			let toReferenceImageViewFrame = self.toDelegate?.getFromCellFrame(for: self)
			else {
				return
		}
		
		toReferenceImageView.isHidden = true
		
		if self.transitionView == nil {
			let transitionView = UIView()
			transitionView.backgroundColor = .brown
			transitionView.clipsToBounds = true
			transitionView.frame = UIScreen.main.bounds
			self.transitionView = transitionView
			containerView.addSubview(transitionView)
		}
		
		containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
		fromReferenceImageView.isHidden = true
		
		let finalTransitionSize = toReferenceImageViewFrame
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext),
					   delay: 0,
					   options: [],
					   animations: {
						fromVC.view.alpha = 0
			self.transitionView?.frame = finalTransitionSize
			toVC.tabBarController?.tabBar.alpha = 1
		}, completion: { completed in
			
			self.transitionView?.removeFromSuperview()
			toReferenceImageView.isHidden = false
			fromReferenceImageView.isHidden = false
			
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
    
    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)
        
        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}

extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return 0.5
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
