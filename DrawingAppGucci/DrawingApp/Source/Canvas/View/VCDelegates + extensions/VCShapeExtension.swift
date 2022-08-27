//
//  VCShapeExtension.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/08/16.
//

import UIKit

//MARK: - 컬러버튼, 스테퍼, 슬라이더 조정 및 뷰 추가
extension CanvasViewController {
    
    // MARK: - 상태창에 선택된 스퀘어 뷰를 알리기
    func informSelectedViewToStatus(color: Color, alpha: Alpha, type blueprint: ShapeBlueprint) {
        let hasColor: Bool = blueprint == .rectangle || blueprint == .drawing
        let buttonTitleString = hasColor ? color.hexaColor : "비어있음"
        colorButton.isEnabled = hasColor ? true : false
        colorButton.setTitle(buttonTitleString, for: .normal)
        adjustSliderAndStepper(by: alpha)
        statusView.isHidden = false
        if blueprint == .drawing {
            self.stepper.isEnabled = false
            self.slider.isEnabled = false
        } else {
            self.stepper.isEnabled = true
            self.slider.isEnabled = true
        }
    }
    
    func updatePropertiesLabels(with view: UIView) {
        self.xLabel.text = "X :: \(Int(view.layer.frame.origin.x))"
        self.yLabel.text = "Y :: \(Int(view.layer.frame.origin.y))"
        self.widthLabel.text = "W :: \(Int(view.layer.frame.width))"
        self.heightLabel.text = "H :: \(Int(view.layer.frame.height))"
    }
    
    func addView(from shape: Shape, index: Int) {
        let view = UIFactory.makeView(with: shape, at: index)
        createPanGestureRecognizer(targetView: view)
        shapeFrameViews.append(view)
        self.backgroundView.addSubview(view)
        view.becomeFirstResponder()
        self.view.bringSubviewToFront(drawableStackview)
    }
    
    // MARK: - 스테퍼와 슬라이더의 값을 조정하는 메서드
    func adjustSliderAndStepper(by value: Alpha) {
        slider.value = Float(value.value)
        stepper.value = value.value
    }
    
    func removeViews() {
        tableView.reloadData()
        shapeFrameViews.forEach { view in
            view.removeFromSuperview()
        }
        shapeFrameViews = []
    }
    
}

