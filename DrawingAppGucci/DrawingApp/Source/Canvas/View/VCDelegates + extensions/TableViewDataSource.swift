//
//  TableViewDataSource.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/16.
//

import UIKit

extension CanvasViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plane?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LayerTableViewCell", for: indexPath) as? LayerTableViewCell,
              let plane = plane
        else { return UITableViewCell() }
        
        func getPrintNumber(target: ShapeBlueprint) -> Int {
            var counter: Int
            var shapes: [Shape]
            switch target {
            case .rectangle:
                shapes = plane.shapes.filter { $0 is Rectangle }
            case .photo:
                shapes = plane.shapes.filter { $0 is Photo }
            case .text:
                shapes = plane.shapes.filter { $0 is Text }
            case .drawing:
                shapes = plane.shapes.filter { $0 is Shape }
            }
            counter = shapes.count
            for shape in shapes {
                if shape == plane[indexPath.row] {
                    return counter
                }
                counter -= 1
            }
            assert(false, "problem ouccured in \(#file), \(#function)")
        }
        
        switch plane[indexPath.row] {
        case _ as Rectangle:
            let number = getPrintNumber(target: .rectangle)
            cell.setUp(with: .rectangle, at: indexPath.row, printNumber: number)
        case _ as Photo:
            cell.setUp(with: .photo, at: indexPath.row, printNumber: getPrintNumber(target: .photo))
        case _ as Text:
            cell.setUp(with: .text, at: indexPath.row, printNumber: getPrintNumber(target: .text))
        default:
            break
        }
        
        return cell
    }
    
    //MARK: - drag and drop 후에 애니메이션과 함께 실행될 메서드
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.row != destinationIndexPath.row else {
            return
        }
        let spaceOfRow = sourceIndexPath.row - destinationIndexPath.row

        for step in 0..<abs(spaceOfRow) {
            if spaceOfRow > 0 {
                self.moveViewAndModel(to: .backward, index: sourceIndexPath.row - step)
            } else {
                self.moveViewAndModel(to: .forward, index: sourceIndexPath.row + step)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "레이어"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(40)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(40)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
