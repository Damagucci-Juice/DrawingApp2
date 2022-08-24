//
//  LayerTableViewCell.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/11.
//

import UIKit
import SnapKit

final class LayerTableViewCell: UITableViewCell {
    
    var title: UILabel?
    var shapeImageView: UIImageView?
    var shapeIndex: Int = Int.max

    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = UILabel()
        self.shapeImageView = UIImageView()
    }
    
    override func prepareForReuse() {
        self.title?.text = ""
        self.shapeImageView?.image = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let title = title,
              let shapeImageView = shapeImageView else { return }

        title.textColor = .label
        
        [shapeImageView, title].forEach {
            contentView.addSubview($0)
        }
        
        title.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        shapeImageView.snp.makeConstraints {

            $0.leading.equalToSuperview().offset(30)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(title)
            $0.width.equalTo(shapeImageView.snp.height)
        }
        
    }
    
    func setUp(with blueprint: ShapeBlueprint, at index: Int, printNumber number: Int) {
        shapeIndex = index
        title?.text = "\(blueprint.rawValue) \(number)"
        switch blueprint {
        case .rectangle:
            shapeImageView?.image = UIImage(systemName: "rectangle")
        case .photo:
            shapeImageView?.image = UIImage(systemName: "photo")
        case .text:
            shapeImageView?.image = UIImage(systemName: "t.square")
        case .drawing:
            shapeImageView?.image = UIImage(systemName: "scribble")
        }
    }
}
