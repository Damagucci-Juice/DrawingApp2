//
//  Plane.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/08.
//

import Foundation

protocol Planable: NSObject {
    func makeShape(with blueprint: ShapeBlueprint, by urlData: Data?)
    func isTouched(at point: (Double, Double)) -> Int?
    func findTouchedShape(at point: (Double, Double)) -> Shape?
    func changeColorAndAlpha(at index: Int, by alphaValue: Double?)
    subscript(_ index: Int) -> Shape { get }
}

final class Plane: NSObject, Planable {
    
    private(set) var shapes: [Shape] = []
    private var factory = ShapeFactory()
    var count: Int { shapes.count }
    
    required init?(coder: NSCoder) {
        guard let shapes = coder.decodeObject(forKey: "shapes") as? [Shape] else { assert(false) }
        self.shapes = shapes
    }
    
    override init() {
        
    }
    
    subscript(index: Int) -> Shape {
        precondition(isIndexValid(index: index), "shapes is out of index")
        return self.shapes[index]
    }
    
    private func isIndexValid(index: Int) -> Bool {
        return 0 <= index && index < self.shapes.count
    }
    
    //MARK: - 도형 추가
    func makeShape(with blueprint: ShapeBlueprint, by urlData: Data? = nil) {
        let shape = factory.generateShape(with: blueprint, urlData: urlData)
        shapes.append(shape)
        
        NotificationCenter.default
            .post(
                name: .add,
                object: self,
                userInfo: [NotificationKey.shapeObject: shape,
                           NotificationKey.index: count - 1]
            )
    }
    
    // MARK: - 몇 번째 인덱스가 선택되었는지 반환
    func isTouched(at point: (Double, Double)) -> Int? {
        for (index, rectangle) in shapes.enumerated() {
            if rectangle.bound.xBound.contains(point.0)
                && rectangle.bound.yBound.contains(point.1) {
                return index
            }
        }
        return nil
    }
    
    // MARK: - 선택된 인덱스의 사각형을 반환
    func findTouchedShape(at point: (Double, Double)) -> Shape? {
        guard let touchResultIndex = isTouched(at: point) else { return nil }
        return self[touchResultIndex]
    }
    
    //MARK: - 색상 변경
    func changeColorAndAlpha(at index: Int, by alphaValue: Double? = nil) {
        var blueprint: ShapeBlueprint = .rectangle
        var color = Color(r: 0, g: 0, b: 0)
        var alpha = Alpha.ten
        switch self[index] {
        case let rectangle as Rectangle:
            if let alphaValue = alphaValue {
                rectangle.changeAlpha(value: alphaValue)
            } else {
                rectangle.setRandomColor()
            }
            blueprint = .rectangle
            color = rectangle.color
            alpha = rectangle.alpha
        case let photo as Photo:
            photo.changeAlpha(value: alphaValue ?? 0)
            blueprint = .photo
            alpha = photo.alpha
        case let text as Text:
            text.changeAlpha(value: alphaValue ?? 0)
            blueprint = .text
            alpha = text.alpha
        default:
            assert(false, "failure at type casting")
        }
        
        NotificationCenter.default
            .post(
                name: .color,
                object: self,
                userInfo: [
                    NotificationKey.color: color,
                    NotificationKey.alpha: alpha,
                    NotificationKey.blueprint: blueprint
                ]
            )
    }
}

// MARK: - 사각형이나 사진의 위치, 크기를 조정
extension Plane {
    func renewCenterOfShape(at index: Int, after position: Point) {
        let shape = self[index]
        guard shape.point.x >= 1 && shape.point.y >= 1 else { return }
        shape.movePlace(to: position)
    }
    //MARK: - X,Y,W,H, 열거형 만들어서 스위치 문으로 못 돌리나?
    func adjustWidth(index: Int, isUp: Bool) {
        let shape = self[index]
        guard shape.size.width >= 1 else { return }
        shape.adjustWidth(isUp: isUp)
        postPropertiesNotification(changed: .width)
    }
    
    func adjustHeight(index: Int, isUp: Bool) {
        let shape = self[index]
        guard shape.size.height >= 1 else { return }
        shape.adjustHeight(isUp: isUp)
        postPropertiesNotification(changed: .height)
    }
    
    func adjustX(index: Int, isUp: Bool) {
        let shape = self[index]
        guard shape.point.x >= 1 else { return }
        shape.adjustX(isUp: isUp)
        postPropertiesNotification(changed: .x)
    }
    
    func adjustY(index: Int, isUp: Bool) {
        let shape = self[index]
        guard shape.point.y >= 1 else { return }
        shape.adjustY(isUp: isUp)
        postPropertiesNotification(changed: .y)
    }
    
    private func postPropertiesNotification(changed property: ShapeProperty) {
        NotificationCenter.default
            .post(
                name: .property,
                object: self,
                userInfo: [NotificationKey.property : property]
            )
    }
}

//MARK: - 목록에서 오브젝트 순서 변경 메서드
extension Plane {
    //MARK: - 배열에서 한 칸 앞으로
    func moveBackward(with index: Int) {
        guard index > 0 else { return }
        let backShape = shapes[index - 1]
        shapes[index - 1] = shapes[index]
        shapes[index] = backShape
    }
    //MARK: - 배열에서 맨 앞으로
    func moveBackmost(with index: Int) {
        var index = index
        while index > 0 {
            moveBackward(with: index)
            index -= 1
        }
    }
    
    //MARK: - 배열에서 한 칸 뒤로
    func moveForward(with index: Int) {
        guard index < shapes.count - 1 else { return }
        let forwardShape = shapes[index + 1]
        shapes[index + 1] = shapes[index]
        shapes[index] = forwardShape
    }
    //MARK: - 배열에서 맨 뒤로
    func moveForemost(with index: Int) {
        var index = index
        while index < shapes.count - 1  {
            moveForward(with: index)
            index += 1
        }
    }
    //MARK: - 배열에서 여러 칸 이동
    func moveRows(by subtractOfIndexPath: Int, from index: Int) {
        let rowCount = abs(subtractOfIndexPath)
        for step in 0..<rowCount {
            if subtractOfIndexPath >= 0 {
                moveBackward(with: index - step)
            } else {
                moveForward(with: index + step)
            }
        }
    }
}

extension Plane: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newPlane = Self()
        newPlane.shapes = self.shapes
        return newPlane
    }
}

extension Plane: NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(self.shapes, forKey: "shapes")
    }
}


extension Plane {
    func removeShape() {
        self.shapes = []
    }
}
