//
//  PageImageModel.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/4/1.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import Foundation
import UIKit

public class PageImageModel {
    
    public var originalImage: UIImage
    
    public var notationPoints: NotationPoint?
    
    public var pointsNotationImage: UIImage?
    
    public var drawingNotationImage: UIImage?
    
    public var upperLowerSeperateThreshold: CGFloat = 0.0
    
    public init(withOriginalImage image: UIImage) { self.originalImage = image }
    
    public func getNotatedImage() -> UIImage {
        print(originalImage.size)
        return JQCV.getNotatedImage(originalImage, notationPoints!.p_UL, notationPoints!.p_UR, notationPoints!.p_DL, notationPoints!.p_DR, upperLowerSeperateThreshold)
    }
    
}

public struct NotationPoint {
    
    public var p_UL: CGPoint
    
    public var p_UR: CGPoint
    
    public var p_DL: CGPoint
    
    public var p_DR: CGPoint
    
    public init(p_UL: CGPoint, p_UR: CGPoint, p_DL: CGPoint, p_DR: CGPoint) {
        self.p_UL = p_UL
        self.p_UR = p_UR
        self.p_DL = p_DL
        self.p_DR = p_DR
    }
    
}
