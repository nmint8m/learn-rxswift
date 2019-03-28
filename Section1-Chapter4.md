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

Trong phần này ta sẽ kết nối class `PhotosViewController` đến `MainViewController` để lấy những photo được user chọn từ Camera Roll.

Đầu tiên, chúng ta cần push `PhotosViewController` vào navigation stack. Mở file `MainViewController.swift` tìm đến function `actionAdd()` và xoá hết code cũ ở đó đi và thay thế bằng:

```swift
    @IBAction func actionAdd() {
        guard let viewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
```

Chạy app và tap vào button `+` để tới Camera Roll. Lần đầu tiên khi chúng ta làm vậy, chúng ta cần cấp quyền access vào Photo Library:

<center>
	<img src="./Document/Image/Section1/c4-img6.png" height="300">
</center>

Sau khi tap OK, chúng ta sẽ thấy photo controller như bên dưới. Có thể có sự khác biệt giữa device và simulator, nên chúng ta cần back và thử lại sau khi cấp phép truy cập photo. Lần thứ hai, chúng ta nhất định sẽ thấy được các sample photo trên Simulator.

<center>
	<img src="./Document/Image/Section1/c4-img7.png" height="300">
</center>

Nếu như chúng ta build app sử dụng Cocoa pattern, bước tiếp theo chúng ta sẽ add delegate protocol để photo view controller có thể giao tiếp ngược lại với main view controller, và đó là cách implement theo hướng non-reactive:

<center>
	<img src="./Document/Image/Section1/c4-img8.png" height="300">
</center>

Tuy nhiên, đối với RxSwift thì không như vậy, chúng ta có một cách universal hơn giúp hai class giao tiếp với nhau - đó là observable. Chúng ta không cần phải định nghĩa protocol bởi observable có thể chuyển nhiều kiểu message đến một hoặc nhiều observer khác nhau.

#### Creating an observable out of the selected photos

Bước tiếp theo, chúng ta add subject vào `PhotosViewController`, subject đó có nhiệm vụ phát event `.next` mỗi khi user tap vào một ảnh trong Camera Roll. Mở file `PhotosViewController.swift` và thêm dòng code sau lên phía đầu:

```swift
import RxSwift
```

Chúng ta cần add một `PublishSubject` để lấy các ảnh được chọn, nhưng chúng ta sẽ không public access nó, bởi vì làm như vậy sẽ khiến các class khác có thể gọi `onNext(_)`, buộc subject phải phát ra value. Có thể trong trường hợp khác chúng ta cần phải làm như vậy, nhưng đối với trường hợp này thì không.

Thêm các property vào `PhotosViewController`:

```swift
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
```

Ở đây chúng ta khai báo private đối với property `selectedPhotosSubject` (`PublishSubject` phát ra các photo được chọn) và public với property `selectedPhotos` (chỉ lấy các tính chất của observable từ subject). Subscribe đến `selectedPhotos` là cách mà main view controller lắng nghe photo sequence mà không gặp trở ngại nào.

`PhotosViewController` đã chứa code đọc ảnh từ Camera Roll và hiển thị nó lên collection view. Tất cả những gì chúng ta cần làm là thêm đoạn code phát ra những ảnh được chọn khi người dùng tap lên collection view cell.

Trong function `collectionView(_:didSelectItemAt:)`, code có sẵn đã giúp chúng ta lấy được ảnh user đang chọn. Việc chúng ta cần làm là trong closure `imageManager.requestImage(...)` là phát `.next` event. Add đoạn code sau phía trong closure, sau dòng lệnh `guard`:

```swift
if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool,
                !isThumbnail {
    self?.selectedPhotosSubject.onNext(image)
}
```

Vậy là từ giờ chúng ta không cần phải xài delegate protocol nữa vì mối quan hệ giữa các view controller đã trở nên đơn giản hơn nhiều:

<center>
	<img src="./Document/Image/Section1/c4-img9.png" height="300">
</center>

#### Observing the sequence of selected photos

Nhiệm vụ tiếp theo là trở về `MainViewController.swift`, thêm đoạn code lắng nghe photo sequence.

Tìm tới function `actionAdd()` thêm đoạn code sau ngay trước đoạn code push new view controller vào navigation stack:

```swift
viewController.selectedPhotos
    .subscribe(
        onNext: { [weak self] newImage in
        },
        onDisposed: {
            print("Completed photo selection")
    }).disposed(by: disposeBag)
```

Trước khi push view controller, chúng ta subscribe event từ property `selectedPhoto` của nó. Cần quan tâm tới hai event là `.next` (khi user tap vào một ảnh) và khi subscription bị dispose.

Thêm đoạn code vào closure `.onNext`:

```swift
guard let this = self else { return }
this.images.value.append(newImage)
```

Chạy app và kiểm tra thành quả nào. Cool! ❄️

<center>
	<img src="./Document/Image/Section1/c4-img10.png" height="300">
</center>

#### Disposing subscriptions - review

Tới đoạn này thì code đã hoạt động đúng mong đợi rồi, nhưng mà bạn thử các bước sau đi: thêm một vài hình vào collage rồi quay lại main screen và kiểm tra console. Bạn không thấy dòng "Completed photo selection" được in ra. Vậy có nghĩa là dòng lệnh `print` trong `onDispose` closure lúc này không bao giờ được gọi tới, tương đương với việc subscription không bao giờ bị dispose và không giải phóng memory! 💥

Chúng ta đã subscribe observable sequence rồi vất nó cho dispose bag của main screen. Subscription này sẽ bị dispose chỉ khi bag object bị release, hoặc là sequence kết thúc bởi error hoặc completed event.

Bởi vì main screen không bị release và photo sequence cũng không bị kết thúc, vậy nên subscription này cứ trường tồn như vậy.

Vậy nên tốt nhất là trước khi back về main screen từ photo view controller, ta nên phát `.completed` event để cho tất cả các observer của nó được hoàn thành và dispose.

Mở file `PhotosViewController.swift`, phát `.completed` event cho subject trong function `viewWillDisappear(_:)`:

```swift
selectedPhotosSubject.onCompleted()
```

Perfect! ✅

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
