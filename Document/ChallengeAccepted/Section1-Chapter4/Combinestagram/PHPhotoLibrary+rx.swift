//
//  PHPhotoLibrary+rx.swift
//  Combinestagram
//
//  Created by Tam Nguyen M. on 6/30/19.
//  Copyright © 2019 Underplot ltd. All rights reserved.
//

import Foundation
import Photos
import RxSwift

// # PHPhotoLibrary authorization observable
extension PHPhotoLibrary {

    static var authorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization { status in
                        observer.onNext(status == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}

