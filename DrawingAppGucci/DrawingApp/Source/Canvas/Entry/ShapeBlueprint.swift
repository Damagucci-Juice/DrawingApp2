//
//  BlueprintOfViewShape.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/27.
//

import Foundation

// MARK: - FactoryMethod 패턴으로 작업할 때, make 메서드에서 어떤 것을 사용하면 더 수월하게 변환 할 수 있을지 알려주는 열거형
enum ShapeBlueprint: String {
    case rectangle = "Rect"
    case photo = "Photo"
    case text = "Text"
    case drawing = "Drawing"
}
