//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

// # Chapter 5: Challenge 1: 
example(of: "Challenge 1") {

    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )

        return phone
    }

    let input = PublishSubject<Int>()

    // Add your code here
    // Phone numbers can’t begin with 0 — use skipWhile.
    // Each input must be a single-digit number — use filter to only allow elements that are less than 10.
    input
        .asObservable()
        .skipWhile { number -> Bool in
            return number == 0
        }.filter { number -> Bool in
            return number >= 0 && number < 10
        }.take(10)
        .toArray()
        .subscribe(onNext: {
            let phone = phoneNumber(from: $0)
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        }).disposed(by: disposeBag)

    input.onNext(0)
    input.onNext(603)

    input.onNext(2)
    input.onNext(1)
    input.onNext(2)

    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(7)

    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }

    input.onNext(9)
}

/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
