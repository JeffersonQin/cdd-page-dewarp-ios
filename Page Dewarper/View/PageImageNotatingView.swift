//
//  PageImageNotatingView.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/4/1.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit

class PageImageNotatingView: UIView {
    
    private var activateButton: NotationButton = .UL
    
    var originalImage = #imageLiteral(resourceName: "Example-1")
    
    var needsToLayout = true
    
    var autoPointsArray = NSMutableArray()
    
    private enum NotationButton {
        case UL
        case UR
        case DL
        case DR
    }
    
    lazy var imageButton_UL: UIButton = createLocatorButton()
    lazy var imageButton_UR: UIButton = createLocatorButton()
    lazy var imageButton_DL: UIButton = createLocatorButton()
    lazy var imageButton_DR: UIButton = createLocatorButton()
    
    lazy var imageInspectorView: InspectorImageView = createInspectorView()
    
    func location_square(between p1: CGPoint, and p2: CGPoint) -> CGFloat {
        return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)
    }
    
    @objc func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let dis_UL = location_square(between: sender.location(in: self), and: imageButton_UL.center)
            let dis_UR = location_square(between: sender.location(in: self), and: imageButton_UR.center)
            let dis_DL = location_square(between: sender.location(in: self), and: imageButton_DL.center)
            let dis_DR = location_square(between: sender.location(in: self), and: imageButton_DR.center)
            if dis_UL <= dis_UR && dis_UL <= dis_DL && dis_UL <= dis_DR {
                self.activateButton = .UL
                self.imageInspectorView.isHidden = false
            } else if dis_UR <= dis_UL && dis_UR <= dis_DL && dis_UR <= dis_DR {
                self.activateButton = .UR
                self.imageInspectorView.isHidden = false
            } else if dis_DL <= dis_UL && dis_DL <= dis_UR && dis_DL <= dis_DR {
                self.activateButton = .DL
                self.imageInspectorView.isHidden = false
            } else {
                self.activateButton = .DR
                self.imageInspectorView.isHidden = false
            }
            print(activateButton)
        case .changed:
            var buttonCenter = sender.location(in: self)
            if sender.location(in: self).x < 0 { buttonCenter.x = 0 }
            if sender.location(in: self).x > self.Width { buttonCenter.x = self.Width }
            if sender.location(in: self).y < 0 {buttonCenter.y = 0 }
            if sender.location(in: self).y > self.Height { buttonCenter.y = self.Height }
            
            self.imageInspectorView.image = self.originalImage.cropping(to: CGRect.init(x: buttonCenter.x / self.Width * originalImage.size.width - 25, y: buttonCenter.y / self.Width * originalImage.size.width - 25, width: 50, height: 50))
            switch activateButton {
            case .UL:
                imageButton_UL.center = buttonCenter
            case .UR:
                imageButton_UR.center = buttonCenter
            case .DL:
                imageButton_DL.center = buttonCenter
            case .DR:
                imageButton_DR.center = buttonCenter
            }
            setNeedsDisplay()
        case .ended:
            self.imageInspectorView.isHidden = true
        case .cancelled:
            self.imageInspectorView.isHidden = true
        default: break
        }
    }
    
    private func createLocatorButton() -> UIButton {
        let locatorButton = UIButton.init()
        locatorButton.setImage(UIImage.init(named: "locator2", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection), for: .normal)
        addSubview(locatorButton)
        locatorButton.backgroundColor = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 0)
        return locatorButton
    }
    
    private func createInspectorView() -> InspectorImageView {
        let inspectorView = InspectorImageView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        self.addSubview(inspectorView)
        inspectorView.isHidden = true
        return inspectorView
    }
    
    private func configureImageView() {
        imageButton_UL.frame = CGRect(x: -15 + 50, y: -15 + 50, width: 30, height: 30)
        imageButton_UR.frame = CGRect(x: self.bounds.width - 15 - 50, y: -15 + 50, width: 30, height: 30)
        imageButton_DL.frame = CGRect(x: -15 + 50, y: self.bounds.height - 15 - 50, width: 30, height: 30)
        imageButton_DR.frame = CGRect(x: self.bounds.width - 15 - 50, y: self.bounds.height - 15 - 50, width: 30, height: 30)
    }
    
    func layoutAutoPoint() {
        if autoPointsArray.count == 8 {
            configureImageView()
            self.imageButton_UR.center = CGPoint(x: autoPointsArray.object(at: 0) as! CGFloat / originalImage.size.width * self.Width, y: autoPointsArray.object(at: 1) as! CGFloat / originalImage.size.width * self.Width)
            self.imageButton_UL.center = CGPoint(x: autoPointsArray.object(at: 2) as! CGFloat / originalImage.size.width * self.Width, y: autoPointsArray.object(at: 3) as! CGFloat / originalImage.size.width * self.Width)
            self.imageButton_DL.center = CGPoint(x: autoPointsArray.object(at: 4) as! CGFloat / originalImage.size.width * self.Width, y: autoPointsArray.object(at: 5) as! CGFloat / originalImage.size.width * self.Width)
            self.imageButton_DR.center = CGPoint(x: autoPointsArray.object(at: 6) as! CGFloat / originalImage.size.width * self.Width, y: autoPointsArray.object(at: 7) as! CGFloat / originalImage.size.width * self.Width)
            self.setNeedsDisplay()
        } else {
            configureImageView()
        }
    }
    
    override func layoutSubviews() {
        if needsToLayout {
            layoutAutoPoint()
            needsToLayout = false
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        var path = UIBezierPath()
        path.move(to: imageButton_UL.center)
        path.addLine(to: imageButton_UR.center)
        #colorLiteral(red: 0.3303630352, green: 0.7530421615, blue: 0.8054673672, alpha: 1).setStroke()
        path.stroke()
        path = UIBezierPath()
        path.move(to: imageButton_UR.center)
        path.addLine(to: imageButton_DR.center)
        #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1).setStroke()
        path.stroke()
        path = UIBezierPath()
        path.move(to: imageButton_DR.center)
        path.addLine(to: imageButton_DL.center)
        #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).setStroke()
        path.stroke()
        path = UIBezierPath()
        path.move(to: imageButton_DL.center)
        path.addLine(to: imageButton_UL.center)
        #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).setStroke()
        path.stroke()
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.Width, y: 0))
        path.addLine(to: imageButton_UR.center)
        path.addLine(to: imageButton_UL.center)
        path.addLine(to: CGPoint(x: 0, y: 0))
        UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).setFill()
        path.fill()
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.Height))
        path.addLine(to: imageButton_DL.center)
        path.addLine(to: imageButton_UL.center)
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.fill()
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.Height))
        path.addLine(to: CGPoint(x: self.Width, y: self.Height))
        path.addLine(to: imageButton_DR.center)
        path.addLine(to: imageButton_DL.center)
        path.addLine(to: CGPoint(x: 0, y: self.Height))
        path.fill()
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.Width, y: 0))
        path.addLine(to: CGPoint(x: self.Width, y: self.Height))
        path.addLine(to: imageButton_DR.center)
        path.addLine(to: imageButton_UR.center)
        path.addLine(to: CGPoint(x: self.Width, y: 0))
        path.fill()
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: Width, y: 0))
        #colorLiteral(red: 0.3303630352, green: 0.7530421615, blue: 0.8054673672, alpha: 1).setStroke()
        path.lineWidth = 2.0
        path.stroke()
        path = UIBezierPath()
        path.move(to: CGPoint(x: Width, y: 0))
        path.addLine(to: CGPoint(x: Width, y: Height))
        #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1).setStroke()
        path.lineWidth = 2.0
        path.stroke()
        path = UIBezierPath()
        path.move(to: CGPoint(x: Width, y: Height))
        path.addLine(to: CGPoint(x: 0, y: Height))
        #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).setStroke()
        path.lineWidth = 2.0
        path.stroke()
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: Height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).setStroke()
        path.lineWidth = 2.0
        path.stroke()
    }

}


extension UIImage {
    
    /// 截取图片的指定区域，并生成新图片
    /// - Parameter rect: 指定的区域
    func cropping(to rect: CGRect) -> UIImage? {
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        // 截取部分图片并生成新图片
        guard let sourceImageRef = self.cgImage else { return nil }
        guard let newImageRef = sourceImageRef.cropping(to: croppingRect) else { return nil }
        let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }
    
}
