//
//  ViewController.swift
//  DrawingApp
//
//  Created by YEONGJIN JANG on 2022/07/05.
//

import UIKit
import Photos
import PhotosUI
import os.log

final class CanvasViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var drawableStackview: UIStackView!
    @IBOutlet weak var pointXView: UIView!
    @IBOutlet weak var pointYView: UIView!
    @IBOutlet weak var sizeWView: UIView!
    @IBOutlet weak var sizeHView: UIView!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    internal let plane = Plane()
    
    private var shapeFrameViews: [UIView] = []
    private var beforeSelectedView: UIView? {
        //MARK: - 선택된 뷰의 테두리를 그리고, 이전에 있던 뷰의 테두리를 지우기
        didSet {
            guard let currentView = beforeSelectedView else { return }
            updatePropertiesLabels(with: currentView)
        }
        willSet {
            self.beforeSelectedView?.drawEdges(selected: false)
            newValue?.drawEdges(selected: true)
        }
    }
    
    private let phPickerViewController: PHPickerViewController = {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        return vc
    }()
    
    @IBAction func touchedTextButton(_ sender: UIButton) {
        plane.makeShape(with: .text)
    }
    
    @IBAction func touchedXUp(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustX(index: currentView.index, isUp: true)
    }
    @IBAction func touchedXDown(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustX(index: currentView.index, isUp: false)
    }
    @IBAction func touchedYUp(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustY(index: currentView.index, isUp: true)
    }
    @IBAction func touchedYDown(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustY(index: currentView.index, isUp: false)
    }
    @IBAction func touchedWUp(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustWidth(index: currentView.index, isUp: true)
    }
    @IBAction func touchedWDown(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustWidth(index: currentView.index, isUp: false)
    }
    @IBAction func touchedHUp(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustHeight(index: currentView.index, isUp: true)
    }
    @IBAction func touchedHDown(_ sender: UIButton) {
        guard let currentView = beforeSelectedView as? Drawable else { return }
        plane.adjustHeight(index: currentView.index, isUp: false)
    }
    
    //MARK: - 사진 버튼 누르면 실행 되는 액션
    @IBAction func touchedPictureButton(_ sender: UIButton) {
        present(phPickerViewController, animated: true)
    }
    
    //MARK: - 상태창에 컬러 버튼 누르면 실행 되는 액션
    @IBAction func touchedColorButton(_ sender: UIButton) {
        guard let currentSquare = beforeSelectedView as? Drawable else { return }
        plane.changeColor(at: currentSquare.index)
    }
    
    //MARK: - 스테퍼 + - 버튼 누르면 실행 되는 액션
    @IBAction func touchedStepper(_ sender: UIStepper) {
        guard let currentSquare = beforeSelectedView as? Drawable else { return }
        plane.changeAlpha(at: currentSquare.index, value: sender.value)
    }
    
    //MARK: - 슬라이더에 점을 움직이면 실행 되는 액션
    @IBAction func movedDot(_ sender: UISlider) {
        guard let currentSquare = beforeSelectedView as? Drawable else { return }
        plane.changeAlpha(at: currentSquare.index, value: Double(sender.value))
    }
    
    //MARK: - 메인 화면에 한 점을 터치하면 실행되는 액션
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        guard 170.0 <= point.x && point.x <= 950.0 else { return }
        
        sender.cancelsTouchesInView = false
        
        //MARK: - 빈공간인지 아닌지 확인
        guard let index = plane
                .isTouched(at: (Double(point.x), Double(point.y))),
              let selectedShape = plane.findTouchedShape(at: (Double(point.x), Double(point.y)))
        else {
            statusView.isHidden = true
            beforeSelectedView = nil
            return
        }
        
        beforeSelectedView = shapeFrameViews[index]
        
        //MARK: - 상태창에 알림
        if let rectangle = selectedShape as? Rectangle {
            self.informSelectedViewToStatus(color: rectangle.color, alpha: selectedShape.alpha, type: .rectangle)
        } else {
            self.informSelectedViewToStatus(color: Color(), alpha: selectedShape.alpha, type: .photo)
        }
    }
    
    //MARK: - 사각형 버튼 누르면 실행 되는 액션
    @IBAction func touchedRectangleButton(_ sender: UIButton) {
        plane.makeShape(with: .rectangle)
    }
    
    //MARK: - 객체들의 초기값 설정
    private func attribute() {
        colorLabel.text = "색상"
        alphaLabel.text = "투명도"
        slider.isContinuous = false
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        stepper.isContinuous = false
        stepper.minimumValue = 0.1
        stepper.maximumValue = 1.0
        stepper.stepValue = 0.1
        rectangleButton.isOpaque = false
        statusView.isHidden = true
        rectangleButton.layer.cornerRadius = 10
        phPickerViewController.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        [pointXView, pointYView, sizeWView, sizeHView].forEach {
            guard let view = $0 else { return }
            view.layer.borderWidth = 0.5
            view.layer.cornerRadius = 10
            view.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    // MARK: - 노티피케이션 옵저버 등록
    private func addObservers() {
        
        // MARK: - 사각형 색 및 투명도 조절
        NotificationCenter.default
            .addObserver(
                forName: .rectangle,
                object: nil,
                queue: .main) { [unowned self] noti in
                    guard
                        let color = noti.userInfo?[NotificationKey.color] as? Color,
                        let alpha = noti.userInfo?[NotificationKey.alpha] as? Alpha
                    else { return }
                    
                    self.beforeSelectedView?.updateColorAndAlpha(color: color, alpha: alpha)
                    self.informSelectedViewToStatus(color: color, alpha: alpha, type: .rectangle)
                }
        
        //MARK: - 사진 투명도 변경
        NotificationCenter.default
            .addObserver(
                forName: .photo,
                object: nil,
                queue: .main) { [unowned self] noti in
                    guard
                        let alpha = noti.userInfo?[NotificationKey.alpha] as? Alpha,
                        let color = noti.userInfo?[NotificationKey.color] as? Color,
                        let photoView = beforeSelectedView as? PhotoView
                    else { return }
                    photoView.updateAlpha(alpha: alpha)
                    self.informSelectedViewToStatus(color: color, alpha: alpha, type: .photo)
                }
        
        //MARK: - 텍스트 투명도 변경
        NotificationCenter.default
            .addObserver(
                forName: .text,
                object: nil,
                queue: .main) { [unowned self] noti in
                    guard
                        let alpha = noti.userInfo?[NotificationKey.alpha] as? Alpha,
                        let color = noti.userInfo?[NotificationKey.color] as? Color,
                        let textView = beforeSelectedView as? TextView
                    else { return }
                    textView.updateAlpha(alpha: alpha)
                    self.informSelectedViewToStatus(color: color, alpha: alpha, type: .text)
                }
        
        //MARK: - 도형 추가 알림 노티피케이션
        NotificationCenter.default
            .addObserver(
                forName: .add,
                object: nil,
                queue: .main) { [unowned self] noti in
                    guard let shape = noti.userInfo?[NotificationKey.shape] as? Shape,
                          let index = noti.userInfo?[NotificationKey.index] as? Int
                    else {
                        return }
                    
                    self.addView(from: shape, index: index)
                    self.tableView.reloadData()
                }
        
        // MARK: - 도형 이동
        NotificationCenter.default.addObserver(forName: .move, object: nil, queue: .main) { _ in
            self.view.reloadInputViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
    }
    
    // MARK: - 메모리 관리를 위해 노티 셋업을 willAppear 에서, 노티 해제를 willDisappear 에서 실행
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        setUpPropertiesNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - 컬러버튼, 스테퍼, 슬라이더 조정 및 뷰에 사각형, 사진 추가
extension CanvasViewController {
    
    // MARK: - 상태창에 선택된 스퀘어 뷰를 알리기
    private func informSelectedViewToStatus(color: Color, alpha: Alpha, type blueprint: ShapeBlueprint) {
        statusView.isHidden = false
        let buttonTitleString = blueprint == .rectangle ? color.hexaColor : "비어있음"
        colorButton.setTitle(buttonTitleString, for: .normal)
        colorButton.isEnabled = blueprint == .rectangle ? true : false
        adjustSliderAndStepper(color: color, alpha: alpha)
    }
    
    func updatePropertiesLabels(with view: UIView) {
        self.xLabel.text = "X :: \(Int(view.layer.frame.origin.x))"
        self.yLabel.text = "Y :: \(Int(view.layer.frame.origin.y))"
        self.widthLabel.text = "W :: \(Int(view.layer.frame.width))"
        self.heightLabel.text = "H :: \(Int(view.layer.frame.height))"
    }
    
    //TODO: 아래 세 메서드 제너럴로 1개로 만들어보자.
    private func addView(from shape: Shape, index: Int) {
        let view = UIFactory.makeView(with: shape, at: index)
        createPanGestureRecognizer(targetView: view)
        shapeFrameViews.append(view)
        self.view.addSubview(view)
        self.view.bringSubviewToFront(drawableStackview)
    }
    
    // MARK: - 새로운 스퀘어뷰를 추가하는 메서드
    private func addSquareView(rect: Rectangle, index: Int) {
        let squareView = SquareView(rectangle: rect, index: index)
        createPanGestureRecognizer(targetView: squareView)
        shapeFrameViews.append(squareView)
        view.addSubview(squareView)
        view.bringSubviewToFront(drawableStackview)
    }
    
    // MARK: - 새로운 사진뷰를 추가하는 메서드
    private func addPhotoView(photo: Photo, index: Int) {
        let photoView = PhotoView(photo: photo, index: index)
        createPanGestureRecognizer(targetView: photoView)
        shapeFrameViews.append(photoView)
        view.addSubview(photoView)
        view.bringSubviewToFront(drawableStackview)
    }
    
    // MARK: - 새로운 텍스트뷰를 추가하는 메서드
    private func addTextView(text: Text, index: Int) {
        let textView = TextView(text: text, index: index)
        createPanGestureRecognizer(targetView: textView)
        shapeFrameViews.append(textView)
        view.addSubview(textView)
        view.bringSubviewToFront(drawableStackview)
    }
    
    
    // MARK: - 스테퍼와 슬라이더의 값을 조정하는 메서드
    private func adjustSliderAndStepper(color: Color, alpha: Alpha) {
        slider.value = Float(alpha.value)
        stepper.value = alpha.value
    }
    
}

// MARK: - 사진 델리게이트
extension CanvasViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] reading, error in
                guard let imageData = reading as? UIImage, error == nil else { return }
                let imagePngData = imageData.pngData()
                self.plane.makeShape(with: .photo, image: imagePngData)
            }
        }
    }
}

// MARK: - 크기와 위치에 관련한 노티피케이션 설정 추가
extension CanvasViewController {
    func setUpPropertiesNotifications() {
        NotificationCenter.default.addObserver(
            forName: .x,
            object: nil,
            queue: .main) { [unowned self] noti in
                guard
                    let drawbleView = beforeSelectedView as? Drawable,
                    let currentView = beforeSelectedView
                else { return }
                let shape = plane[drawbleView.index]
                currentView.layer.frame.origin.x = shape.point.x
                updatePropertiesLabels(with: currentView)
            }
        
        NotificationCenter.default.addObserver(
            forName: .y,
            object: nil,
            queue: .main) { [unowned self] noti in
                guard
                    let drawbleView = beforeSelectedView as? Drawable,
                    let currentView = beforeSelectedView
                else { return }
                let shape = plane[drawbleView.index]
                currentView.layer.frame.origin.y = shape.point.y
                updatePropertiesLabels(with: currentView)
            }
        
        NotificationCenter.default.addObserver(
            forName: .width,
            object: nil,
            queue: .main) { [unowned self] noti in
                guard
                    let drawbleView = beforeSelectedView as? Drawable,
                    let currentView = beforeSelectedView
                else { return }
                let shape = plane[drawbleView.index]
                currentView.frame = CGRect(x: shape.point.x, y: shape.point.y, width: shape.size.width, height: shape.size.height)
                updatePropertiesLabels(with: currentView)
            }
        
        NotificationCenter.default.addObserver(
            forName: .height,
            object: nil,
            queue: .main) { [unowned self] noti in
                guard
                    let drawbleView = beforeSelectedView as? Drawable,
                    let currentView = beforeSelectedView
                else { return }
                let shape = plane[drawbleView.index]
                currentView.frame = CGRect(x: shape.point.x, y: shape.point.y, width: shape.size.width, height: shape.size.height)
                updatePropertiesLabels(with: currentView)
            }
    }
}

extension CanvasViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plane.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LayerTableViewCell", for: indexPath) as? LayerTableViewCell else { return UITableViewCell() }
        
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
            cell.setUp(with: .rectangle, at: indexPath.row, printNumber: getPrintNumber(target: .rectangle))
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
        guard sourceIndexPath.row != destinationIndexPath.row else { return }
        let spaceOfRow = sourceIndexPath.row - destinationIndexPath.row
        plane.moveRow(by: spaceOfRow, from: sourceIndexPath.row)
        if spaceOfRow > 0 {
            for step in 0..<spaceOfRow {
                self.moveViewForward(with: sourceIndexPath.row - step)
            }
        } else {
            for step in 0..<spaceOfRow {
                self.moveViewBackward(with: step + sourceIndexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "레이어"
    }
}

extension CanvasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shape = plane[indexPath.row]
        beforeSelectedView = shapeFrameViews[indexPath.row]
        
        //MARK: - 상태창에 알림
        if let rectangle = shape as? Rectangle {
            self.informSelectedViewToStatus(color: rectangle.color, alpha: shape.alpha, type: .rectangle)
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
                self.plane.moveFormost(with: indexPath.row)
                var index = indexPath.row
                while index > 0 {
                    self.moveViewForward(with: index)
                    index -= 1
                }
                tableView.reloadData()
            }
            let backwardAction =
            UIAction(title: NSLocalizedString("뒤로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.up.square")) { [unowned self] action in
                self.plane.moveforward(with: indexPath.row)
                self.moveViewForward(with: indexPath.row)
                tableView.reloadData()
            }
            let forwardAction =
            UIAction(title: NSLocalizedString("앞으로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.down.square")) { [unowned self] action in
                self.plane.moveBackward(with: indexPath.row)
                self.moveViewBackward(with: indexPath.row)
                tableView.reloadData()
            }
            let foreMostAction =
            UIAction(title: NSLocalizedString("맨 앞으로 보내기", comment: ""),
                     image: UIImage(systemName: "arrow.down.to.line")) { [unowned self] action in
                self.plane.moveBackmost(with: indexPath.row)
                var index = indexPath.row
                while index < shapeFrameViews.count - 1 {
                    moveViewBackward(with: index)
                    index += 1
                }
                tableView.reloadData()
            }
            
            return UIMenu(title: "", children: [backMostAction, backwardAction, forwardAction, foreMostAction])
        }
    }
}

//MARK: - 길게 눌러서 한칸 셀을 움직이는 메서드
extension CanvasViewController {
    private func moveViewForward(with index: Int) {
        guard index > 0 else { return }
        let preView = shapeFrameViews[index - 1]
        shapeFrameViews[index - 1] = shapeFrameViews[index]
        shapeFrameViews[index] = preView
    }
    
    private func moveViewBackward(with index: Int) {
        guard index < shapeFrameViews.count - 1 else { return }
        let postView = shapeFrameViews[index + 1]
        shapeFrameViews[index + 1] = shapeFrameViews[index]
        shapeFrameViews[index] = postView
    }
}


//MARK: - TableView Cell Drag and Drop
extension CanvasViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}
