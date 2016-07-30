//
//  PickerViewController.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/28.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func present(sender: AnyObject) {
        
        let vc = PickerViewController()
        // vc.delegate = self
        vc.startPickingPhotos(self)
    }
}

extension ViewController: PickerViewControllerDelegate {
    func didFinishPickingImages(images: [UIImage]) {
        imageView1.image = images[0]
    }
    
    func didCancel() {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView1.image = image
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}