//
//  CanvasView.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/23.
//

import UIKit

final class CanvasView: UIView {

    private var lines = [[CGPoint]]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { line in
            for (i, p) in line.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
        }
          
//        for (i, p) in points.enumerated() {
//            if i == 0 {
//                context.move(to: p)
//            } else {
//                context.addLine(to: p)
//            }
//        }
          
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(5)
        context.setLineCap(.round)
        context.strokePath()
//        context.
        
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        //MARK: - touches in CanvasView, not nil
        guard let point = touches.first?.location(in: self),
              var line = lines.popLast()
        else { return }
        
        line.append(point)
        lines.append(line)
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lines = []
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        postNotification(with: lines)
        self.lines = []
    }
}

extension CanvasView {
    private func postNotification(with lines: [[CGPoint]]) {
        NotificationCenter.default
            .post(
                name: .add,
                object: self,
                userInfo: [NotificationKey.shapeObject: lines]
            )
    }
}
