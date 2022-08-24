//
//  DrawingView.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/24.
//

import UIKit

final class LineView: UIImageView, Drawable {
    
    
    var index: Int
    let lines: [[CGPoint]]
    
    init(line: Line, index: Int) {
        self.index = index
        self.lines = line.lines.map({ line in
            var tempLine: [CGPoint] = []
            line.forEach {
                tempLine.append(CGPoint(x: $0.x, y: $0.y))
            }
            return tempLine
        })
        super.init(frame: CGRect(x: line.point.x, y: line.point.y, width: line.size.width, height: line.size.height))
        super.backgroundColor = .green
        super.layer.opacity = 0.5
        dump(line.bound)
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class shoud be made by init(), Not init?(coder:)")
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        
//        lines.forEach { line in
//            for (i, p) in line.enumerated() {
//                if i == 0 {
//                    context.move(to: p)
//                } else {
//                    context.addLine(to: p)
//                }
//            }
//        }
//          
////        for (i, p) in points.enumerated() {
////            if i == 0 {
////                context.move(to: p)
////            } else {
////                context.addLine(to: p)
////            }
////        }
//          
//        context.setStrokeColor(UIColor.red.cgColor)
//        context.setLineWidth(5)
//        context.setLineCap(.round)
//        context.strokePath()
//        
//        setNeedsDisplay()
//    }
    
    func updateAlphaOrColor(alpha: Alpha, color: Color?) {
        assert(false)
    }
}
