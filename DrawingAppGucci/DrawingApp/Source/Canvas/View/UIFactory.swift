//
//  UIFactory.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/15.
//

import Foundation
import UIKit.UIView

final class UIFactory {
    static func makeView(with shape: Shape, at index: Int) -> UIView {
        switch shape {
        case let rectangle as Rectangle:
            return SquareView(rectangle: rectangle, index: index)
        case let photo as Photo:
            return PhotoView(photo: photo, index: index)
        case let text as Text:
            return TextView(text: text, index: index)
        case let line as Line:
            return LineView(line: line, index: index)
        default:
            assert(false, "problem occured at \(#file)")
        }
    }
}
