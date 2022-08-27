//
//  Line.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/24.
//

import Foundation

final class Line: Shape {
    private(set) var lines: [[Point]]
    private(set) var color: Color = Color(r: 0, g: 0, b: 0)
    
    init(shape: Shape, lines: [[Point]]) {
        self.lines = lines
        super.init(id: shape.id, size: shape.size, point: shape.point, alpha: shape.alpha, bound: shape.bound)
    }
    
    required init?(coder: NSCoder) {
        guard let lines = coder.decodeObject(forKey: "lines") as? [[Point]] else { assert(false) }
        self.lines = lines
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(lines, forKey: "lines")
    }
    
    func setRandomColor() {
        self.color = Color()
    }
}
