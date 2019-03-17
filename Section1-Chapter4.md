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
	<img src="" height="200">
</center>

App flow như sau:
- Màn hình đầu tiên, user có thể thấy photo collage hiện tại.
- Một nút để clear list photo hiện tại.
- Một sút để save collage vào bộ nhớ.
- Khi user tap vào nút `+` góc trên bên phải, user được chuyển đến màn hình thứ hai chứa list photo trong Camera Roll. User lúc này có thể add thêm photo vào collage bằng cách chọn thumbnail.

Ở đây cái view controller và storyboard đã được kết nối với nhau, chúng ta có thể chọn file `UIImage+Collage.swift` để xem cách một collage thực tế được xây dựng như thế nào.

Điều quan trọng ở đây là chúng ta sẽ học cách vận dụng những skill mới vào thực tế. Time to get started! 🎉


### Using a variable in a view controller

### Talking to other view controllers via subjects

### Creating a custom observable

### RxSwift traits in practice

### Completable

## More

Quay lại chapter trước [Chapter 3: Subjects][Chapter 3]

Đi đến chapter sau [Chapter 5: Filtering operators][Chapter 5]

Quay lại [RxSwiftDiary's Menu][Diary]

---
[Chapter 2]: ./Section1-Chapter2.md "Observables"
[Chapter 3]: ./Section1-Chapter3.md "Subjects"
[Chapter 5]: ./Section2-Chapter5.md "Filtering operators"
[Diary]: https://github.com/nmint8m/rxswiftdiary "RxSwift Diary"
