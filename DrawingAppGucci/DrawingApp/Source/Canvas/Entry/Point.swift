//
//  Point.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/23.
//

import Foundation

struct Point: Codable {
    func encode(with coder: NSCoder) {
        coder.encode(x, forKey: "x")
        coder.encode(y, forKey: "y")
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    var x: Double
    var y: Double
}
