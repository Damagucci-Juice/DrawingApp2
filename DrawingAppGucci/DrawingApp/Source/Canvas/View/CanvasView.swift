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
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lines = []
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstLine = lines.first else { return }
        
        if isCanDrawing && !firstLine.isEmpty {
            postNotification(with: lines)
        }
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
    
    func enableDrawing() {
        self.isCanDrawing.toggle()
    }
}
