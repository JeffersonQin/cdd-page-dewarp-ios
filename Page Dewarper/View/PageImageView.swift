//
//  PageImageView.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/3/31.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit

class PageImageView: UIView {
    
    private lazy var imageViewForPageImage = createImageView()
    
    var pageImageDrawingView: PageImageDrawingView? {
        didSet { self.setNeedsLayout() }
    }
    var pageImageNotatingView: PageImageNotatingView? {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable
    var showingImage: UIImage = #imageLiteral(resourceName: "Example-1") { didSet { self.setNeedsLayout() } }
    
    private func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }
    
    private func configureImageView() {
        var useViewWidth: Bool = false
        if self.bounds.width / showingImage.size.width * showingImage.size.height < self.bounds.height { useViewWidth = true }
        var imageSize = CGSize.zero
        if useViewWidth {
            imageSize = showingImage.size.zoom(by: self.bounds.width / showingImage.size.width)
        } else {
            imageSize = showingImage.size.zoom(by: self.bounds.height / showingImage.size.height)
        }
        imageViewForPageImage.frame = CGRect(origin: CGPoint(x: (bounds.width - imageSize.width) / 2, y: (bounds.height - imageSize.height) / 2), size: imageSize)
        imageViewForPageImage.image = showingImage
        let pageImageDrawingViewFrame = CGRect(origin: CGPoint(x: self.frame.minX + imageViewForPageImage.frame.minX, y: self.frame.minY + imageViewForPageImage.frame.minY), size: self.imageViewForPageImage.frame.size)
        if let drawingView: PageImageDrawingView = pageImageDrawingView {
            drawingView.frame = pageImageDrawingViewFrame
        }
        if let notatingView: PageImageNotatingView = pageImageNotatingView {
            notatingView.frame = pageImageDrawingViewFrame
            notatingView.needsToLayout = true
            notatingView.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        configureImageView()
    }
}

extension CGRect {
    
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width / 2, height: height)
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width / 2, height: height)
    }
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale, newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    
}

extension CGPoint {
    
    func offSetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
    
}

extension CGSize {
    
    func zoom(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
    
}
