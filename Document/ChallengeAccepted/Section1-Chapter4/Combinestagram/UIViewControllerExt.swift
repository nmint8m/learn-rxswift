//
//  UIViewControllerExt.swift
//  Combinestagram
//
//  Created by Tam Nguyen M. on 6/30/19.
//  Copyright © 2019 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {

    /*
    // # Chapter 4: Challenge 2: Add custom observable to present alerts
    func alert(title: String = "",
               message: String = "") -> Completable {
        return Completable.create { [weak self] completable in
            guard let this = self else {
                completable(.completed)
                return Disposables.create()
            }
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
                completable(.completed)
            }
            alert.addAction(action)
            this.present(alert, animated: true, completion: nil)
            return Disposables.create()
        }
    }
    */

    func alert(title: String = "",
               message: String = "") -> Observable<Bool> {
        return Observable.create { [weak self] observable in
            guard let this = self else {
                observable.onCompleted()
                return Disposables.create()
            }
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
                observable.onCompleted()
            }
            alert.addAction(action)
            this.present(alert, animated: true, completion: nil)
            return Disposables.create()
        }
    }
}

