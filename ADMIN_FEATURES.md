# ADMIN PANEL & USER ROLE MANAGEMENT

## Tổng quan

Tôi đã hoàn thành việc triển khai admin panel và hệ thống phân quyền người dùng cho ứng dụng từ điển. Hệ thống bao gồm:

### 1. Phân quyền người dùng (User Roles)
- **User**: Người dùng thường, có thể thêm/sửa/xóa từ vựng cá nhân
- **Admin**: Quản trị viên, có thể truy cập admin panel và quản lý toàn bộ hệ thống

### 2. Admin Dashboard
- **Thống kê tổng quan**: Tổng số users, words, users mới trong tháng/tuần
- **Biểu đồ phân tích**: Đăng ký users theo thời gian, từ vựng được thêm theo thời gian
- **Top users**: Danh sách users hoạt động tích cực nhất
- **Recent users**: Danh sách users đăng ký gần đây

### 3. User Management
- **Xem danh sách users**: Phân trang, hiển thị thông tin chi tiết
- **Chỉnh sửa role**: Admin có thể thăng/giáng role của users
- **Xóa users**: Admin có thể xóa users (không thể tự xóa mình)
- **Thống kê cá nhân**: Số từ vựng, ngày tham gia, đăng nhập cuối

### 4. Analytics & Reports
- **Lưu dữ liệu thống kê**: Tự động lưu analytics hàng ngày vào database
- **Biểu đồ thời gian**: 7 ngày, 30 ngày, 90 ngày
- **Popular words**: Từ vựng phổ biến nhất được thêm bởi users
- **User activity**: Theo dõi hoạt động người dùng

## Cấu trúc Backend

### Models mới
```javascript
// User.js - Thêm role field
role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
}

// Analytics.js - Model mới cho thống kê
{
    date: Date,
    totalUsers: Number,
    newUsers: Number,
    totalWords: Number,
    wordsAdded: Number,
    activeUsers: Number,
    userLoginCount: Number,
    popularWords: [{term: String, frequency: Number}],
    languageStats: Map
}
```

### Middleware mới
```javascript
// admin.js - Middleware kiểm tra quyền admin
const adminMiddleware = async (req, res, next) => {
    // Kiểm tra authentication trước
    // Sau đó kiểm tra role === 'admin'
}
```

### Routes mới
```javascript
// /api/admin/* - Tất cả endpoints cho admin
GET /api/admin/dashboard - Dashboard stats
GET /api/admin/analytics - Analytics data
GET /api/admin/users - Users list với pagination
PUT /api/admin/users/:id/role - Update user role
DELETE /api/admin/users/:id - Delete user
POST /api/admin/analytics/save - Save daily analytics
```

## Cấu trúc Frontend

### Services mới
```dart
// admin_service.dart - Service gọi admin APIs
class AdminService {
    Future<Map<String, dynamic>> getDashboardStats()
    Future<Map<String, dynamic>> getAnalytics({String period = '7d'})
    Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 10})
    Future<void> updateUserRole(String userId, String role)
    Future<void> deleteUser(String userId)
    Future<void> saveAnalytics()
}
```

### Screens mới
```dart
// admin_dashboard_page.dart - Trang chính admin
// admin_users_page.dart - Quản lý users
// admin_analytics_page.dart - Xem biểu đồ và thống kê
```

### Navigation Flow
```
SplashScreen -> kiểm tra role
    ├── Admin -> AdminDashboardPage
    └── User -> HomePage

LoginPage -> kiểm tra role sau đăng nhập
    ├── Admin -> AdminDashboardPage  
    └── User -> HomePage

ProfilePage -> nếu là admin, hiện nút "Admin Dashboard"
```

## User mặc định

**Admin account được tạo tự động:**
- Email: `admin@example.com`
- Password: `admin123`
- Role: `admin`

## API Testing

Tất cả admin APIs đã được test và hoạt động:

```bash
# Login admin
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Get dashboard stats  
curl -X GET http://localhost:3001/api/admin/dashboard \
  -H "Authorization: Bearer $TOKEN"

# Get analytics
curl -X GET http://localhost:3001/api/admin/analytics?period=7d \
  -H "Authorization: Bearer $TOKEN"

# Get users list
curl -X GET http://localhost:3001/api/admin/users?page=1&limit=10 \
  -H "Authorization: Bearer $TOKEN"

# Update user role
curl -X PUT http://localhost:3001/api/admin/users/$USER_ID/role \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"admin"}'

# Delete user
curl -X DELETE http://localhost:3001/api/admin/users/$USER_ID \
  -H "Authorization: Bearer $TOKEN"

# Save analytics
curl -X POST http://localhost:3001/api/admin/analytics/save \
  -H "Authorization: Bearer $TOKEN"
```

## Features đã hoàn thành

### ✅ Backend Features
- [x] User role system (user/admin)
- [x] Admin authentication middleware
- [x] Analytics data model
- [x] Admin dashboard API
- [x] User management API
- [x] Analytics API with time periods
- [x] Auto-create admin user
- [x] Save daily analytics

### ✅ Frontend Features  
- [x] Admin dashboard UI
- [x] User management interface
- [x] Analytics charts (simple bar charts)
- [x] Role-based navigation
- [x] Admin profile badge
- [x] Permission-based UI elements
- [x] Error handling và loading states

### ✅ Security Features
- [x] Role-based access control
- [x] Admin-only endpoints protection
- [x] Self-deletion prevention
- [x] Token-based authentication for admin APIs

## Cách sử dụng

1. **Khởi động backend**: `npm start` trong thư mục backend
2. **Khởi động Flutter app**: `flutter run`
3. **Đăng nhập admin**: Sử dụng `admin@example.com` / `admin123`
4. **Truy cập admin panel**: Từ Profile page hoặc tự động redirect sau login
5. **Quản lý users**: Xem, sửa role, xóa users
6. **Xem analytics**: Charts và thống kê theo thời gian
7. **Lưu analytics**: Nhấn nút Save trong dashboard

## Screenshots mô tả

- Admin Dashboard: Hiển thị tổng quan thống kê, navigation cards
- User Management: Danh sách users với pagination, actions
- Analytics: Simple bar charts cho registrations và words over time
- Profile với admin badge: Hiển thị role và nút admin dashboard

Hệ thống đã hoàn thiện và sẵn sàng sử dụng!
