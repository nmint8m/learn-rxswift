*Written by: __Nguyen Minh Tam__*

# Section 1: Getting started with RxSwift

Mục tiêu:

- Những problem của asynchronous programming mà RxSwift nhắm đến.
- Solution.
- Các class cơ bản trong foundation của Rx framework.

## Chapter 1: Hello RxSwift

RxSwift là gì?

> RxSwift is a library for composing asynchronous and event-based code by using observable sequences and functional style operators, allowing for parameterised execution via schedulers.

Nói theo cách dễ hiểu hơn:

> RxSwift, in its essence, simplifies developing asynchronous programs by allowing your code to react to new data and process it in a sequential, isolated manner.
> 
> Hiểu nôm na là: RxSwift giúp đơn giản hoá quá trình phát triển ứng dụng bất đồng bộ bằng cách cho phép code của mình tương tác với data và xử lý chúng theo một cách tuần tự và độc lập.

### I. Introduction to asynchronous programming

Trong app iOS, tại bất cứ thời điểm nào đều xử lý những tác vụ sau:

- Phản hồi với tap vào button
- Ẩn keyboark khi text field mất focus
- Download ảnh lớn từ internet
- Lưu data vào disk
- Play audio

Tất cả những tác vụ này đều có thể cùng diễn ra một lúc. Ví dụ như khi ẩn keyboard, audio đang phát không hề bị dừng cho đến khi animation kết thúc đúng hem? Và những tác vụ khác nhau trên không block lẫn nhau. Bởi vì iOS cung cấp nhiều API có thể thực hiện các tác vụ trên nhiều thread riêng biệt và trên nhiều core khác nhau của CPU.

Rất phức tạp để có thể viết code chạy song song, đặc biệt là những tác vụ cần làm việc trên cùng một data. Rất khó để tranh luận rằng đoạn code nào sẽ update data trước và đoạn nào đọc kết quả sau cùng.

#### 1. Cocoa and UIKit Asynchronous APIs

Apple giúp chúng ta viết asynchronous code bằng các API sau:

- NotificationCenter
- The delegate pattern
- Grand Central Dispatch
- Closures

Bởi vì hầu hết các class và UI component đều hoạt động bất đồng bộ, nên không thể nào quyết định được code của toàn bộ app được chạy như thế nào. Nói tóm lại là, code của app được thực thi khá là lạ lùng, nó phụ thuộc vào rất nhiều nhân tố bên ngoài, ví dụ như user input, network activity, hoặc là event của OS. Mỗi lần user chạy app là một lần code chạy khác vì chính những nhân tố bên ngoài đó.

Dù sao đi nữa thì những API liệt kê ở trên đều vô cùng xuất sắc, đáp ứng được các task chuyên biệt, và nói cho công bằng rằng nó khá là mạnh moẽ so với offer của những platform khác. Cái vấn đề ờ đây là việc code bất đồng bộ sẽ trở nên khó khăn vì Apple cung cấp nhiều API, mà lại không có universal language nào có thể liên kết các API bất đồng bộ này. Vậy nên khá là chắc kèo rằng việc đọc và viết code sẽ khó mà triển được.

![Image 1][Image 1]

Trước khi kết thúc section này và cho ví dụ về ngữ cảnh để dễ hiểu hơn, chúng mình thử so sánh 2 đoạn code sau: `synchronous` và `asynchronous`. 

##### a. Synchronous code

Đoạn code kinh điển mà ai cũng sẽ trải qua một lần trong đời: print mỗi element trong một array. Ví dụ sau đảm bảo được 2 tiêu chí:

- Chạy đồng bộ
- Collection ở đây không thay đổi khi đang chạy vòng lặp. 

```swift
var array = [1, 2, 3]
for number in array {
    print(number)
    array = [4, 5, 6]
}
print(array)
```

Kết quả như sau:

```
1
2
3
[4, 5, 6]
```

##### b. Asynchronous code

Cũng một đoạn code như thế, nhưng giả sử mỗi vòng lặp là một reaction cho một cái tap trên button. Bởi user liên tục tap lên button, app sẽ liên tục print ra element tiếp theo.

```swift
var array = [1, 2, 3]
var currentIndex = 0
//this method is connected in IB to a button
@IBAction func printNext(_ sender: Any) {
  print(array[currentIndex])
  if currentIndex != array.count-1 {
    currentIndex += 1
  }
}
```
Vấn đề cốt lõi mà viết code asynchronous là:

- thứ tự công việc được thực hiện
- shared mutable data

May mắn thay, dăm ba cái vấn đề này, RxSwift xử lý bá lắm rồi.

#### 2. Asynchronous programming glossary

RxSwift nhằm giải quyết những issue sau:

- State và đặt biệt là shared mutable state
- Imperative programming
- Side effects
- Declarative code
- Reactive systems

Những issue trên được định nghĩa và giải thích như sau:

__State và shared mutable state__

`State` rất khó để định nghĩa rõ ràng.

Ví dụ: Mọi chuyện đều ổn khi bạn sử dụng laptop sau khi bật nó lên. Cho đến khi bạn xài nó được một vài ngày hay thậm chí một vài tuần chả hạn, laptop của bạn thỉnh thoảng lại bị treo. Lúc đó, cả hardware và software đều duy trì giống hệt lúc đầu, tuy nhiên, cái thay đổi là state. Laptop sẽ lại chạy ổn khi restart.

Data trong bộ nhớ hoặc trong disk, tất cả những nhân tố do user input, các bản ghi còn tồn tại sau khi fetch data tư cloud service - tổng thể của tất cả những thứ đó là state của laptop.

__Imperative programming__

`Imperative programming` là một hướng lập trình sử dụng mệnh lệnh (statement) để thay đổi trạng thái (state) của program. Khá giống với việc ra lệnh cho chú chó của bạn: "Đứng lên! Ngồi xuống!" - bạn sử dụng `imperative code` để ra lệnh cho app thực hiện mệnh lệnh một cách chính xác khi nào và bằng cách nào.

`Imperative code` tương tự với cách hiểu của code của máy tính: theo sát trình tự được hướng dẫn. Gian nan ở chỗ chúng ta đang cố viết `imperative code` cho một cái app bất đồng bộ phức tạp - nhất là khi dính líu tới `shared mutable state`.

Ví dụ đơn giản:

```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  setupUI()
  connectUIControls()
  createDataSource()
  listenForChanges()
}
```

Chả chắc chắn được những method trên đang làm gì. Những method trên có cập nhật property của chính view controller đó hay không? Chúng được gọi đúng thứ tự chưa? Có ai đã swap thứ tự gọi method và commit change lên source code hả vì giờ đây app của ngày xưa đã chết rồi bởi chính sự swap kia?

__Side effects__

`Side effect` là những biến đổi của state ngoài scope hiện tại. Ví dụ với method `connectUIControls()` được gọi trên kia, hẳn là nó sẽ cài đặt vài event handler cho một số UI component. Điều này tạo nên `side effect` như sau, bởi vì nó thay đổi state của view nên app sẽ hoạt động theo 2 cách hoàn toàn khác nhau khi so sánh trước và sau khi chạy `connectUIControls()`

Mỗi lần bạn sửa data được lưu trong disk hoặc update text của một label trên màn hình, bạn đã tạo nên `side effect`.

Có nghĩa là như vầy, khi mình thay đổi state, mà không có tác dụng gì hết, tỉ dụ như là update UI ngay lập tức, thì việc thay đổi trên rất chy là vô ích.

Vấn đề khi đối mặt với việc tạo nên side effects là làm sao cho nó có thể controlled được. Mình cần phải xác định được đoạn code nào sẽ tạo ra side effect, đoạn nào chỉ xử lý và xuất data. 

Mục đích RxSwift nhằm giải quyết những issue đã kể ra phía trên bởi một số khái niệm sau. 

__Declarative code__

Trong `imperative programming`, bạn thay đổi `state` khi bạn muốn, trong `functional code`, bạn không tạo ra bất cứ `side effect` nào. RxSwift kết hợp những mặt tốt nhất của `imperative programming` và `functional code`.

`Declarative code` cho phép bạn khai báo các behavior, và chạy các behavior này bất cứ khi nào một sự kiện liên quan xuất hiện và khiến cho nó thành một data không bị thay đổi (immutable) và tách biệt để có thể làm việc cùng. 

Bằng cách này bạn có thể làm việc cùng asynchronous code, nhưng mà có thể tạo ra một dữ liệu giả tương tự trong vòng lặp đơn: Dữ liệu đó là immutable data và chúng ta có thể thực thi code một cách tuần tự và xác định.

__Reactive systems__

`Reactive system` là một khái niệm trừu tượng xuất hiện cả trong web lẫn iOS app. `Reactive system` có những tính chất sau:

- Responsive: UI luôn luôn được up to date và thể hiện app state mới nhất
- Resilient: Mỗi behavior được khai báo một cách độc lập và có khả năng error recovery linh hoạt
- Elastic: Code handle nhiều công việc
- Message driven: Các component sử dụng message-based communication để nâng cao tính reusability và tính độc lập, tách rời khỏi lifecycle và sự implementation của các class.

## More

Back to [RxSwift Diary Menu][Diary]

---

[Diary]: https://github.com/nmint8m/rxswiftdiary "RxSwift Diary"

[Image 1]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img1.png "Image 1"
[Image 2]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img2.png "Image 2"
[Image 3]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img3.png "Image 3"
[Image 4]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img4.png "Image 4"
[Image 5]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img5.png "Image 5"
[Image 6]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img6.png "Image 6"
[Image 7]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img7.png "Image 7"
[Image 8]: https://github.com/nmint8m/rxswiftdiary/blob/master/Image/Section1/c1-img8.png "Image 8"

