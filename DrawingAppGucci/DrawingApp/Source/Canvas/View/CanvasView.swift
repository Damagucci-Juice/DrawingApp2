//
//  CanvasView.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/23.
//

import UIKit

final class CanvasView: UIView {

    private var lines = [[CGPoint]]()
    private var isCanDrawing: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let aPath = UIBezierPath()
        lines.forEach { line in
            for (i, p) in line.enumerated() {
                if i == 0 {
                    aPath.move(to: p)
                } else {
                    aPath.addLine(to: p)
                }
            }
        }

        addGraphicSubLayer(aPath.cgPath)
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCanDrawing {
            lines.append([CGPoint]())
        }
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
        self.layer.sublayers?.forEach({ layer in
            if case let shapeLayer as CAShapeLayer = layer {
                shapeLayer.removeFromSuperlayer()
            }
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstLine = lines.first else { return }

        if isCanDrawing && !firstLine.isEmpty {
            postNotification(with: lines)
        }
        self.lines = []
        self.layer.sublayers?.forEach({ layer in
            if case let shapeLayer as CAShapeLayer = layer {
                shapeLayer.removeFromSuperlayer()
            }
        })
    }
}

extension CanvasView {
    private func postNotification(with lines: [[CGPoint]]) {
        guard let line = lines.first else { return }
        NotificationCenter.default
            .post(
                name: .add,
                object: self,
                userInfo: [NotificationKey.shapeObject: line]
            )
    }
    
    func enableDrawing() {
        self.isCanDrawing.toggle()
    }
    
    fileprivate func addGraphicSubLayer(_ path: CGPath) {
        let bezierLayer = CAShapeLayer()
        bezierLayer.path = path
        bezierLayer.lineWidth = 5
        bezierLayer.strokeColor = UIColor.black.cgColor
        bezierLayer.fillRule = .nonZero
        bezierLayer.fillColor = .none
        bezierLayer.lineCap = .butt
        
        self.layer.addSublayer(bezierLayer)
    }
}
