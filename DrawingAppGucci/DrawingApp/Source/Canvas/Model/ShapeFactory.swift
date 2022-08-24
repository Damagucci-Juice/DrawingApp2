//
//  ShapeFactory.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/05.
//

import Foundation

final class ShapeFactory {
    
    private var viewBound: (ClosedRange<Double>, ClosedRange<Double>)?
    
    init() {
        NotificationCenter.default
            .addObserver(
                forName: .boundary,
                object: nil,
                queue: .current) { [weak self] noti in
                    guard let bound =
                            noti.userInfo?[NotificationKey.range]
                            as? (ClosedRange<Double>, ClosedRange<Double>)
                    else { return }
                    
                    self?.viewBound = bound
                }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func generateShape(with: ShapeBlueprint, urlData: Data? = nil) -> Shape {
        guard let viewBound = viewBound else {
            assert(false, "viewBound에 값이 없습니다.")
        }


        let size = Size(width: ShapeSize.width,
                        height: ShapeSize.height)
        let point = Point(x: Double.random(in: viewBound.0),
                          y: Double.random(in: viewBound.1))
        let shape = Shape(id: generateUUID(),
                          size: size,
                          point: point,
                          alpha: Self.generateAlpha(),
                          bound: Bound(size: size, point: point))

        switch with {
        case .rectangle:
            return Rectangle(shape: shape, color: Color())
        case .photo:
            guard let urlData = urlData else {
                assert(false, "imageData is nil")
            }
            return Photo(shape: shape, urlData: urlData)
        case .text:
            let string = makeRandomText()
            let textSize = Size(width: Double(string.count) * 13, height: 35)
            shape.size = textSize
            return Text(shape: shape, string: string)
        case .drawing:
            guard let linesData = urlData,
                  let lines = try? JSONDecoder().decode([[Point]].self, from: linesData)
            else { assert(false) }
            let pointAndSize = makeOriginPointAndSize(from: lines)
            shape.point = pointAndSize.point
            shape.size = pointAndSize.size
            
            return Line(shape: shape, lines: lines)
        }
    }
    
     private func generateUUID() -> String {
        let id = UUID()             // xxxx-xxxx-xxxx-xxxx
            .uuidString
            .components(separatedBy: "-")
            .reduce("") { partialResult, word in
                return partialResult + word
            }
        
        var resultId: String = ""
        for word in id.enumerated() {
            if word.offset > 8 {
                break
            }
            if word.offset % 3 == 0 && word.offset != 0 {
                resultId += "-"
            }
            resultId += String(word.element)
        }

        return resultId             // xxx-xxx-xxx
    }
    
    static func generateAlpha() -> Alpha {
        let randomAlpha = Int.random(in: 1...10)
        switch randomAlpha {
        case 1:
            return .one
        case 2:
            return .two
        case 3:
            return .three
        case 4:
            return .four
        case 5:
            return .five
        case 6:
            return .six
        case 7:
            return .seven
        case 8:
            return .eight
        case 9:
            return .nine
        default:
            return .ten
        }
    }
    
    private func makeRandomText() -> String {
        let string: String = """
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Egestas tellus rutrum tellus pellentesque eu. Viverra justo nec ultrices dui sapien eget mi proin sed. Vel pretium lectus quam id leo. Molestie at elementum eu facilisis sed odio morbi quis commodo. Risus at ultrices mi tempus imperdiet nulla malesuada. In est ante in nibh mauris cursus mattis molestie a. Venenatis urna cursus eget nunc. Eget velit aliquet sagittis id consectetur purus ut. Amet consectetur adipiscing elit pellentesque habitant morbi tristique senectus. Consequat nisl vel pretium lectus quam id. Nisl vel pretium lectus quam id leo in vitae turpis. Purus faucibus ornare suspendisse sed. Amet mauris commodo quis imperdiet.
                            """
        let dividedStringBySpace: [String] = string.split(separator: " ").map { String($0) }
        let randomInt = Int.random(in: 0...Int.max)
        var result = ""
        for index in randomInt..<randomInt + 5 {
            let tempIndex = index % dividedStringBySpace.count
            result += "\(dividedStringBySpace[tempIndex]) "
        }
        result.removeLast()
        return result
    }
    
        private func makeOriginPointAndSize(from lines: [[Point]]) -> (point: Point, size: Size) {
            //x, y 중에 가장 0에 가까운 것을 찾아서 Point 로 만들기
            var minX: Double = Double(Int.max)
            var minY: Double = Double(Int.max)
            var maxX: Double = 0.0
            var maxY: Double = 0.0
            lines.forEach { line in
                //TODO: - switch (point.x, point.y) {} 로 할 필요 없는지 확인
                line.forEach { point in
                    if point.x < minX {
                        minX = point.x
                    }
                    if point.y < minY {
                        minY = point.y
                    }
                    if point.x > maxX {
                        maxX = point.x
                    }
                    if point.y > maxY {
                        maxY = point.y
                    }
                }
                
            }
            return (
                Point.init(x: minX, y: minY),
                Size(width: maxX - minX, height: maxY - minY)
            )
        }
}
