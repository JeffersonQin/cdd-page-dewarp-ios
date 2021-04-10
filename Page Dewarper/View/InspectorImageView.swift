//
//  InspectorImageView.swift
//  Page Dewarpper
//
//  Created by Jefferson Qin on 2020/4/6.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit

class InspectorImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let pointImageView = UIImageView.init(image: #imageLiteral(resourceName: "point"))
        pointImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.addSubview(pointImageView)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
