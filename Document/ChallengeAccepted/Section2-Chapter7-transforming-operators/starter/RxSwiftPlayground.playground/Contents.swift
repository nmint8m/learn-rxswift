//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

example(of: "toArray") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3)
        .toArray()
        .subscribe(onNext: {
            print($0) })
        .disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    Observable<NSNumber>.of(1, 21, 321)
        .map {
            formatter.string(from: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map { index, integer in
            (index + 1) * integer
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

struct Student {
    var score: BehaviorSubject<Int>
}

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    let student = PublishSubject<Student>()
    student
        .flatMap {
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    student.onNext(ryan)
    student.onNext(charlotte)
    ryan.score.onNext(95)
    ryan.score.onNext(100)
}

example(of: "flatMapLatest") {
    let disposeBag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    let student = PublishSubject<Student>()
    student
        .flatMapLatest {
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    student.onNext(ryan)
    student.onNext(charlotte)
    ryan.score.onNext(95)
    charlotte.score.onNext(100)
}

example(of: "materialize and dematerialize") {
    enum MyError: Error {
        case anError
    }

    let disposeBag = DisposeBag()
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    let student = BehaviorSubject(value: ryan)

    let studentScore = student
        .flatMapLatest {
            $0.score.materialize()
    }

    studentScore
        /* Original
        .subscribe(onNext: {
            print($0)
        })
         */
        .filter {
            guard let error = $0.error else {
                return true
            }
            print(error)
            return false
        }
        .dematerialize()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError)
    ryan.score.onNext(90)

    student.onNext(charlotte)
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
