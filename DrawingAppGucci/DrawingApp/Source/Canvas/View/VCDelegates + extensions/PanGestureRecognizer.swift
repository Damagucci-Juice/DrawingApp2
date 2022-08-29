//
//  PanGestureRecognizer.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/29.
//

import UIKit

class PanGestureRecognizer: NSObject, UIGestureRecognizerDelegate {
    
    var delegate: CanvasViewController?
    
    //MARK: - 뷰가 생성될 때마다 아래 panGesture가 생성되어 타겟 뷰의 gesture recognizer 로 추가
    func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        
        targetView.addGestureRecognizer(panGesture)
    }
    
    //MARK: - view를 드래깅 하는 GestureRecognizer
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        guard let drawableView = sender.view as? Drawable,
              let currentView = sender.view,
              let vc = delegate
        else { return }
        
        switch sender.state {
        case .began:
            fallthrough
        case .changed:
            sender.view?.alpha = CGFloat(vc.plane?[drawableView.index].alpha.value ?? 0 / 2)
            vc.updatePropertiesLabels(with: currentView)
        case .ended:
            guard let changedOrigin = sender.view?.frame.origin else { return }
            let movedPoint = Point(x: changedOrigin.x, y: changedOrigin.y)
            vc.plane?.renewCenterOfShape(at: drawableView.index, after: movedPoint)
            sender.view?.alpha = CGFloat(vc.plane?[drawableView.index].alpha.value ?? 0)
            vc.updatePropertiesLabels(with: currentView)
        default:
            break
        }
        
        let transition = sender.translation(in: vc.view)
        sender.view?.center.x += transition.x
        sender.view?.center.y += transition.y
        
        sender.setTranslation(.zero, in: vc.view)
    }
}
