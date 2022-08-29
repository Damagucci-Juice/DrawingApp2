//
//  MoveCellExtension.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/16.
//

import UIKit

//MARK: - 길게 눌러서 한칸 셀을 움직이는 메서드
extension CanvasViewController {
    func moveViewBackward(with index: Int) {
        guard index > 0 else { return }
        let preView = shapeFrameViews[index - 1]
        shapeFrameViews[index - 1] = shapeFrameViews[index]
        shapeFrameViews[index] = preView
    }
    
    func moveViewForeward(with index: Int) {
        guard index < shapeFrameViews.count - 1 else { return }
        let postView = shapeFrameViews[index + 1]
        shapeFrameViews[index + 1] = shapeFrameViews[index]
        shapeFrameViews[index] = postView
    }
    
    func moveViewAndModel(to direction: Direction, index: Int) {
        var index = index
        switch direction {
        case .backward:
            self.plane?.moveBackward(with: index)
            self.moveViewBackward(with: index)
        case .backmost:
            self.plane?.moveBackmost(with: index)
            while index > 0 {
                self.moveViewBackward(with: index)
                index -= 1
            }
        case .forward:
            self.plane?.moveForward(with: index)
            self.moveViewForeward(with: index)
        case .foremost:
            self.plane?.moveForemost(with: index)
            while index < shapeFrameViews.count - 1 {
                moveViewForeward(with: index)
                index += 1
            }
        }
    }
}
