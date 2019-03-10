*Written by: __Nguyen Minh Tam__*

# <img src="https://github.com/nmint8m/rxswiftdiary/blob/master/Image/img-rx.png" height ="30"> Section 1: Getting started with RxSwift

## <img src="https://github.com/nmint8m/rxswiftdiary/blob/master/Image/img-rx.png" height ="25"> Chapter 2: Observables

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

![Image 1][Image 1]

Trong ví dụ trên, observable phát ra 3 element. Khi observable phát ra 1 element, có nghĩa là nó đang thực hiện một tác vụ next event.

Sau đây là marble diagram khác, nhưng lần này observable được kết thúc bởi một đường kẻ dọc ở phía cuối.

![Image 2][Image 2]

Observable phát ra 3 event và kết thúc. Gọi là completed event bởi vì sau đó observable này đã kết thúc và không phát thêm bất kỳ một event nào cả. Kết thúc trong trường hợp này là loại kết thúc bình thường. Tuy nhiên, trong một số trường hợp có lỗi phát sinh:

![Image 3][Image 3]

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

## More

Quay lại chapter trước [Chapter 1: Hello RxSwift][Chapter 1]

Đi đến chapter sau [Chapter 3: Subjects][Chapter 3]

Quay lại [RxSwiftDiary's Menu][Diary]

---
[Chapter 1]: https://github.com/nmint8m/rxswiftdiary/blob/master/Diary/Section1-Chapter1.md "Hello RxSwift"
[Chapter 3]: https://github.com/nmint8m/rxswiftdiary/blob/master/Diary/Section1-Chapter3.md "Subjects"
[Diary]: https://github.com/nmint8m/rxswiftdiary "RxSwift Diary"

[Image 1]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img1.png "Image 1"
[Image 2]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img2.png "Image 2"
[Image 3]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img3.png "Image 3"
[Image 4]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img4.png "Image 4"
[Image 5]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img5.png "Image 5"
[Image 6]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img6.png "Image 6"
[Image 7]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c2-img7.png "Image 7"


