//
//  HomeTableViewController.swift
//  Page Dewarpper
//
//  Created by Jefferson Qin on 2020/4/6.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

import UIKit
import Floaty
import JGProgressHUD

class HomeTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let floaty = Floaty()
        floaty.addItem("New doc from camera", icon: #imageLiteral(resourceName: "camera")) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .camera
                self.present(cameraPicker, animated: true, completion: nil)
            }
        }
        floaty.addItem("Import from album", icon: #imageLiteral(resourceName: "album")) { (_) in
            let photoPicker =  UIImagePickerController()
            photoPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            photoPicker.sourceType = .photoLibrary
            self.present(photoPicker, animated: true, completion: nil)
        }
        floaty.sticky = true;
        floaty.openAnimationType = .slideUp
        floaty.friendlyTap = true
        floaty.plusColor = UIColor.white
        floaty.buttonColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        self.tableView.addSubview(floaty)
        floaty.isHidden = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1058823529, green: 0.3294117647, blue: 0.5764705882, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let progressHUD = JGProgressHUD.init(style: .dark)
        progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView.init()
        progressHUD.textLabel.text = "Build Version"
        progressHUD.detailTextLabel.text = versionCode
        progressHUD.show(in: self.view, animated: true)
        progressHUD.dismiss(afterDelay: 2.0, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true, completion:nil)
        if image != nil {
            self.performSegue(withIdentifier: "imageSegue", sender: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCellIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "imageSegue" {
            if let dvc = segue.destination as? PageImageNotatingViewController {
                dvc.originalImage = JQCV.getImage(image, false)
            }
        }
    }

}
