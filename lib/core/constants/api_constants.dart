class ApiConstants {
  // QUAN TRỌNG:
  // - Nếu chạy trên MÁY ẢO ANDROID, dùng: "http://10.0.2.2:4000/"  static const String graphqlUrl = "http://10.0.2.2:4000/"; 
  // - Nếu chạy trên MÁY ẢO IOS, dùng: "http://localhost:4000/"
  // - Nếu chạy trên MÁY THẬT (cùng mạng WiFi), dùng IP LAN của máy tính. 10.12.3.16         192.168.1.9
  //   (Mở cmd/terminal, gõ `ipconfig` (Windows) hoặc `ifconfig` (macOS/Linux))
  static const String graphqlUrl = "http://192.168.1.9:4000/"; 
}