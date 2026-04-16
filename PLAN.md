# Luxlog — Phase 4: Social & Portfolio Frontend Logic

Kế hoạch này nhằm xây dựng hoàn thiện toàn bộ **Logic Frontend (UI State)** cho mạng xã hội Nhiếp ảnh Luxlog, để các chức năng này ở trạng thái sẵn sàng "Plug-and-play" với Backend API sau này. 

## 🎯 Mục tiêu
- Biến các nút bấm (Follow, Comment) bị "chết" hiện tại thành các luồng tương tác thực thụ trên màn hình.
- Nâng cấp màn hình Feed có khả năng chia luồng (For You / Following).
- Thêm màn hình Public Portfolio phục vụ cho tính năng chia sẻ link.

---

## 🛠 Proposed Changes (Implementation Tasks)

### 1. Feed Screen Tabs ("For You" vs "Following")
Thay thế tiêu đề `Feed` tĩnh bằng hệ thống Tab Bar.
#### [MODIFY] `lib/features/feed/presentation/feed_screen.dart`
- Thêm `TabBar` vào `_FeedAppBarDelegate`.
- Phân chia `SliverList` thành 2 page của `TabBarView` (Mock tách biệt 2 mảng danh sách post khác nhau để mô phỏng).

### 2. Comments Bottom Sheet Flow
Giao diện List Comment nên được hiển thị dưới dạng Bottom Sheet vuốt từ dưới lên khi người dùng nhấn vào nút Comment, giữ cho họ không bị chuyển cảnh màn hình đột ngột.
#### [NEW] `lib/features/gallery/presentation/widgets/comment_bottom_sheet.dart`
- Chứa ListView danh sách comment và thanh TextFormField ở dưới cùng kèm bàn phím ảo.
#### [MODIFY] `feed_screen.dart` và `photo_detail_screen.dart`
- Xác định sự kiện `onTap` của icon `chat_bubble_outline`.
- Gọi hàm `showModalBottomSheet(context: context, builder: (_) => CommentBottomSheet())`.

### 3. Logic Follow / Unfollow (Optimistic UI)
Người dùng mong muốn thấy nút Follow phản hồi ngay lập tức thay vì đợi API Load.
#### [NEW] `lib/features/profile/providers/follow_state_provider.dart`
- Tạo StateNotifierProvider tạm thời quản lý danh sách ID người dùng đang follow.
#### [MODIFY] `lib/features/profile/presentation/profile_screen.dart`
- Gắn biến `_isFollowing` theo dõi qua Provider thay vì Local State để đồng nhất toàn app.

### 4. Màn hình Public Portfolio View
Đây là màn hình sinh ra khi Photographer cấu hình xong Portfolio ở Editor và chia sẻ link web cho người khác.
#### [NEW] `lib/features/portfolio/presentation/public_portfolio_screen.dart`
- Load thiết kế masonry hoặc grid tùy theo block đã được sinh ra. Trang này là Read-Only (Không có icon Edit / Setting).
#### [MODIFY] `lib/app/router.dart`
- Bổ sung Route `GoRoute(path: '/p/:slug')` để render màn Public Portfolio.

---

## ⚠️ Open Questions (User Review Required)
> [!IMPORTANT]
> Đối với màn hình **Public Portfolio**: Bạn muốn nó sẽ hiển thị dưới dạng Full-width (chiếm trọn mí trình duyệt, không có Bottom Navigation Bar của app) để giống hệt một Website cá nhân, hay vẫn phải nằm gọn trong khung navigation của App (như một màn hình con)?
> 
> *Gợi ý: Đặt nó dưới dạng Full-width Web Page riêng biệt sẽ chuyên nghiệp hơn.* Xin ý kiến để tôi bắt tay vào code!
