//
//  PageImageNotatingViewController.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/4/1.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit
import JGProgressHUD

class PageImageNotatingViewController: UIViewController {
    
    var originalImage = UIImage.init(named: "Example-1")!
    
    var pageImageModel: PageImageModel?
    
    @IBOutlet var pageImageView: PageImageView!
    
    @IBOutlet var pageImageNotatingView: PageImageNotatingView! {
        didSet {
            pageImageNotatingView.addGestureRecognizer(UIPanGestureRecognizer.init(target: pageImageNotatingView, action: #selector(PageImageNotatingView.panGestureHandler(sender:))))
        }
    }
    
    @IBAction func autoButtonClicked(_ sender: UIBarButtonItem) {
        self.pageImageNotatingView.layoutAutoPoint()
    }
    
    @IBAction func maximizeButtonClicked(_ sender: UIBarButtonItem) {
        self.pageImageNotatingView.imageButton_UL.center = CGPoint(x: 0, y: 0)
        self.pageImageNotatingView.imageButton_UR.center = CGPoint(x: self.pageImageNotatingView.Width, y: 0)
        self.pageImageNotatingView.imageButton_DL.center = CGPoint(x: 0, y: self.pageImageNotatingView.Height)
        self.pageImageNotatingView.imageButton_DR.center = CGPoint(x: self.pageImageNotatingView.Width, y: self.pageImageNotatingView.Height)
        self.pageImageNotatingView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageImageModel = PageImageModel(withOriginalImage: originalImage)
        pageImageView.showingImage = pageImageModel!.originalImage
        pageImageNotatingView.originalImage = pageImageModel!.originalImage
        pageImageView.pageImageNotatingView = pageImageNotatingView
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1056642756, green: 0.3285115659, blue: 0.574674964, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let progressHUD = JGProgressHUD.init(style: .dark)
        progressHUD.textLabel.text = "Computing"
        progressHUD.show(in: self.view, animated: true)
        pageImageNotatingView.autoPointsArray = JQCV.largestRect(pageImageModel?.originalImage)!
        pageImageNotatingView.layoutAutoPoint()
        progressHUD.dismiss(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueWithPoints" {
            pageImageModel?.notationPoints = NotationPoint.init(
                p_UL: pageImageNotatingView.imageButton_UL.center * ((pageImageModel?.originalImage.size.width)! / pageImageNotatingView.bounds.width),
                p_UR: pageImageNotatingView.imageButton_UR.center * ((pageImageModel?.originalImage.size.width)! / pageImageNotatingView.bounds.width),
                p_DL: pageImageNotatingView.imageButton_DL.center * ((pageImageModel?.originalImage.size.width)! / pageImageNotatingView.bounds.width),
                p_DR: pageImageNotatingView.imageButton_DR.center * ((pageImageModel?.originalImage.size.width)! / pageImageNotatingView.bounds.width))
            pageImageModel?.upperLowerSeperateThreshold = ((pageImageModel?.notationPoints?.p_UL.y)! + (pageImageModel?.notationPoints?.p_DL.y)!) / 2
            pageImageModel?.pointsNotationImage = pageImageModel?.getNotatedImage()
            if let dvc = segue.destination as? PageImageDrawingViewController {
                dvc.pageImageModel = self.pageImageModel!
            }
        }
        
    }

}


public extension CGPoint {
    
    static func * (_ p: CGPoint, _ n: CGFloat) -> CGPoint {
        return CGPoint(x: p.x * n, y: p.y * n)
    }
    
}
