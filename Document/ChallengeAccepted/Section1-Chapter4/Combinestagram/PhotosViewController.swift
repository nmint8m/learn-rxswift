/*
 * Copyright (c) 2016-present Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Photos
import RxSwift

class PhotosViewController: UICollectionViewController {

    // MARK: public properties
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    var bag = DisposeBag()

    // MARK: private properties
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()

    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()

    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }

    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // # Reload the photos collection when access is granted
        let authorize = PHPhotoLibrary.authorized.share()
        authorize
            .skipWhile { return !$0 }
            .take(1).subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.photos = PhotosViewController.loadPhotos()
                    this.collectionView?.reloadData()
                }
            }).disposed(by: bag)
        // # Display an error message if the user doesnʼt grant access
        authorize
            .skip(1)
            .takeLast(1)
            .filter { return !$0 }
            .subscribe(onNext: { [weak self] _ in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.errorMessage()
                }
            }
        ).disposed(by: bag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
    }

    // MARK: UICollectionView

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell

        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)

        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }

        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool,
                !isThumbnail {
                self?.selectedPhotosSubject.onNext(image)
            }
        })
    }

    // # Display an error message if the user doesnʼt grant access
    private func errorMessage() {
        alert(title: "No access to Camera Roll",
              message: "You can grant access to Combinestagram from the Settings app")
            // # Completing a subscription after given time interval
            .take(5, scheduler: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
}

