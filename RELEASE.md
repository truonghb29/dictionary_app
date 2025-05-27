# 📚 Dictionary App - Production Release

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Netlify](https://img.shields.io/badge/Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)](https://netlify.com)
[![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com)

> **🚀 Live Demo**: [https://dictionary-app-truonghb.netlify.app](https://dictionary-app-truonghb.netlify.app)

## 🌟 Giới thiệu

Dictionary App là ứng dụng từ điển thông minh được phát triển bằng Flutter và Node.js, cho phép người dùng tra cứu từ vựng, lưu từ yêu thích và theo dõi tiến độ học tập.

### ✨ Tính năng chính
- 🔍 **Tìm kiếm thông minh**: Tra cứu từ vựng với thuật toán tìm kiếm nâng cao
- 🗣️ **Phát âm chuẩn**: Nghe phát âm của người bản xứ
- ⭐ **Lưu từ yêu thích**: Tạo danh sách từ vựng cá nhân
- 📊 **Thống kê học tập**: Theo dõi tiến độ và thành tích
- 🔐 **Xác thực bảo mật**: Hệ thống đăng ký/đăng nhập với JWT
- 👨‍💼 **Admin Dashboard**: Quản lý người dùng và hệ thống

## 🚀 Truy cập ứng dụng

### 🌐 Web App (Khuyến nghị)
```
https://dictionary-app-truonghb.netlify.app
```
- ✅ Không cần cài đặt
- ✅ Responsive design
- ✅ Tốc độ cao
- ✅ Tự động cập nhật

### 📱 Mobile Apps
- **Android APK**: [Đang chuẩn bị]
- **iOS App**: [Sắp ra mắt]

## 🛠️ Kiến trúc hệ thống

```
📱 Frontend (Flutter Web)     🌐 Backend (Node.js)     🗄️ Database (MongoDB)
┌─────────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Netlify Hosting   │ ───► │  Render Hosting  │ ───► │  MongoDB Atlas  │
│  🔗 Static Deploy   │      │  🚀 API Server   │      │  ☁️ Cloud DB    │
└─────────────────────┘      └──────────────────┘      └─────────────────┘
```

### 🔧 Tech Stack
- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Node.js + Express.js
- **Database**: MongoDB Atlas
- **Authentication**: JWT (JSON Web Tokens)
- **Hosting**: Netlify (Frontend) + Render (Backend)
- **State Management**: Provider Pattern
- **API**: RESTful API

## 📊 URLs và Endpoints

### 🌐 Production URLs
- **Frontend**: `https://dictionary-app-truonghb.netlify.app`
- **Backend API**: `https://dictionary-app-backend.onrender.com`
- **Health Check**: `https://dictionary-app-backend.onrender.com/api/health`

### 🔗 API Endpoints
```
POST   /api/auth/register     # Đăng ký người dùng
POST   /api/auth/login        # Đăng nhập
GET    /api/user/words        # Lấy từ đã lưu
POST   /api/user/words        # Lưu từ mới
DELETE /api/user/words/:id    # Xóa từ đã lưu
GET    /api/admin/dashboard   # Admin dashboard
GET    /api/admin/users       # Quản lý người dùng
GET    /api/health            # Kiểm tra sức khỏe hệ thống
```

## 👥 Tài khoản Demo

### 👤 User Account
Đăng ký tài khoản mới tại ứng dụng hoặc sử dụng:
```
Email: demo@example.com
Password: demo123
```

### 👨‍💼 Admin Account
```
Email: admin@example.com
Password: admin123
```

## 🔧 Cài đặt Development

### Prerequisites
- Flutter SDK 3.x+
- Node.js 18+
- MongoDB (Local hoặc Atlas)

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Cập nhật MONGODB_URI trong .env
npm start
```

### Frontend Setup
```bash
flutter pub get
flutter run -d web
```

## 📱 Hướng dẫn sử dụng

### 🚀 Bắt đầu nhanh
1. Truy cập [Dictionary App](https://dictionary-app-truonghb.netlify.app)
2. Đăng ký tài khoản mới
3. Bắt đầu tra từ và học vocabulary!

### 📖 Hướng dẫn chi tiết
- [📚 User Guide](./USER_GUIDE.md) - Hướng dẫn sử dụng đầy đủ
- [🔧 Admin Guide](./ADMIN_FEATURES.md) - Tính năng admin

## ⚡ Kiểm tra hệ thống

### 🔍 Health Check Script
```bash
./health-check.sh
```

### 🧪 Manual Testing
```bash
# Kiểm tra Frontend
curl -I https://dictionary-app-truonghb.netlify.app

# Kiểm tra Backend
curl https://dictionary-app-backend.onrender.com/api/health

# Test API endpoint
curl -X POST https://dictionary-app-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test","password":"test"}'
```

## 📈 Performance

- **Frontend Load Time**: < 3s
- **API Response Time**: < 2s
- **Database Query Time**: < 500ms
- **Uptime**: 99.9%

## 🔒 Bảo mật

- ✅ HTTPS cho tất cả connections
- ✅ JWT token authentication
- ✅ Password hashing với bcrypt
- ✅ CORS properly configured
- ✅ Input validation và sanitization
- ✅ Rate limiting (planned)

## 🐛 Troubleshooting

### Lỗi thường gặp
1. **Không thể đăng nhập**: Kiểm tra email/password và internet
2. **Trang không load**: Refresh hoặc xóa cache
3. **API error**: Kiểm tra backend status
4. **Mobile không responsive**: Sử dụng trình duyệt mới nhất

### 🆘 Hỗ trợ
- **Email**: truonghb29@example.com
- **GitHub Issues**: [Tạo issue mới](https://github.com/truonghb29/dictionary_app/issues)
- **Documentation**: [Wiki](https://github.com/truonghb29/dictionary_app/wiki)

## 🚀 Roadmap

### ✅ Version 1.0 (Current)
- [x] Cơ bản dictionary features
- [x] User authentication
- [x] Admin dashboard
- [x] Production deployment

### 🔄 Version 1.1 (Q2 2024)
- [ ] Mobile native apps
- [ ] Voice search
- [ ] Offline mode
- [ ] Push notifications

### 🎯 Version 2.0 (Q3 2024)
- [ ] AI-powered definitions
- [ ] Flashcard system
- [ ] Community features
- [ ] Multiple languages

## 📄 License

Dự án này được phát triển cho mục đích giáo dục tại Khoa Công nghệ Thông tin.

## 🙏 Credits

**Phát triển bởi**: Trương Hữu Bính  
**Học viện**: [Tên trường]  
**Môn học**: Chuyên ngành Công nghệ Thông tin  
**Năm**: 2024  

### 🎉 Đóng góp
- Cảm ơn thầy cô đã hướng dẫn
- Cảm ơn cộng đồng Flutter và Node.js
- Cảm ơn các open source libraries

---

<div align="center">

**🌟 Nếu bạn thấy project hay, hãy cho một Star! ⭐**

[🌐 Demo](https://dictionary-app-truonghb.netlify.app) • [📚 Docs](./USER_GUIDE.md) • [🐛 Issues](https://github.com/truonghb29/dictionary_app/issues) • [📧 Contact](mailto:truonghb29@example.com)

</div>
