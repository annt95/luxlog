# Luxlog — Photography Platform Implementation Plan

Cập nhật tiến độ dự án Luxlog (trước đây là VibeShot). Dự án đang được xây dựng trên Flutter Web/Mobile với thiết kế **"The Darkroom Editorial"**.

## Mục tiêu hiện tại
Cập nhật kế hoạch để phản ánh những phần giao diện (UI) đã hoàn thành xuất sắc trong Phase 1 & Phase 2, và vạch ra lộ trình tích hợp hệ thống Backend (Supabase) cùng hoàn thiện luồng Logic cho Phase 3 & Phase 4.

> [!IMPORTANT]
> **User Review Required**: Kế hoạch này chuyển trọng tâm từ việc thiết kế UI thuần sang việc tích hợp dữ liệu thật. Xin đánh giá mức độ ưu tiên: Bạn muốn làm Hệ thống Đăng nhập & Data trước hay làm nốt các Màn hình (Ví dụ: Public Portfolio & Notifications) trước?

---

## 🟢 Những gì đã hoàn thành (Phase 1 & 2 UI/UX)
- **Tech Stack**: Đã thiết lập Flutter 3.41, Riverpod 2, GoRouter. Triển khai CI/CD Web lên Vercel.
- **Design System**: Thống nhất `theme.dart`, CSS variables, color (Vintage Gold/Charcoal), Typography, Glassmorphism.
- **UI Module Gallery / Feed**: Màn hình Social Feed (Instagram-like con), Photo Detail, Upload màn (cùng parse EXIF thật).
- **UI Module Explore / Discover**: Màn hình Discover Masonry, Explore Search.
- **UI Module Portfolio / Profile**: Màn hình Dashboard, Portfolio Editor (drag&drop blocks), và Profile Cá nhân.

---

## 🟡 Những gì còn thiếu (Cần triển khai)

### 1. Tích hợp Backend (Supabase)
> Tầng tảng thiết yếu để ứng dụng có thể lưu trữ và hoạt động thực.
- **Xác thực (Auth)**:
  - Gắn Supabase Auth vào màn hình `LoginScreen`.
  - Quản lý persistent session qua Riverpod Provider.
- **Cơ sở dữ liệu (Database)**:
  - Định nghĩa database schema thực tế trên Supabase (Users, Photos, Comments, Likes, Portfolio).
  - Viết các Repository class (`PhotoRepository`, `UserRepository`, `PortfolioRepository`) để gọi API từ Supabase.
- **Lưu trữ (Storage)**:
  - Cập nhật luồng `upload_screen.dart` để upload ảnh thật sự lên Supabase Storage bucket.
  - Xử lý nén ảnh/thumb trước khi upload hoặc qua Supabase webhook.
- **State Management**:
  - Chuyển toàn bộ mock data hiện tại thành AsyncValue trên Riverpod để fetch data realtime.

### 2. Hoàn thiện Logic Social Layer (Phase 3)
> Xử lý tương tác giữa người dùng với người dùng.
- **Following Feed Filter**:
  - Thêm logic lọc Feed trên màn hình Home (chỉ fetch Post của những user đang Following).
- **Cơ chế Follow/Unfollow**:
  - Gắn logic gọi API follow/unfollow trên `ProfileScreen` và feed headers. Cập nhật state UI ngay lập tức (optimistic UI update).
- **Comments Full Flow**:
  - Thiết kế và gắn Data cho BottomSheet / Modal liệt kê danh sách comment ở `PhotoDetailScreen`.
  - Logic post comment mới.
- **Notifications Screen**:
  - *Màn hình mới chưa có*: Chứa danh sách thông báo lịch sử (likes, new comments, follows).

### 3. Hoàn thiện Portfolio Builder (Phase 4)
- **Portfolio Public View**:
  - *Màn hình mới chưa có*: Màn hình hiển thị Portfolio cho người mua/vãn cảnh khi họ có link sharing. Sẽ parse cấu trúc block JSON thành giao diện thực tế.
- **Lưu trữ Data Portfolio Editor**:
  - Kết nối trạng thái của drag-and-drop editor (`portfolio_editor_screen.dart`) để lưu thành cấu trúc JSON trên Supabase DB.

### 4. Polish & Tối ưu (Phase 5)
- Mobile responsiveness: Tinh chỉnh lại tỷ lệ font & spacing trên màn hình hẹp (Mobile browser / App).
- PWA/SEO optimization (Dynamic meta tags cho flutter web nếu hỗ trợ qua template).

---

## Open Questions

> [!WARNING]
> Cần xác nhận từ USER: Với Supabase, chúng ta sử dụng Backend-as-a-Service, bạn đã chuẩn bị sẵn Project URL & API Key của Supabase chưa, hay tôi sẽ giúp xây dựng những SQL Scripts (Migrations) trước để bạn tự apply?
