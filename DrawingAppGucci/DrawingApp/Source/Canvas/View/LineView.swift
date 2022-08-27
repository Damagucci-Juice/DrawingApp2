//
//  DrawingView.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/24.
//

import UIKit

final class LineView: UIView, Drawable {
    
    
    var index: Int
    let lines: [[CGPoint]]
    let line: Line
    var shapeLayer: CAShapeLayer?
    
    init(line: Line, index: Int) {
        self.index = index
        self.lines = line.lines.map({ line in
            var tempLine: [CGPoint] = []
            line.forEach {
                tempLine.append(CGPoint(x: $0.x, y: $0.y))
            }
            return tempLine
        })
        self.line = line
        super.init(frame: CGRect(x: line.point.x, y: line.point.y, width: line.size.width, height: line.size.height))
        self.layer.borderColor = tintColor.cgColor
        self.sizeToFit()
        self.draw(self.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class shoud be made by init(), Not init?(coder:)")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let aPath = UIBezierPath()
        let origin = getOrigin(lines: self.lines)
        
        lines.forEach { line in
            for (i, p) in line.enumerated() {
                let calculatedPoint = CGPoint(x: p.x - origin.x, y: p.y - origin.y)
                if i == 0 {
                    aPath.move(to: calculatedPoint)
                } else {
                    aPath.addLine(to: calculatedPoint)
                }
            }
        }
        
        addGraphicSubLayer(aPath.cgPath)
        setNeedsDisplay()
    }
    
    func updateAlphaOrColor(alpha: Alpha, color: Color?) {
        guard let color = color,
              let layer = shapeLayer
        else { return }
        
        self.layer.sublayers?.removeAll()
        layer.strokeColor = CGColor(red: color.$r, green: color.$g, blue: color.$b, alpha: 1)
        DispatchQueue.main.async { [weak self] in
            self?.layer.addSublayer(layer)
            self?.setNeedsDisplay()
        }
        
    }
    
    fileprivate func getOrigin(lines: [[CGPoint]]) -> Point {
        var minX = Double(Int.max)
        var minY = Double(Int.max)
        lines.forEach { line in
            for p in line {
                if p.x < minX {
                    minX = p.x
                }
                if p.y < minY {
                    minY = p.y
                }
            }
        }
        return Point(x: minX, y: minY)
    }
    
    fileprivate func addGraphicSubLayer(_ path: CGPath) {
        let bezierLayer = CAShapeLayer()
        bezierLayer.path = path
        bezierLayer.lineWidth = 5
        bezierLayer.strokeColor = CGColor(red: line.color.$r, green: line.color.$g, blue: line.color.$b, alpha: 1)
        bezierLayer.fillRule = .nonZero
        bezierLayer.fillColor = .none
        bezierLayer.lineCap = .butt
        
        self.layer.addSublayer(bezierLayer)
        self.shapeLayer = bezierLayer
    }
}
