//
//  Text.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/08.
//

import Foundation

final class Text: Shape {
    
    let string: String
    
    init(shape: Shape, string: String) {
        self.string = string
        super.init(id: shape.id, size: shape.size, point: shape.point, alpha: shape.alpha, bound: shape.bound)
    }
    
    required init?(coder: NSCoder) {
        guard let string = coder.decodeObject(forKey: "string") as? String else { assert(false) }
        self.string = string
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(string, forKey: "string")
    }
}
