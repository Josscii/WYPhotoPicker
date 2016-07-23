//
//  ViewController.swift
//  WYPhotoPicker
//
//  Created by Josscii on 16/5/26.
//  Copyright © 2016年 Josscii. All rights reserved.
//

import UIKit
import Photos

enum PickerConstants {
    static let screenWidth = UIScreen.mainScreen().bounds.width
    static let selectionModeHeight: CGFloat = 232.5
    static let viewModeHeight: CGFloat = 191
    static let pickerCellIdentifier = "PickerCell"
}

protocol PickerViewControllerDelegate: class {
    func didFinishPickingImages(images: [UIImage])
    func didCancel()
}

class PickerViewController: UIViewController {
    // Properties
    
    var collectionView: PickerCollectionView!
    var layout: PickerLayout!
    var tableView: UITableView!
    
    var assets = [PHAsset]()
    var photos = [UIImage?]()
    var widths = [CGFloat]()
    
    weak var delegate: PickerViewControllerDelegate?
    
    var transitionDelegate: PickerTransitionDelegate?
    
    // Life cycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // custom transition
        transitionDelegate = PickerTransitionDelegate()
        transitioningDelegate = transitionDelegate
        modalPresentationStyle = .Custom
        
        // layout
        layout = PickerLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        configureLayout()
    }
    
    func configureLayout() {
        // view for tap to dismiss
        let tapView = UIView(frame: view.bounds)
        tapView.backgroundColor = UIColor.clearColor()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapView.addGestureRecognizer(gesture)
        view.addSubview(tapView)
        
        // tableview
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
        
        collectionView.heightConstraint = NSLayoutConstraint(item: collectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: PickerConstants.viewModeHeight)
        
        collectionView.heightConstraint?.active = true
    }
}

extension PickerViewController {
    
    func startPickingPhotos(on: ViewController) {
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
                self.widths = [CGFloat](count: self.assets.count, repeatedValue: 0)
                
                dispatch_async(dispatch_get_main_queue(), {
                    on.presentViewController(self, animated: true, completion: nil)
                })
            case .Restricted, .Denied:
                dispatch_async(dispatch_get_main_queue(), {
                    let alertAction = UIAlertAction(title: "好的", style: .Default, handler: nil)
                    let alertController = UIAlertController(title: nil, message: "请在iPhone的“设置-隐私-相机”选项中，允许本应用访问你的相机", preferredStyle: .Alert)
                    alertController.addAction(alertAction)
                    on.presentViewController(alertController, animated: true, completion: nil)
                    self.delegate?.didCancel()
                })
                break
            default:
                // place for .NotDetermined - in this callback status is already determined so should never get here
                break
            }
        }
    }
    
    func targetSizeForAsset(asset: PHAsset) -> CGSize {
        let scale = UIScreen.mainScreen().scale
        let width = CGFloat(asset.pixelWidth) / scale
        let height = CGFloat(asset.pixelHeight) / scale
        
        let ratio = width / height
        
        let targetHeight = (collectionView.selectionMode ? PickerConstants.selectionModeHeight : PickerConstants.viewModeHeight) - 10
        
        return CGSize(width: targetHeight * ratio, height: targetHeight)
    }
}

// MARK: tableview delegate and datasource
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
                
                for index in collectionView.seletedIndexPaths {
                    selectedImages.append(photos[index.item]!)
                }
                
                delegate?.didFinishPickingImages(selectedImages)
                
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

// MARK: imagePikerdelegate
extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        delegate?.didFinishPickingImages([image])
        
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
        
        if let photo = photos[indexPath.row] {
            cell.imageView.image = photo
        } else {
            let asset = assets[indexPath.item]
            
            let option = PHImageRequestOptions()
            option.resizeMode = .Exact
            
            var targetSize = targetSizeForAsset(asset)
            targetSize.width *= 2
            targetSize.height *= 2
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .Default, options: option) {
                (image, info) -> Void in
                // what you want to do with the image here
                
                if info!["PHImageResultIsDegradedKey"]?.integerValue == 0 {
                    self.photos[indexPath.row] = image
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView.image = image
                })
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        layout?.toCenterIndexPath = indexPath
        tableView.reloadData()
        
        if self.collectionView.seletedIndexPaths.contains(indexPath) {
            self.collectionView.seletedIndexPaths.remove(indexPath)
            layout?.invalidateLayout()
        } else {
            self.collectionView.seletedIndexPaths.append(indexPath)
            
            if !self.collectionView!.selectionMode {
                self.collectionView!.selectionMode = true
                
                self.layout?.invalidateLayout()
                UIView.animateWithDuration(0.3, animations: {
                    self.collectionView?.heightConstraint?.constant = PickerConstants.selectionModeHeight + 1 // plus 1 to avoid warnings on ip6sp
                    self.collectionView?.layoutIfNeeded()
                    }, completion: { _ in
                        self.layout?.invalidateLayout()
                })
                
                tableView.reloadData()
            } else {
                
                layout?.invalidateLayout()
                
                self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            }
        }
    }
}

extension PickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let asset = assets[indexPath.row]
        let targetSize = targetSizeForAsset(asset)
        widths[indexPath.row] = targetSize.width
        
        return targetSize
    }
}

extension PickerViewController {
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension Array where Element: Equatable {
    mutating func remove(element: Element) {
        if let index = indexOf(element) {
            removeAtIndex(index)
        }
    }
}