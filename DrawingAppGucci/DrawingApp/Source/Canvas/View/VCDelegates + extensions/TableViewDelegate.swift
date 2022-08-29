//
//  TableViewDelegate.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/16.
//

import UIKit

extension CanvasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let plane = plane else { return }
        let shape = plane[indexPath.row]
        beforeSelectedView = shapeFrameViews[indexPath.row]
        
        //MARK: - 상태창에 알림
        if let rectangle = shape as? Rectangle {
            self.informSelectedViewToStatus(color: rectangle.color, alpha: shape.alpha, type: .rectangle)
        } else if case let line as Line = shape {
            self.informSelectedViewToStatus(color: line.color, alpha: shape.alpha, type: .drawing)
        } else {
            self.informSelectedViewToStatus(color: Color(r: 0, g: 0, b: 0), alpha: shape.alpha, type: .photo)
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
        return
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [unowned self] suggestedActions in
            let backMostAction =
            UIAction(title: NSLocalizedString("맨 뒤로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.up.to.line")) { [unowned self] action in
                moveViewAndModel(to: .backmost, index: indexPath.row)
                tableView.reloadData()
            }
            let backwardAction =
            UIAction(title: NSLocalizedString("뒤로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.up.square")) { [unowned self] action in
                moveViewAndModel(to: .backward, index: indexPath.row)
                tableView.reloadData()
            }
            let forwardAction =
            UIAction(title: NSLocalizedString("앞으로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.down.square")) { [unowned self] action in
                moveViewAndModel(to: .forward, index: indexPath.row)
                tableView.reloadData()
            }
            let foreMostAction =
            UIAction(title: NSLocalizedString("맨 앞으로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.down.to.line")) { [unowned self] action in
                moveViewAndModel(to: .foremost, index: indexPath.row)
                tableView.reloadData()
            }
            
            return UIMenu(title: "", children: [backMostAction, backwardAction, forwardAction, foreMostAction])
        }
    }
}
