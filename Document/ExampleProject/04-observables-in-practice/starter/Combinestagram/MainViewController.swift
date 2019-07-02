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
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!

    private let disposeBag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    // # Implementing a basic uniqueness filter
    private var imageCache = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Chapter 6: Challenge 1: Combinestagramʼs source code

        let imagesObservable = images.asObservable().share()

        imagesObservable
            .subscribe(onNext: { [weak self] photos in
                guard let this = self else { return }
                this.updateUI(photos: photos)
            }).disposed(by: disposeBag)

        // # Using throttle to reduce work on subscriptions with high load
        imagesObservable
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] photos in
                self.imagePreview.image = UIImage.collage(images: photos,
                                                          size: self.imagePreview.frame.size)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    @IBAction func actionClear() {
        images.value = []
        imageCache = []

        // Chapter 6: Challenge 1: Combinestagramʼs source code
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: nil, style: .done,
                                                           target: nil, action: nil)
    }

    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        /* Original version
        PhotoWriter.save(image)
            .asSingle()
            .subscribe(onSuccess: { [weak self] id in
                self?.showMessage("Saved with id: \(id)")
                self?.actionClear()
                }, onError: { [weak self] error in
                    self?.showMessage("Error", description: error.localizedDescription)
            })
            .disposed(by: disposeBag)
         */

        // Challenge 2: Add custom observable to present alerts
        PhotoWriter
            .save(image)
            .subscribe(
                onSuccess: { [weak self] id in
                    self?.showMessage("Saved with id: \(id)")
                    self?.actionClear()
                }, onError: { [weak self] error in
                    self?.showMessage("Error", description: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func actionAdd() {
        guard let viewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController else { return }
        /* Original code
        viewController.selectedPhotos
            .subscribe(
                onNext: { [weak self] newImage in
                    guard let this = self else { return }
                    this.images.value.append(newImage)
                },
                onDisposed: {
                    print("Completed photo selection")
            }).disposed(by: disposeBag)
        navigationController?.pushViewController(viewController, animated: true)
         */

        // # Sharing subscriptions
        let shareSelectedPhotos = viewController.selectedPhotos.share()
        shareSelectedPhotos
            // # Keep taking elements while a condition is met
            .takeWhile{ [weak self] _ in
                guard let this = self else { return false }
                return this.images.value.count < 6
            }
            // # Filtering elements you donʼt need
            .filter { newImage in
                return newImage.size.width > newImage.size.height
            }
            // # Implementing a basic uniqueness filter
            .filter { [weak self] newImage in
                guard let this = self else { return false }
                let imageLenght = UIImagePNGRepresentation(newImage)?.count ?? 0
                guard !this.imageCache.contains(imageLenght) else {
                    return false
                }
                this.imageCache.append(imageLenght)
                return true
            }
            .subscribe(
            onNext: { [weak self] newImage in
                guard let this = self else { return }
                this.images.value.append(newImage)
            },
            onDisposed: {
                print("Completed photo selection")
            }).disposed(by: disposeBag)

        shareSelectedPhotos
            // # Ignoring all elements
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                guard let this = self else { return }
                this.updateNavigationIcon()
            }).disposed(by: viewController.bag)

        navigationController?.pushViewController(viewController, animated: true)
    }

    func showMessage(_ title: String, description: String = "") {
        /* Original code
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
        present(alert, animated: true, completion: nil)
         */
        // # Chapter 4: Challenge 2: Add custom observable to present alerts
        alert(title: title, message: description)
            .subscribe(onCompleted: { [weak self] in
                guard let this = self else { return }
                this.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    // # Ignoring all elements
    private func updateNavigationIcon() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done,
                                                           target: nil, action: nil)
    }
}

