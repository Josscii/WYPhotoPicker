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
        vc.delegate = self
        
        presentViewController(vc, animated: true, completion: nil)
    }
}

extension ViewController: PickerPhotoDelegate {
    func didSelectImages(images: [UIImage]) {
        imageView1.image = images[0]
    }
}
