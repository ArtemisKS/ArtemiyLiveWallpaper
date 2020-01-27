//
//  AssetSelectionViewController.swift
//  ArtemiyLiveWallpapers
//
//  Created by Artem Kuprijanets on 1/26/20.
//  Copyright © 2020 Artem Kuprijanets. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos
import SwiftMessages
import MobileCoreServices
import collection_view_layouts
import SKPhotoBrowser

enum SelectionType {
  case gif
  case video
  case images
}

let maxPhotosNum = 7

class AssetSelectionVC: UIViewController {
  
  @IBOutlet var collectionView: UICollectionView!
  
  var images = [UIImage]()
  var skImages = [SKPhoto]()
  var selectedPhotoAssets = [TLPHAsset]()
  var selectedAsset: PHAsset?
  
  var tempAssetUrl: URL?
  var isPhotoAcceddAllowed = true {
    didSet {
      DispatchQueue.main.async {
        self.logoView.isHidden = true
        self.allowPhotoAccesView.isHidden = false
      }
    }
  }
  
  lazy var allowPhotoAccesView: AllowLibraryAccessView = {
    let view = AllowLibraryAccessView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  var seletedAssetType: SelectionType? {
    didSet {
      
      if seletedAssetType != .images {
        routeToEditorVC(withVideo: true)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.selectedPhotoAssets = [TLPHAsset]()
    selectedAsset = nil
    viewController.tempPhotoAssets = [PHAsset]()
  }
  
  lazy var logoView: UIImageView = {
    let view = UIImageView(image: UIImage(named: "ic_Logo"))
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UIApplication.shared.keyWindow?.backgroundColor = view.mainColor
//    applyLogoInTitleView()
//    view.applyMainAppTheme()
    // Normally in viewDidLayoutSubviews(), but here OK in viewDidLoad
    setupViewsConstr()
    allowPhotoAccesView.isHidden = true
    
    confCollectionView()
    confPicker()
    confNavBar()
    setupImages()
  }
  
  lazy var viewController: CustomPhotoPickerViewController = {
    let vc = CustomPhotoPickerViewController()
    var configure = TLPhotosPickerConfigure()
    configure.allowedLivePhotos = false
    configure.cancelTitle = ""
    configure.allowedAlbumCloudShared = false
    configure.allowedVideoRecording = false
    configure.maxVideoDuration = 10.0
    configure.maxSelectedAssets = maxPhotosNum
    vc.configure = configure
    return vc
  }()
  
  private func setupImages() {
    
    let imagesCount = 34
    
    for ind in 0..<imagesCount {
      if let image = UIImage(named: "IMG_\(ind)") {
        images.append(image)
        skImages.append(SKPhoto.photoWithImage(image))
      }
    }
  }
  
  private func setupViewsConstr() {
    
    view.addSubview(logoView)
    NSLayoutConstraint.activate([
      
      logoView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      logoView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      logoView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
      logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor)
      
    ])
    
    self.view.addSubview(allowPhotoAccesView)
    NSLayoutConstraint.activate([
      
      allowPhotoAccesView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      allowPhotoAccesView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      allowPhotoAccesView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.85),
      allowPhotoAccesView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45)
    ])
  }
  
  private func confCollectionView() {
    
    let layout: BaseLayout = InstagramLayout()

    layout.delegate = self
    layout.cellsPadding = ItemsPadding(horizontal: 2, vertical: 2)

    collectionView.collectionViewLayout = layout
    collectionView.reloadData()
  }
  
  private func confPicker() {
    
    viewController.delegate = self
    viewController.logDelegate = self
  }
  
  private func confNavBar() {
    
    let rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(openGalleryPicker))
    
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }
  
  @objc private func openGalleryPicker() {
    
    if isPhotoAcceddAllowed {
      let embeddedVc = UINavigationController(rootViewController: viewController)
      DispatchQueue.main.async {
        self.present(embeddedVc, animated: true, completion: nil)
      }
      
    }
    
  }
  
  private func confAssetEditor() -> UIViewController {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "AssetEditorViewController") as! AssetEditorVC
    vc.isPhotoAssetSelected = false
    vc.selectedAsset = self.selectedAsset
    vc.selectionType = self.seletedAssetType
    return vc
  }
  
  private func confAssetEditorVC(withTLPHAssets assets: [TLPHAsset]) -> UIViewController {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "AssetEditorViewController") as! AssetEditorVC
    vc.isPhotoAssetSelected = true
    vc.selectedAsset = nil
    vc.selectionType = .images
    vc.selectedPhotoAssets = assets
    return vc
  }
  
  private func routeToEditorVC(
    withVideo: Bool,
    withTLPHAssets assets: [TLPHAsset]? = nil) {
    
    let vc = withVideo ?
      confAssetEditor() : confAssetEditorVC(withTLPHAssets: assets!)
    viewController.quitCurrentVC {
      DispatchQueue.main.async {
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
  
}

//MARK: - TLPhotosPickerViewControllerDelegate
extension AssetSelectionVC: TLPhotosPickerViewControllerDelegate {
  
  func dismissPhotoPicker(withTLPHAssets assets: [TLPHAsset]) {
    
    self.selectedPhotoAssets = assets
    routeToEditorVC(withVideo: false, withTLPHAssets: assets)
  }
  
  func dismissPhotoPicker(withPHAssets: [PHAsset]) {}
  
  func photoPickerDidCancel() {}
  
  func dismissComplete() {}
  
  func canSelectAsset(phAsset: PHAsset) -> Bool {
    
    
    switch phAsset.mediaType {
    case .image:
      
      if let identifier = phAsset.value(forKey: "uniformTypeIdentifier") as? String
      {
        if identifier == kUTTypeGIF as String
          
        {   if self.viewController.tempPhotoAssets.count >= 1 {
          SwiftMessages.showToast("Video and Gifs can only be selected individually.", type: .warning)
          return false
          }
          
          self.selectedAsset = phAsset
          self.seletedAssetType = .gif
        }
      }
      if (phAsset.mediaSubtypes == .photoLive) {
        return false
        
      }else {
        self.viewController.tempPhotoAssets.append(phAsset)
      }
      
      
    case .video:
      if self.viewController.tempPhotoAssets.count >= 1 {
        SwiftMessages.showToast("Video and Gifs can only be selected individually.", type: .warning)
        return false
      }
      
      self.selectedAsset = phAsset
      self.seletedAssetType = .video
    default:
      print("Unknown")
    }
    return true
  }
  
  func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
    SwiftMessages.showToast("Photos Selection Limit is \(maxPhotosNum).", type: .warning)
  }
  
  func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
    
    self.isPhotoAcceddAllowed = false
    self.dismiss(animated: false, completion: nil)
  }
  
  func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {}
}

//MARK: - UICollectionViewDataSource
extension AssetSelectionVC: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: String(describing: PhotoCVC.self),
      for: indexPath) as! PhotoCVC
    
    cell.setCell(image: images[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
}

//MARK: - LayoutDelegate
extension AssetSelectionVC: LayoutDelegate {
  
  func cellSize(indexPath: IndexPath) -> CGSize {
    return .zero
  }
}

//MARK: - UICollectionViewDelegate
extension AssetSelectionVC: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let ind = indexPath.row
    if let cell = collectionView.cellForItem(at: indexPath) {
      
      let image = images[ind]
      let browser = SKPhotoBrowser(originImage: image, photos: skImages, animatedFromView: cell)
      browser.initializePageIndex(indexPath.row)
      present(browser, animated: true)
    }
  }
}

//MARK: - TLPhotosPickerLogDelegate
extension AssetSelectionVC: TLPhotosPickerLogDelegate{
  
  func selectedCameraCell(picker: TLPhotosPickerViewController) {}
  
  func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
    
    if self.viewController.tempPhotoAssets.count >= 1{
      self.viewController.tempPhotoAssets.removeLast()
    }
  }
  
  func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {}
  
  func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {}
  
  
}


extension PHAsset {
  
  func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
    if self.mediaType == .image {
      let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
      options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
        return true
      }
      self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
        completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
      })
    } else if self.mediaType == .video {
      let options: PHVideoRequestOptions = PHVideoRequestOptions()
      options.version = .original
      PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
        if let urlAsset = asset as? AVURLAsset {
          let localVideoUrl: URL = urlAsset.url as URL
          completionHandler(localVideoUrl)
        } else {
          completionHandler(nil)
        }
      })
    }
  }
}


class CustomPhotoPickerViewController: TLPhotosPickerViewController {
  
  var isFirstLoaded = false
  var tempPhotoAssets = [PHAsset]()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    if isFirstLoaded {
      self.selectedAssets =  [TLPHAsset]()
      self.tempPhotoAssets = [PHAsset]()
      self.collectionView.reloadData()
      
    }
    self.isFirstLoaded = true
  }
  
  override func makeUI() {
    super.makeUI()
    self.customNavItem.rightBarButtonItem = UIBarButtonItem(
      title: "Next",
      style: .done,
      target: self,
      action: #selector(handleNextButtonTapped))
    self.customNavItem.leftBarButtonItem?.isEnabled = false
    applyLogoInTitleView()
  }
  
  @objc func handleNextButtonTapped() {
    
    if selectedAssets.isEmpty { return }
    DispatchQueue.main.async {
      self.delegate!.dismissPhotoPicker(withTLPHAssets: self.selectedAssets)
    }
    
  }
  
}

class AllowLibraryAccessView: UIView {
  
  lazy var topLable: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 26)
    label.adjustsFontSizeToFitWidth = true
    label.textColor = .white
    label.text = "Please Allow Photo Library Access"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var midLable: UILabel = {
    let label = UILabel()
    label.text = "This allow ReShape to access all photos and videos from your Photos app to let you create live photos."
    label.numberOfLines = 0
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var bottomLable: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 26)
    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 0
    label.text = "Setting > Privacy > Photos > ReShape > Read and Write"
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var logoView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.image = UIImage(named: "ic_Logo")
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(logoView)
    NSLayoutConstraint.activate([
      logoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      logoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      logoView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.4),
      logoView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)
    ])
    
    self.addSubview(topLable)
    NSLayoutConstraint.activate([
      topLable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      topLable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      topLable.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.15),
      topLable.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 10)
    ])
    
    self.addSubview(midLable)
    NSLayoutConstraint.activate([
      midLable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      midLable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      midLable.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25),
      midLable.topAnchor.constraint(equalTo: topLable.bottomAnchor, constant: 10)
    ])
    
    self.addSubview(bottomLable)
    NSLayoutConstraint.activate([
      bottomLable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      bottomLable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      bottomLable.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      bottomLable.topAnchor.constraint(equalTo: midLable.bottomAnchor, constant: 10)
    ])
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
