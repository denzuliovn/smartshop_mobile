class ApiConstants {
  // QUAN TRỌNG:
  // - Nếu chạy trên MÁY ẢO ANDROID, dùng: "http://10.0.2.2:4000/"  static const String graphqlUrl = "http://10.0.2.2:4000/"; 
  // - Nếu chạy trên MÁY ẢO IOS, dùng: "http://localhost:4000/" 
  //   (Mở cmd/terminal, gõ `ipconfig` (Windows) hoặc `ifconfig` (macOS/Linux))
  // ip wifi trường UMT: 10.12.1.130
  // ip wifi nhà: 192.168.1.3

  static const String ipAddress = "10.12.2.217"; // <<-- THAY IP CỦA BẠN VÀO ĐÂY 
  static const String baseUrl = "http://$ipAddress:4000";
  static const String graphqlUrl = "$baseUrl/"; 
}

