# Luxlog — Testing & Icon Generation

Kế hoạch này nhằm thực thi 2 yêu cầu: Thiết kế App Icon với sự hỗ trợ của Stitch, và thiết lập luồng Test (Unit Test + E2E Test) cho ứng dụng Luxlog.

## 🎯 Mục tiêu
- Tạo ra concept App Icon độc đáo cho Luxlog. Liên kết giữa ý tưởng "Darkroom" (phòng tối rửa ảnh) và chất liệu premium.
- Cài đặt và viết **Unit Tests** cho các logic hoạt động độc lập (như State Providers, Data Models).
- Cài đặt **E2E Tests** (Integration Test) mô phỏng luồng người dùng (Màn hình Home -> Cuộn Feed -> Bấm Follow -> Mở Comment).

---

## 🛠 Proposed Changes

### 1. App Icon Design
#### [NEW] `assets/icons/app_icon.png`
- Sử dụng mô hình tạo sinh ảnh (Image Generation tool của AI) để vẽ ra icon dựa vào Design System của Luxlog (tông màu Dark, nét mạ Vàng `primary`).
- Chỉnh sửa file code cấu hình Android/iOS (tùy chọn) để nạp App Icon này vào.
- **Vai trò của StitchMCP**: Khởi tạo một project thiết kế "Splash Screen/Icon Concept" để lưu lại Design Guideline (Mã nguồn UI) dùng để tham khảo.

### 2. Thiết lập Testing Environment
#### [MODIFY] `pubspec.yaml`
- Thêm `integration_test` (Flutter SDK).
- Thêm `mocktail: ^1.0.3` (dùng để mock Unit test).
- Thêm `flutter_test` (Đã có sẵn).

### 3. Viết Unit Tests
#### [NEW] `test/features/profile/providers/follow_state_provider_test.dart`
- Viết Unit Test cho `FollowState` (đã code ở Phase 4) để đảm bảo:
  - Khởi tạo thành công danh sách mặc định.
  - Hàm `toggleFollow` có thể thêm user nếu chưa có.
  - Hàm `toggleFollow` xóa user khỏi danh sách nếu đang follow.

### 4. Viết End-to-End (E2E) Tests
#### [NEW] `integration_test/app_flow_test.dart`
- Kích hoạt integration test driver.
- Chạy toàn bộ app (`main()`).
- Mô phỏng các tương tác cốt lõi:
  - Chờ giao diện `FeedScreen` hiện ra.
  - Tìm nút `Tab` "Following" và bấm vào đó -> Expect thấy thông báo rỗng hoặc danh sách filter.
  - Mở sang `ProfileScreen` -> Tìm và nhấn nút "Follow".
  - Quay lại màn hình ảnh -> Bấm icon 💬 để mở `CommentBottomSheet`.

---

## ⚠️ Open Questions (User Review Required)
> [!IMPORTANT]
> - Về phía **App Icon**, tôi sẽ generate ra file ảnh gốc vào thư mục dự án và có thể gán nó vào file cấu hình `launcher_icon` nếu bạn cũng muốn. Bạn có đồng ý với phong cách: Tông màu đen/thép viền vàng mang phong cách ống kính máy ảnh tối giản không?
> - **E2E Test** của Flutter yêu cầu phải chạy trên Simulator/máy thật để test UI Render (command: `flutter test integration_test`). Kênh test integration của Flutter có thể chạy hơi nặng máy do nó build toàn bộ app. Bạn có sẵn sàng chạy nó ở máy bạn sau khi tôi code xong không?
