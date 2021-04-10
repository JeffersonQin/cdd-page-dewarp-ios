//
//  PageImageDrawingView.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/3/31.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit

class PageImageDrawingView: UIView {
    
    var pathsOfDrawing: [UIBezierPath] = []

    private func drawPath() {
        for path in pathsOfDrawing {
            path.lineJoinStyle = CGLineJoin.round
            path.lineWidth = SizeRatio.lineWidthToBoundWidth * bounds.width
            UIColor.init(red: 0, green: 255, blue: 255, alpha: 1).setStroke()
            path.stroke()
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawPath()
    }
    
    @objc func panGestureHandler(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .possible:
            print("possible")
        case .began:
            print(panGesture.location(in: self))
            let newPath = UIBezierPath()
            newPath.move(to: panGesture.location(in: self))
            pathsOfDrawing.append(newPath)
        case .changed:
            print(panGesture.location(in: self))
            pathsOfDrawing.last?.addLine(to: panGesture.location(in: self))
            setNeedsDisplay()
        default:
            break
        }
    }
    
}

extension PageImageDrawingView {
    
    struct SizeRatio {
        static var lineWidthToBoundWidth: CGFloat = 0.03
    }
    
}
