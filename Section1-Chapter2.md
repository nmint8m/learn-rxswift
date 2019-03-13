*Written by: __Nguyen Minh Tam__*

# <img src="./Image/img-rx.png" height ="30"> Section 1: Getting started with RxSwift

## <img src="./Image/img-rx.png" height ="25"> Chapter 2: Observables

Trong chapter này, bạn sẽ lướt qua nhiều ví dụ tạo và subcribing observable. Mặc dù observable sử dụng trong real world nhiều trường hợp khá là chuối, cơ mà những phần còn lại sẽ giúp chúng ta đạt được những skill quan trọng và biết được kha khá các loại observable khác nhau.

Trước khi đi vào tìm hiểu sâu hơn, đầu tiên chúng ta cùng tìm hiểu `Observable` là gì đã.

### Getting started

### What is an observable

Các khái niệm như `observable`, `observable sequence` hay `sequence` có thể sử dụng thay thế cho nhau trong Rx, và thật ra thì chúng là cùng một thứ. À mà còn nữa, bạn sẽ thấy khái niệm `stream` được nhắc đến nhiều, đặc biệt là từ những developer đã biết đến reactive programming environment khác trước khi làm quen với RxSwift. `Stream` cũng tương tự như những khái niệm trên, nhưng đối với RxSwift thì chúng ta hay gọi nó là `sequence` chứ không phải `stream` cho nó ngầu. Nói tóm lại là, đối với RxSwift:

```
Everything is a sequence
```

hoặc là những thứ làm việc với một `sequence`. `Observable` là `sequence` kết hợp với vài quyền năng đặc biệt. Một quyền năng quan trọng nhất trong số đó là tính bất đồng bộ. `Observable` phát ra event xuyên suốt một khoảng thời gian. Các event ở đây có thể chứa dữ liệu, ví dụ như `Observable<Int>` có thể chứa số nguyên, hay `Observable<Developer>` chứa instance của kiểu Developer, hoặc nó có thể nhận các gesture như tap chả hạn.

### Lifecycle of an observable

Để mô tả observable một cách trực quan, ta sử dụng marble diagram như sau:

<center>
	<img src="./Image/Section1/c2-img1.png" height="200">
</center>

Trong ví dụ trên, observable phát ra 3 element. Khi observable phát ra 1 element, có nghĩa là nó đang thực hiện một tác vụ next event.

Sau đây là marble diagram khác, nhưng lần này observable được kết thúc bởi một đường kẻ dọc ở phía cuối.

<center>
	<img src="./Image/Section1/c2-img2.png" height="200">
</center>

Observable phát ra 3 event và kết thúc. Gọi là completed event bởi vì sau đó observable này đã kết thúc và không phát thêm bất kỳ một event nào cả. Kết thúc trong trường hợp này là loại kết thúc bình thường. Tuy nhiên, trong một số trường hợp có lỗi phát sinh:

<center>
	<img src="./Image/Section1/c2-img3.png" height="200">
</center>

Một error được biểu thị trên marble diagram bằng dấu X màu đỏ. Observable phát ra một error event contain error. Nó không khác mấy so với khi observable được kết thúc theo cách bình thường. Khi một observable phát một error event, observable sẽ kết thúc và không phát thêm bất kỳ một event nào nữa.

Tóm tắc cho phần này:

- Observable phát next event có chứa dữ liệu. Nó vẫn có thể tiếp tục hoạt động cho đến khi
 - Phát ra error event và kết thúc, hoặc là
 - Phát ra completed event và kết thúc.
- Khi một observable kết thúc, nó sẽ không phát event nữa.

Ví dụ trong RxSwift source code, những event này được khai báo dưới dạng các case của một enumeration:

```swift
/// Represents a sequence event.
///
/// Sequence grammar:
/// **next\* (error | completed)**
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)
    /// Sequence terminated with an error.
    case error(Swift.Error)
    /// Sequence completed successfully.
    case completed
}
```

Bạn thấy đấy, `.next` event chứa một instance của element nào đó, trong khi `.error` event chứa một instance của `Swift.Error` và cuối cùng là `.completed` event chỉ đơn giản là một sự kiện kết thúc và không chứa bất kỳ data nào.

Ô kề, một observable có thể làm được gì thì các bác đã hiểu rồi đấy. Tiếp theo đây các bác sẽ cùng thôi tạo vài cái observable để xem cụ thể nó hoạt động như nào nhé.

### Creating observables

Quay lại với file `RxSwift.playground` và thêm đoạn:

```swift
let one = 1
let two = 2
let three = 3
let observable1 = Observable<Int>.just(one)
let observable2 = Observable.of(one, two, three)
```

Đoạn trên có nghĩa:
- Khai báo vài integer constant
- Khởi tạo một observable sequence có kiểu Int với duy nhất một element integer `one`
- Khởi tạo một observable sequence với duy nhất một element integer `one`
- Khởi tạo một observable sequence với nhiều element: `one`, `two`, `three`

Method như `just` là type method của kiểu Observable. Tuy nhiên trong Rx, lưu ý là các method đều được gọi là `operator`. Ví dụ số 2 không khai báo kiểu cụ thể, tuy nhiên nó không phải là một array, nó là kiểu `Observable<Int>`. Vậy nên nếu bạn muốn tạo một observable sequence với nhiều element, chỉ cần pass một array vào `of`.


```swift
let observable3 = Observable.of([one, two, three])
```

Option-click vào `observable3` bạn sẽ thấy nó thuộc kiểu `Observable<[Int]>`. Lúc này array là một element, không phải là từng phần tử của nó.

Một operator khác được sử dụng để tạo observable là `from`.

```swift
let observable4 = Observable.from([one, two, three])
```

Tuy nhiên `from` operator lại tạo observable từ kiểu của từng phần tử của array. Option-click vào `observable4` bạn sẽ thấy nó thuộc kiểu `Observable<Int>` thay vì `[Int]`

Lúc này console của playground khá là trống lúc nàt, vì chúng ta chưa print ra thứ gì cả. Chúng ta sẽ thay đổi điều này bằng cách subcribe observable.

## More

Quay lại chapter trước [Chapter 1: Hello RxSwift][Chapter 1]

Đi đến chapter sau [Chapter 3: Subjects][Chapter 3]

Quay lại [RxSwiftDiary's Menu][Diary]

---
[Chapter 1]: ./Section1-Chapter1.md "Hello RxSwift"
[Chapter 3]: ./Section1-Chapter3.md "Subjects"
[Diary]: https://github.com/nmint8m/rxswiftdiary "RxSwift Diary"


