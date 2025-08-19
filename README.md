# 🚀 SmartShop Mobile

## 📝 Mô tả dự án

SmartShop Mobile là ứng dụng di động giúp người dùng có trải nghiệm mua sắm tiện lợi và nhanh chóng. Ứng dụng hỗ trợ quét mã sản phẩm, quản lý giỏ hàng, thanh toán trực tiếp và đồng bộ dữ liệu với backend. Dự án được phát triển trên nền tảng Flutter với backend sử dụng Express.js, GraphQL, và MongoDB, đảm bảo hiệu năng và bảo mật tối ưu.

---

## 📚 Mục lục

- [🚀 SmartShop Mobile](#-smartshop-mobile)
  - [📝 Mô tả dự án](#-mô-tả-dự-án)
  - [📚 Mục lục](#-mục-lục)
  - [💻 Công nghệ sử dụng](#-công-nghệ-sử-dụng)
  - [⚙️ Yêu cầu hệ thống](#️-yêu-cầu-hệ-thống)
  - [🛠️ Cách cài đặt và chạy dự án](#️-cách-cài-đặt-và-chạy-dự-án)
    - [1️⃣ Cấu hình địa chỉ IP cho API](#1️⃣-cấu-hình-địa-chỉ-ip-cho-api)
    - [2️⃣ Khởi động backend server](#2️⃣-khởi-động-backend-server)
    - [3️⃣ Chạy ứng dụng SmartShop Mobile](#3️⃣-chạy-ứng-dụng-smartshop-mobile)
  - [📞 Hỗ trợ và liên hệ](#-hỗ-trợ-và-liên-hệ)

---

## 💻 Công nghệ sử dụng

- 🐦 Flutter (Dart)  
- ⚙️ Express.js  
- 🔍 GraphQL  
- 🍃 MongoDB (Mongoose)  
- 🔐 JWT Authentication  
- 🔥 Firebase  
- 🟨 JavaScript / TypeScript  

---

## ⚙️ Yêu cầu hệ thống

- 🛠️ Flutter SDK mới nhất  
- 📦 Node.js và npm  
- 📱 Android Studio hoặc Xcode (cho việc chạy trên thiết bị mô phỏng)  
- 🌐 Kết nối mạng LAN chung cho backend và thiết bị di động  

---

## 🛠️ Cách cài đặt và chạy dự án

### 1️⃣ Cấu hình địa chỉ IP cho API

- 🖥️ Nếu chạy dự án Flutter trên máy tính (localhost), sử dụng IP: `10.0.2.2`.
- 📱 Nếu chạy dự án trên điện thoại thật (kết nối chung mạng LAN với máy tính):
  - 📝 Mở Command Prompt, chạy lệnh `ipconfig` để lấy địa chỉ IP LAN của máy tính.
  - 📂 Mở file `lib/core/constants/api_constants.dart`.
  - ✏️ Thay đổi giá trị biến `ipAddress` thành địa chỉ IP LAN vừa lấy.
  - 💾 Lưu file.

### 2️⃣ Khởi động backend server

- 🗂️ Mở terminal, điều hướng vào thư mục `server`.
- 📥 Cài đặt các gói phụ thuộc:

``` bash
npm install
```
- ▶️ Khởi chạy server:

``` bash
npm start
```
### 3️⃣ Chạy ứng dụng SmartShop Mobile

- 🏠 Mở terminal tại thư mục dự án Flutter.
- 🧹 Làm sạch project:

``` bash
flutter clean
```
- ▶️ Chạy ứng dụng trên thiết bị mô phỏng hoặc thiết bị thật:

``` bash
flutter run
```


---

## 📞 Hỗ trợ và liên hệ

Nếu gặp vấn đề khi kết nối hoặc chạy ứng dụng, hãy kiểm tra lại IP cấu hình và đảm bảo thiết bị di động cùng máy tính đang dùng chung mạng LAN.  

Mọi thắc mắc và đóng góp, vui lòng liên hệ qua GitHub: https://github.com/denzuliovn

---
