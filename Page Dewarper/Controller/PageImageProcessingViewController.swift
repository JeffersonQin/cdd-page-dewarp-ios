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
    
    private var width: NSInteger = 0
    private var height: NSInteger = 0
    private var segmentCount: NSInteger = 0
    
    private func process() {
        let alertController = UIAlertController.init(title: "Adjust Size of Output", message: "Type in Width & Height", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Width"
            textField.text = "2100"
        }
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Height"
            textField.text = "2850"
        }
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Segment Count"
            textField.text = "300"
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (_) in
            guard let width: NSInteger = NSInteger((alertController.textFields![0] as UITextField).text!),
                  let height: NSInteger = NSInteger((alertController.textFields![1] as UITextField).text!),
                  let segmentCount: NSInteger = NSInteger((alertController.textFields![2] as UITextField).text!)
            else {
                let errorAlert = UIAlertController.init()
                errorAlert.addAction(UIAlertAction.init(title: "Wrong Format", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            self.width = width
            self.height = height
            self.segmentCount = segmentCount
            self.progressHUD.show(in: self.view, animated: true)
            Thread.init {
                let showImage = JQCV.getPreProcessResult(self.pageImageModel?.originalImage, self.pageImageModel?.drawingNotationImage, self.pageImageModel!.upperLowerSeperateThreshold, (self.pageImageModel?.notationPoints!.p_UL)!, (self.pageImageModel?.notationPoints!.p_UR)!, (self.pageImageModel?.notationPoints!.p_DL)!, (self.pageImageModel?.notationPoints!.p_DR)!, self.width, self.height, self.segmentCount, self.progressHUD)
                DispatchQueue.main.async {
                    self.pageImageView.showingImage = showImage!
                    UIImageWriteToSavedPhotosAlbum(self.pageImageView.showingImage, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                    self.progressHUD.dismiss(animated: true)
                }
            }.start()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func adjustButtonTouched(_ sender: UIBarButtonItem) {
        self.process()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageImageView.showingImage = pageImageModel!.pointsNotationImage!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.process()
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
