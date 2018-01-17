//
//  File.swift
//  InstagrmaAgain
//
//  Created by Jae Ki Lee on 1/9/18.
//  Copyright © 2018 Jae Ki LeeJae. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //my custom transition animation code logic
        
        //애니메이션의 대상이되는 뷰
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        guard let toView = transitionContext.view(forKey: .to) else {return}
        
        containerView.addSubview(toView)
        
        //x, y 는 애니메이션이 시작되는 어느 포인트
        let startingFrame = CGRect(x: 0, y: toView.frame.height, width: toView.frame.width, height: toView.frame.height)
        //toView 가 애니메이션처럼 작동하는데 위와 같은 포인터에서 출발한다.
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //animation 이 작동한 후에 나타나지는 것들
            
                //이 펑션 전에 이미 toView에 관한 값을 주어 주지 않아도 된다.
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
                //animation이 작동하면서, fromView 는 +y 방향으로 사라진다.
            fromView.frame = CGRect(x: 0, y: fromView.frame.height, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
