//
//  Line.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/24.
//

import Foundation

final class Line: Shape {
    
    let lineData: Data
    private(set) var color: Color = Color(r: 0, g: 0, b: 0)
    
    init(shape: Shape, lineData: Data) {
        self.lineData = lineData
        super.init(id: shape.id, size: shape.size, point: shape.point, alpha: shape.alpha, bound: shape.bound)
    }
    
    required init?(coder: NSCoder) {
        guard let lineData = coder.decodeData(),
              let red = coder.decodeObject(forKey: "red") as? UInt8,
              let green = coder.decodeObject(forKey: "green") as? UInt8,
              let blue = coder.decodeObject(forKey: "blue") as? UInt8
        else { fatalError() }

        let color = Color(r: red, g: green, b: blue)
        self.lineData = lineData
        self.color = color
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(lineData)
        coder.encode(color.r, forKey: "red")
        coder.encode(color.g, forKey: "green")
        coder.encode(color.b, forKey: "blue")
    }
    
    func setRandomColor() {
        self.color = Color()
    }
}
