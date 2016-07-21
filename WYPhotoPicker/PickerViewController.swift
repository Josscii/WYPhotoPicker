//
//  ViewController.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/26.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit
import Photos

let screenWidth = UIScreen.mainScreen().bounds.width
let viewModeSize = CGSize(width: 86, height: 129)
let selectionModeSize = CGSize(width: screenWidth/2, height: 232.5)

protocol PickerPhotoDelegate: class {
    func didSelectImages(images: [UIImage])
}

class PickerViewController: UIViewController {
    var collectionView: PickerCollectionView!
    var tableView: UITableView!
    var layout: NewPickerLayout?
    
    var assets = [PHAsset]()
    var photos = [UIImage?]()
    
    weak var delegate: PickerPhotoDelegate?
    
    var transitionDelegate: PickerTransitionDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // custom transition
        transitionDelegate = PickerTransitionDelegate()
        transitioningDelegate = transitionDelegate
        modalPresentationStyle = .Custom
        layout = NewPickerLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var widths: [CGFloat] = []
    
    var selectionModeHeight: CGFloat = 232.5
    var viewModeHeight: CGFloat = 191
    
    let scale = UIScreen.mainScreen().scale
    
    func targetSizeForAsset(asset: PHAsset) -> CGSize {
        
        let width = CGFloat(asset.pixelWidth) / scale
        let height = CGFloat(asset.pixelHeight) / scale
        
        let ratio = width / height
        
        let targetHeight = (collectionView.selectionMode ? selectionModeHeight : viewModeHeight) - 10
        
        return CGSize(width: targetHeight  * ratio, height: targetHeight)
    }
    
    func beginPickingPhotos(authorizationResult: Bool -> ()) {
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .Authorized:
                
                let options = PHFetchOptions()
                let pred = NSPredicate(format: "mediaType = %@", NSNumber(integer:PHAssetMediaType.Image.rawValue))
                options.predicate = pred
                
                let results = PHAsset.fetchAssetsWithOptions(options)
                
                results.enumerateObjectsUsingBlock { result, index, _ in
                    let asset = result as! PHAsset
                    self.assets.insert(asset, atIndex: 0)
                }
                
                self.photos = [UIImage?](count: self.assets.count, repeatedValue: nil)
                
                dispatch_async(dispatch_get_main_queue(), {
                    authorizationResult(true)
                })
            case .Restricted, .Denied:
                dispatch_async(dispatch_get_main_queue(), {
                    authorizationResult(false)
                })
            default:
                // place for .NotDetermined - in this callback status is already determined so should never get here
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.clearColor()
        
        configureLayout()
    }
    
    func configureLayout() {
        let tapView = UIView(frame: view.bounds)
        tapView.backgroundColor = UIColor.clearColor()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapView.addGestureRecognizer(gesture)
        
        view.addSubview(tapView)
        
        tableView = UITableView(frame: CGRect.zero, style: .Plain)
        tableView.rowHeight = 50
        tableView.scrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(PickerTableViewCell.self, forCellReuseIdentifier: "cell1")
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        // iOS 9
        if #available(iOS 9.0, *)
        {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        collectionView = PickerCollectionView(frame: CGRect.zero, collectionViewLayout: layout!)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.registerClass(PickerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        collectionView?.allowsMultipleSelection = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false

        for subview in [tableView, collectionView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
            
            NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0).active = true
            
            NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0).active = true
        }
        
        // tableview
        
        NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150).active = true
        
        // collectionview 
        NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: tableView, attribute: .Top, multiplier: 1, constant: 0).active = true
        
        collectionView.heightConstraint = NSLayoutConstraint(item: collectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: viewModeHeight)
        
        collectionView.heightConstraint?.active = true
    }
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! PickerTableViewCell
        
        var text = ""
        
        if !collectionView.selectionMode {
            switch indexPath.row {
            case 0:
                text = "相册"
            case 1:
                text = "相机"
            default:
                text = "取消"
            }
        } else {
            switch indexPath.row {
            case 0:
                if collectionView.indexPathsForSelectedItems()!.isEmpty {
                    text = "发送"
                } else {
                    text = "发送 \(collectionView.indexPathsForSelectedItems()!.count) 张照片"
                }
            case 1:
                text = "相机"
            default:
                text = "取消"
            }
        }
        
        cell.titleLabel.text = text
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !collectionView.selectionMode {
            switch indexPath.row {
            case 0:
                let picker = UIImagePickerController()
                picker.sourceType = .PhotoLibrary
                picker.delegate = self
                dismissViewControllerAnimated(true, completion: nil)
                
                guard let delegateVC = delegate as? UIViewController else { return }
                
                delegateVC.presentViewController(picker, animated: true, completion: nil)
            case 1:
                let cam = UIImagePickerControllerSourceType.Camera
                let ok = UIImagePickerController.isSourceTypeAvailable(cam)
                if (!ok) {
                    print("no camera")
                    return
                }
                
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.delegate = self
                presentViewController(picker, animated: true, completion: nil)
            default:
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            switch indexPath.row {
            case 0:
                var selectedImages = [UIImage]()
                
                if let selectedImagesIndex = collectionView.indexPathsForSelectedItems() {
                    for index in selectedImagesIndex {
                        // cellforItemAtIndexPath 只能返回在屏幕内的 cell
                        /*
                         if let cell = collectionView.cellForItemAtIndexPath(index) as? PickerCell,
                         let image = cell.imageView.image {
                         selectedImages.append(image)
                         
                         print(index)
                         }
                         */
                        
                        selectedImages.append(photos[index.item]!)
                    }
                }
                
                delegate?.didSelectImages(selectedImages)
                
                dismissViewControllerAnimated(true, completion: nil)
            case 1:
                let cam = UIImagePickerControllerSourceType.Camera
                let ok = UIImagePickerController.isSourceTypeAvailable(cam)
                if (!ok) {
                    print("no camera")
                    return
                }
                
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.delegate = self
                presentViewController(picker, animated: true, completion: nil)
            default:
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        delegate?.didSelectImages([image])
        
        dismiss()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss()
    }
}

extension PickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PickerCell
        
        let asset = assets[indexPath.item]
        
        cell.delegate = self
        
        let option = PHImageRequestOptions()
        option.resizeMode = .Exact
    
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.targetSizeForAsset(asset), contentMode: .Default, options: option) {
            (image, info) -> Void in
            // what you want to do with the image here
            
            if info!["PHImageResultIsDegradedKey"]?.integerValue == 0 {
                // print("Result Size Is \(image!.size)")
                
                self.photos[indexPath.row] = image
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                cell.imageView.image = image
            })
        }
        
        return cell
    }
}

extension PickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let asset = self.assets[indexPath.row]
        
        return targetSizeForAsset(asset)
    }
}

extension PickerViewController: PickerDelegate {
    func invalidateLayout(cell: UICollectionViewCell) {
        tableView.reloadData()
        
        if !collectionView!.selectionMode {
            collectionView!.selectionMode = true
            
            self.layout?.invalidateLayout()
            UIView.animateWithDuration(0.3, animations: { 
                self.collectionView?.heightConstraint?.constant = selectionModeSize.height + 1 // plus 1 to avoid warnings on ip6sp
                
                if let indexPath = self.collectionView?.indexPathForCell(cell) {
                    if !cell.selected {
                        // an workaround
                        let offset = CGPoint(x: CGFloat(max(0, min(CGFloat(self.assets.count - 2), CGFloat(indexPath.item) - 0.5))) * screenWidth/2, y: 0)
                        
                        self.collectionView?.contentOffset = offset
                    }
                }
                
                self.collectionView?.layoutIfNeeded()
            }, completion: { _ in
                self.layout?.invalidateLayout()
            })
            
            tableView.reloadData()
        } else {
            
            layout?.invalidateLayout()
            if let indexPath = collectionView?.indexPathForCell(cell) {

                if !cell.selected {
                    // 用 uiview.animation 改 contentoffset 会有 bug
                    
                    if indexPath.item == 0 && collectionView.contentOffset.x == 0 {
                        // do nothing
                    } else {
                        collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
                    }
                }
            }
        }
    }
}

extension PickerViewController {
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}