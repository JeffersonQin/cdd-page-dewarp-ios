//
//  PageImageProcessingViewController.swift
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/4/1.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit
import JGProgressHUD

class PageImageProcessingViewController: UIViewController {

    
    @IBOutlet var pageImageView: PageImageView!
    
    var pageImageModel: PageImageModel?
    
    let progressHUD = JGProgressHUD.init(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageImageView.showingImage = pageImageModel!.pointsNotationImage!
        progressHUD.show(in: self.view, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Thread.init {
            let showImage = JQCV.getPreProcessResult(self.pageImageModel?.originalImage, self.pageImageModel?.drawingNotationImage, self.pageImageModel!.upperLowerSeperateThreshold, (self.pageImageModel?.notationPoints!.p_UL)!, (self.pageImageModel?.notationPoints!.p_UR)!, (self.pageImageModel?.notationPoints!.p_DL)!, (self.pageImageModel?.notationPoints!.p_DR)!, self.progressHUD)
            DispatchQueue.main.async {
                self.pageImageView.showingImage = showImage!
                UIImageWriteToSavedPhotosAlbum(self.pageImageView.showingImage, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                self.progressHUD.dismiss(animated: true)
            }
        }.start()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
