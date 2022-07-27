//
//  Shape.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/27.
//

import Foundation

class Shape {
    
    let id: String
    let size: Size
    let point: Point
    
    private(set) var alpha: Alpha
    private(set) var bound: Bound

    init(id: String, size: Size, point: Point, alpha: Alpha, bound: Bound) {
        self.id = id
        self.size = size
        self.point = point
        self.alpha = alpha
        self.bound = bound
    }
    
    func changeAlpha(value: Double) {
        self.alpha.change(value: value)
    }
}
