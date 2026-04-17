# E4. Photo Upload + Film Mode & Security Hardening — Walkthrough

Đã hoàn thành toàn bộ 2 workstream quan trọng: Hoàn thiện luồng Upload ảnh (bao gồm chế độ máy film) và thắt chặt bảo mật cho nền tảng Luxlog.

---

## 📸 1. Hoàn thiện Photo Upload + Film Mode

Chúng ta đã chuyển đổi từ luồng upload "giả lập" sang luồng thật phối hợp với Supabase Storage và Real-time Metadata.

### Các thay đổi chính:
- **Database**: Chạy migration `003` thêm các cột `is_film`, `film_stock`, `film_camera`, `caption`, `license`, `allow_download`.
- **PhotoRepository**: Implement logic upload dùng `uploadBinary` (tương thích web). Ảnh được lưu tại `photos/uploads/{userId}/{timestamp}.ext`.
- **Upload Screen**:
  - Chuyển sang `ConsumerStatefulWidget` để tích hợp Riverpod.
  - Thêm tính năng **Film Mode**: Khi bật toggle "Shot on Film", người dùng có thể nhập thủ công tên máy film và loại film stock.
  - Tích hợp validation: Giới hạn file size 20MB, kiểm tra độ dài title/caption.

> [!TIP]
> **Film Mode Activation**: Trong màn hình Details của upload, tìm biểu tượng 🎞️. Khi chọn, app sẽ bỏ qua GPS (nếu muốn) và cho phép bạn ghi lại "hồn" của bức ảnh film.

---

## 🔒 2. Security Hardening (Bảo mật)

Rà soát và triển khai các biện pháp bảo vệ dữ liệu người dùng và hệ thống.

### Các hạng mục bảo mật đã triển khai:
1. **Row Level Security (RLS)**:
   - Thêm migration `004` bổ sung policies còn thiếu cho: `photos` (DELETE), `comments`, `likes`, `follows`, `portfolios`.
   - Đảm bảo chỉ chủ sở hữu mới có quyền xóa dữ liệu của mình.
2. **Security Headers**:
   - Cập nhật `vercel.json` với các headers: **CSP** (chỉ cho phép connect tới Supabase/trusted sources), **X-Frame-Options** (chống clickjacking), **HSTS**, and **Permissions-Policy**.
3. **Input Validation**:
   - **Signup**: Áp dụng RegExp kiểm tra format email, độ mạnh mật khẩu (8+ ký tự, 1 hoa, 1 số), và giới hạn tên hiển thị.
   - **Upload**: Chặn file > 20MB ngay tại client.
4. **Error Sanitization**:
   - Loại bỏ việc hiển thị `e.toString()` thô cho người dùng. Sử dụng `AppException` để hiển thị message thân thiện và bảo mật (không leak cấu trúc folder/internal errors).
5. **Clean Code**:
   - Thay thế `print()` bằng `debugPrint()` trong `SupabaseService`.

---

## ✅ Kết quả Kiểm thử (Verification)

### 1. Phân tích mã nguồn
- `flutter analyze`: Không có lỗi hoặc cảnh báo nghiêm trọng.
- `dart run build_runner build`: Code generation cho `PhotoModel` thành công.

### 2. Build Release
- **Lệnh**: `flutter build web --release`
- **Kết quả**: **SUCCESS (Exit code 0)**.
- **Vesting**: Đã kiểm tra tính tương thích của bundle bundle web trên hệ thống cục bộ.

---

## 🚀 Bước tiếp theo đề xuất (Next Steps)

1. **Storage Policy**: Đừng quên truy cập Supabase Dashboard -> Storage để đảm bảo bucket `photos` đã được tạo và có policy cho phép authenticated users upload.
2. **E5. Profile Management**: Bây giờ khi đã có thể upload ảnh, bước tiếp theo nên là hoàn thiện màn hình Profile để hiển thị danh sách ảnh người dùng đã đăng.
3. **Analytics**: Tích hợp thêm logging cơ bản để theo dõi tỉ lệ upload lỗi (nếu có).

---
*Luxlog — Lưu giữ khoảnh khắc 35mm của bạn một cách an toàn và tinh tế.*
