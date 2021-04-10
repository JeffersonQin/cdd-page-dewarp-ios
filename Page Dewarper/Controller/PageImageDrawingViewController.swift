//
//  PageImageDrawingViewController.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/3/31.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit

class PageImageDrawingViewController: UIViewController {

    var pan: UIPanGestureRecognizer?
    
    var pageImageModel: PageImageModel?
    
    @IBOutlet var pageImageView: PageImageView!
    
    @IBOutlet var pageImageDrawingView: PageImageDrawingView! {
        didSet {
            pan = UIPanGestureRecognizer.init(target: pageImageDrawingView, action: #selector(PageImageDrawingView.panGestureHandler(panGesture:)))
            pageImageDrawingView.addGestureRecognizer(pan!)
            pan!.isEnabled = true
        }
    }
    
    @IBAction func undoToolButtonTouched(_ sender: UIBarButtonItem) {
        if pageImageDrawingView.pathsOfDrawing.count > 0 {
            pageImageDrawingView.pathsOfDrawing.remove(at: pageImageDrawingView.pathsOfDrawing.count - 1)
            pageImageDrawingView.setNeedsDisplay()
        }
    }
    
    @IBAction func clearToolButtonTouched(_ sender: UIBarButtonItem) {
        pageImageDrawingView.pathsOfDrawing = []
        pageImageDrawingView.setNeedsDisplay()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        PageImageDrawingView.SizeRatio.lineWidthToBoundWidth = CGFloat(sender.value)
        pageImageDrawingView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pageImageView.showingImage = pageImageModel!.pointsNotationImage!
        pageImageView.pageImageDrawingView = pageImageDrawingView
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1056642756, green: 0.3285115659, blue: 0.574674964, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        var showMessage = ""
        if error != nil {
            showMessage = "保存失败"
        } else {
            showMessage = "保存成功"
        }
        print(showMessage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueWithDrawings" {
            let image = getImageFromView(view: self.pageImageDrawingView)
            self.pageImageModel?.drawingNotationImage = JQCV.getResizedImage(image, (self.pageImageModel?.originalImage.size)!, true)
            if let dvc = segue.destination as? PageImageProcessingViewController {
                dvc.pageImageModel = self.pageImageModel
            }
        }
    }
    
}

func getImageFromView(view: UIView) -> UIImage {
    UIGraphicsBeginImageContext(view.bounds.size)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}
