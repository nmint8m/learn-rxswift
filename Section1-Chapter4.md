_Written by: **Nguyen Minh Tam**_

# Section I: Getting started with RxSwift

## Chapter 4: Observables and Subjects in practice

Tính đến thời điểm này, chúng ta đã có thể hiểu được cách hoạt động của observable và của các loại subject khác nhau và học được cách khởi tạo, cách làm việc với chúng qua playground.

Trong chapter này, chúng ta sẽ làm việc với một app hoàn thiện để hiểu được cách sử dụng observable trong thực tế, như: binding UI vào data model hoặc present new controller và cách nhận output từ observable. Chúng ta sẽ sử dụng sức mạnh siêu nhiên của RxSwift để tạo ra app cho phép người dùng tạo ra photo collage. Let's do it! 🎉

**Menu**

- [Getting started](#getting-started)
- [Using a variable in a view controller](#using-a-variable-in-a-view-controller)
- [Talking to other view controllers via subjects](#talking-to-other-view-controllers-via-subjects)
- [Creating a custom observable](#creating-a-custom-observable)
- [RxSwift traits in practice](#rxswift-traits-in-practice)
- [Completable](#completable)

### Getting started

Sau khi chạy `pod install`, mở `Combinestagram.xcworkspace` trong thư mục `./Document/ExampleProject/04-observables-in-practice/starter/`.

Chọn `Main.storyboard` và bạn sẽ thấy app interface như sau:

<center>
	<img src="./Document/Image/Section1/c4-img1.png" height="300">
</center>

App flow như sau:
- Màn hình đầu tiên, user có thể thấy photo collage hiện tại.
- Một nút để clear list photo hiện tại.
- Một sút để save collage vào bộ nhớ.
- Khi user tap vào nút `+` góc trên bên phải, user được chuyển đến màn hình thứ hai chứa list photo trong Camera Roll. User lúc này có thể add thêm photo vào collage bằng cách chọn thumbnail.

Ở đây cái view controller và storyboard đã được kết nối với nhau, chúng ta có thể chọn file `UIImage+Collage.swift` để xem cách một collage thực tế được xây dựng như thế nào.

Điều quan trọng ở đây là chúng ta sẽ học cách vận dụng những skill mới vào thực tế. Time to get started! 🎉


### Using a variable in a view controller

Chúng ta sẽ bắt đầu bằng việc thêm một property Variable<[UIImage]> vào controller class để lưu các photo được chọn vào value của nó.

Mở `MainViewController.swift` và thêm đoạn code sau:

```swift
private let disposeBag = DisposeBag()
private let images = Variable<[UIImage]>([])
```

Bởi vì property `disposeBag` được sở hữu bởi view controller, vậy nên khi view controller release thì các observable được thêm vào `disposeBag` sẽ bị dispose theo. Điều này khiến cho việc quản lý bộ nhớ của các subscription hết sức dễ dàng: chỉ bằng việc quăng subscription vào bag và nó sẽ bị dispose khi view controller bị deallocate.

<center>
	<img src="./Document/Image/Section1/c4-img2.png" height="300">
</center>

Tuy nhiên, quá trình trên sẽ không xảy ra đối với một số view controller nhất định, ví dụ như đối với trường hợp nó là root view controller, nó sẽ không bị release trước khi tắt app. Chúng ta sẽ tìm hiểu về cách thức hoạt động của quá trình `dispose-upon- deallocation` ở phần sau của chapter này.

Lúc đầu, app của chúng ta sẽ luôn luôn hiển thị một collage có nhiều ảnh giống nhau, là ảnh mèo được add sẵn trong `Assets.xcassets`. Mỗi lần user tap vào `+`, chúng ta sẽ add thêm ảnh vào variable `images`.

Tìm tới function `actionAdd()` và add đoạn code sau:

```swift
guard let image = UIImage(named: "img-cat.jpg") else { return }
images.value.append(image)
```

Giá trị khởi tạo của variable `images` là một mảng rỗng, vậy nên mỗi khi user tap nút `+`, observable sequence được tạo bởi `images` sẽ phát `.next` event với element là một array mới.

Để cho phép user clear lựa chọn, add code sau vào funtion `actionClear()`:

```swift
images.value = []
```

Với những đoạn code ngắn trên, chúng ta đã có thể handle user input tốt rồi. Bây giờ chúng ta sẽ sang phần lắng nghe `images` và hiển thị kết quả lên screen.

#### Adding photos to the collage 

Trong function `viewDidLoad()`, khởi tạo subscription tới `images`. Và nhớ rằng vì `images` là variable nên ta phải dùng `asObservable()` để có thể subscribe tới nó:

```swift
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                guard let this = self,
                let preview = this.imagePreview else { return }
                preview.image = UIImage.collage(images: photos,
                                                size: preview.frame.size)
            }).disposed(by: disposeBag)
```

Ở chapter này, chúng ta sẽ học cách subscribe observable trong `viewDidLoad()`. Trong những chapter cuối, chúng ta sẽ học cách triển khai subscribe observable vào các class tách biệt, và ở chapter cuối cùng, chúng ta sẽ học về MVVM.

Bây giờ thử chạy app nào!

<center>
	<img src="./Document/Image/Section1/c4-img3.png" height="300">
</center>

#### Driving a complex view controller UI 

Khi sử dụng app hiện tại, chúng ta có thể dễ để ý thấy có một số điểm cần cải thiện về mặt UX, ví dụ như:

- Disable clear button khi không có ảnh nào được chọn hoặc sau khi user tab clear button.
- Tương tự đối với save button.
- Nên disable save button khi trống chỗ trên collage trong trường hợp ảnh bị lẻ.
- Nên giới hạn số ảnh trong khoảng 6 ảnh.
- Nên hiển thị title của view controller cho biết current selection là gì.

Nếu đọc kỹ danh sách yêu cầu trên, chúng ta có thể nhận thấy việc thay đổi có thể gặp một chút phức tạp khi implement bởi cách non-reactive.

May là RxSwift cho phép subscribe `images` nhiều lần, thêm đoạn code sau vào trong function `viewDidLoad()`:

```swift
		images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                guard let this = self else { return }
                this.updateUI(photos: photos)
            }).disposed(by: disposeBag)
```

Trong đó:

```swift
	private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
```

Đoạn code trên gíup chúng ta cập nhật UI theo các rule ở trên. Các logic được gom lại một chỗ và có thể dễ dàng đọc hiểu. Chạy app lại nào và thử xem các rule được áp dụng ra sao:

<center>
	<img src="./Document/Image/Section1/c4-img4.png" height="300">
	<img src="./Document/Image/Section1/c4-img5.png" height="300">
</center>

Tới đây thì chúng ta đã có thể thấy lợi ích của RxSwift rồi, với vài dòng code đơn giản mà chúng ta có thế điều khiển toàn bộ UI của app.

### Talking to other view controllers via subjects

### Creating a custom observable

### RxSwift traits in practice

### Completable

## More

Quay lại chapter trước [Chapter 3: Subjects][Chapter 3]

Đi đến chapter sau [Chapter 5: Filtering operators][Chapter 5]

Quay lại [RxSwiftDiary's Menu][Diary]

## Reference

[RxSwift: Reactive Programming with Swift][Reference] 

---
[Chapter 2]: ./Section1-Chapter2.md "Observables"
[Chapter 3]: ./Section1-Chapter3.md "Subjects"
[Chapter 5]: ./Section2-Chapter5.md "Filtering operators"
[Diary]: https://github.com/nmint8m/rxswiftdiary "RxSwift Diary"
[Reference]: https://store.raywenderlich.com/products/rxswift "RxSwift: Reactive Programming with Swift"
