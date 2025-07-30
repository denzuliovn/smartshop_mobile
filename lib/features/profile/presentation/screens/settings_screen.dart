import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // --- Giao diện ---
          _buildSectionHeader(context, 'Giao diện'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Chế độ Sáng/Tối'),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  // Dựa vào giá trị enum của ThemeMode để gọi provider
                  if (newValue == ThemeMode.light) {
                     ref.read(themeProvider.notifier).setThemeMode(ThemeModeOption.light);
                  } else if (newValue == ThemeMode.dark) {
                     ref.read(themeProvider.notifier).setThemeMode(ThemeModeOption.dark);
                  } else {
                     ref.read(themeProvider.notifier).setThemeMode(ThemeModeOption.system);
                  }
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Hệ thống')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Sáng')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối')),
              ],
            ),
          ),

          const Divider(),

          // --- Hỗ trợ & Liên hệ ---
          _buildSectionHeader(context, 'Hỗ trợ & Liên hệ'),
          _buildMenuItem(context, icon: Icons.help_outline, title: 'Câu hỏi thường gặp (FAQ)', onTap: () => _showMockContent(context, 'FAQ', mockFaqContent)),
          _buildMenuItem(context, icon: Icons.support_agent, title: 'Liên hệ CSKH', onTap: () => _showMockContent(context, 'Liên hệ CSKH', mockContactContent)),
          _buildMenuItem(context, icon: Icons.feedback_outlined, title: 'Gửi phản hồi / Báo lỗi', onTap: () {}),

          const Divider(),

          // --- Điều khoản & Chính sách ---
          _buildSectionHeader(context, 'Điều khoản & Chính sách'),
          _buildMenuItem(context, icon: Icons.article_outlined, title: 'Điều khoản sử dụng', onTap: () => _showMockContent(context, 'Điều khoản sử dụng', mockTermsContent)),
          _buildMenuItem(context, icon: Icons.privacy_tip_outlined, title: 'Chính sách bảo mật', onTap: () => _showMockContent(context, 'Chính sách bảo mật', mockPrivacyContent)),
          _buildMenuItem(context, icon: Icons.assignment_return_outlined, title: 'Chính sách hoàn trả & bảo hành', onTap: () => _showMockContent(context, 'Chính sách', mockReturnPolicyContent)),
        ],
      ),
    );
  }

  // Helper widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Hàm hiển thị nội dung mock
  void _showMockContent(BuildContext context, String title, String content) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(content),
        ),
      ),
    ));
  }
}


// --- DỮ LIỆU MOCK (đặt ở cuối file hoặc trong file riêng) ---

const String mockFaqContent = """
**1. Làm thế nào để theo dõi đơn hàng của tôi?**
Bạn có thể vào mục "Đơn hàng" ở thanh điều hướng dưới cùng để xem trạng thái tất cả các đơn hàng đã đặt.

**2. SmartShop có hỗ trợ giao hàng toàn quốc không?**
Có, chúng tôi hỗ trợ giao hàng đến tất cả các tỉnh thành trên toàn quốc.

**3. Tôi có thể trả hàng nếu không ưng ý không?**
Có, bạn có thể tham khảo chi tiết trong "Chính sách hoàn trả & bảo hành".
""";

const String mockContactContent = """
**Tổng đài Chăm sóc Khách hàng:**
- **Hotline:** 1900 1234 (Cước phí 1.000đ/phút)
- **Email:** support@smartshop.com
- **Giờ hoạt động:** 8:00 - 22:00 tất cả các ngày trong tuần.

**Địa chỉ văn phòng:**
Số 1, Đường ABC, Quận 1, TP. Hồ Chí Minh
""";

const String mockTermsContent = """
📄 Điều khoản sử dụng
Cập nhật lần cuối: [Ngày/tháng/năm]

Chào mừng bạn đến với [Tên Ứng Dụng]! Khi sử dụng ứng dụng của chúng tôi, bạn đồng ý với các điều khoản sử dụng sau. Vui lòng đọc kỹ trước khi tiếp tục.

🔹 1. Chấp nhận điều khoản
Khi truy cập hoặc sử dụng ứng dụng, bạn đồng ý bị ràng buộc bởi các điều khoản này. Nếu bạn không đồng ý, vui lòng không sử dụng ứng dụng.

🔹 2. Tài khoản người dùng
Người dùng phải cung cấp thông tin chính xác khi đăng ký tài khoản.

Bạn có trách nhiệm giữ bảo mật thông tin đăng nhập.

Mọi hành động được thực hiện từ tài khoản của bạn sẽ được coi là do bạn thực hiện.

🔹 3. Hành vi bị cấm
Bạn không được phép:

Giả mạo danh tính hoặc sử dụng thông tin sai sự thật.

Can thiệp vào hệ thống, dữ liệu hoặc làm gián đoạn dịch vụ.

Đăng tải nội dung có tính xúc phạm, lừa đảo, hoặc vi phạm pháp luật.

Sử dụng ứng dụng với mục đích trái pháp luật hoặc gây hại cho bên thứ ba.

🔹 4. Giao dịch và đơn hàng
Chúng tôi cam kết cung cấp thông tin sản phẩm chính xác, minh bạch.

Giá cả có thể thay đổi mà không cần thông báo trước.

Đơn hàng chỉ có hiệu lực sau khi được chúng tôi xác nhận.

Trong trường hợp phát sinh lỗi kỹ thuật, hệ thống hoặc do sai sót giá, chúng tôi có quyền huỷ đơn hàng và hoàn tiền nếu đã thanh toán.

🔹 5. Sở hữu trí tuệ
Toàn bộ nội dung trong ứng dụng (logo, hình ảnh, văn bản, mã nguồn…) thuộc quyền sở hữu của [Tên công ty hoặc chủ sở hữu].

Bạn không được phép sao chép, sửa đổi, phát tán nội dung khi chưa có sự đồng ý bằng văn bản.

🔹 6. Giới hạn trách nhiệm
Chúng tôi không chịu trách nhiệm về:

Sự cố kỹ thuật ngoài ý muốn, mất kết nối mạng, hoặc lỗi hệ thống tạm thời.

Tổn thất phát sinh do hành vi sử dụng sai mục đích từ phía người dùng.

Bên thứ ba can thiệp trái phép nếu không xuất phát từ lỗi của chúng tôi.

🔹 7. Thay đổi điều khoản
Chúng tôi có thể cập nhật điều khoản này bất kỳ lúc nào. Phiên bản cập nhật sẽ có hiệu lực ngay khi được đăng tải. Người dùng nên kiểm tra định kỳ.

🔹 8. Liên hệ
Mọi thắc mắc hoặc yêu cầu hỗ trợ vui lòng liên hệ:

Email: support@tenapp.com

Hotline: 1900 123 456

Địa chỉ: Tầng 5, Tòa nhà XYZ, Quận 1, TP.HCM
""";
const String mockPrivacyContent = """ 
🛡️ Chính sách bảo mật
Cập nhật lần cuối: [Ngày/tháng/năm]

Ứng dụng [Tên ứng dụng] cam kết bảo vệ quyền riêng tư và thông tin cá nhân của người dùng. Chính sách bảo mật này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ dữ liệu của bạn khi sử dụng ứng dụng.

🔍 1. Thông tin chúng tôi thu thập
Chúng tôi có thể thu thập các loại thông tin sau:

Thông tin cá nhân: Họ tên, địa chỉ email, số điện thoại, địa chỉ giao hàng.

Thông tin đăng nhập: Tên người dùng, mật khẩu (được mã hóa).

Dữ liệu giao dịch: Lịch sử mua hàng, đơn hàng, phương thức thanh toán (chúng tôi không lưu trữ thông tin thẻ tín dụng).

Dữ liệu thiết bị: Loại thiết bị, hệ điều hành, địa chỉ IP, thông tin trình duyệt.

Thông tin hành vi người dùng: Sản phẩm đã xem, tìm kiếm, hoặc thêm vào danh sách yêu thích.

🧠 2. Mục đích sử dụng thông tin
Chúng tôi sử dụng thông tin của bạn để:

Cung cấp và cải thiện dịch vụ mua sắm.

Xử lý đơn hàng và giao hàng đúng địa chỉ.

Cá nhân hóa trải nghiệm mua sắm (gợi ý sản phẩm phù hợp).

Gửi thông báo về đơn hàng, khuyến mãi, hoặc cập nhật quan trọng.

Hỗ trợ người dùng khi cần thiết.

🔐 3. Bảo mật thông tin
Dữ liệu cá nhân được mã hóa và lưu trữ an toàn trên máy chủ.

Mật khẩu được mã hóa bằng các phương pháp hiện đại (ví dụ: SHA-256, bcrypt).

Chúng tôi sử dụng kết nối HTTPS để truyền dữ liệu an toàn giữa thiết bị và máy chủ.

Giới hạn truy cập nội bộ chỉ với nhân viên có thẩm quyền.

🤝 4. Chia sẻ thông tin với bên thứ ba
Chúng tôi không bán hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba trừ các trường hợp:

Đối tác giao hàng (chỉ tên, số điện thoại, địa chỉ giao hàng).

Nhà cung cấp dịch vụ thanh toán (bảo mật PCI-DSS).

Khi có yêu cầu hợp pháp từ cơ quan chức năng.

⚙️ 5. Quyền của người dùng
Người dùng có thể:

Xem, cập nhật, hoặc xoá thông tin cá nhân trong phần "Tài khoản".

Yêu cầu xóa tài khoản và toàn bộ dữ liệu liên quan bằng cách liên hệ [email hỗ trợ].

Hủy đăng ký nhận thông báo bất cứ lúc nào.
""";
const String mockReturnPolicyContent = """ 
🔁 Chính sách hoàn trả
Cập nhật lần cuối: [Ngày/tháng/năm]

Tại [Tên Ứng Dụng], chúng tôi cam kết mang đến trải nghiệm mua sắm tốt nhất cho bạn. Nếu sản phẩm bạn nhận được có lỗi, không đúng mô tả, hoặc không đạt kỳ vọng, bạn hoàn toàn có thể yêu cầu hoàn trả theo các điều kiện dưới đây:

📦 1. Điều kiện hoàn trả
Bạn có thể yêu cầu trả hàng nếu sản phẩm:

Bị lỗi kỹ thuật từ nhà sản xuất.

Bị hư hỏng trong quá trình vận chuyển.

Không đúng với sản phẩm đã đặt (sai mẫu, sai màu, sai thông số).

Còn trong thời hạn hoàn trả: 7 ngày kể từ ngày nhận hàng.

Sản phẩm còn nguyên vẹn (bao bì, tem niêm phong, phụ kiện đi kèm).

❌ Không áp dụng hoàn trả nếu:

Sản phẩm đã qua sử dụng, bị rơi vỡ, móp méo do người dùng.

Hết thời gian quy định hoàn trả.

Sản phẩm nằm trong danh mục không hỗ trợ đổi trả (ví dụ: thẻ cào, phần mềm đã kích hoạt, hàng giảm giá sâu,…).

📑 2. Quy trình hoàn trả
Gửi yêu cầu hoàn trả qua ứng dụng (trong mục “Đơn hàng” > “Yêu cầu hoàn trả”) hoặc liên hệ CSKH.

Đính kèm hình ảnh/video mô tả tình trạng sản phẩm.

Chờ hệ thống xác minh yêu cầu trong 1–2 ngày làm việc.

Nếu được chấp nhận, bạn sẽ:

Nhận thông tin hướng dẫn gửi hàng hoàn lại.

Hoặc được thu hồi sản phẩm tại địa chỉ giao hàng.

💸 3. Phương thức hoàn tiền
Sau khi nhận được sản phẩm trả về và kiểm tra, chúng tôi sẽ tiến hành hoàn tiền theo phương thức:

Hoàn vào tài khoản ngân hàng (3–7 ngày làm việc).

Hoặc hoàn vào ví điện tử nếu bạn đã thanh toán qua ví.

📞 4. Liên hệ hỗ trợ
Nếu có bất kỳ thắc mắc nào về hoàn trả, vui lòng liên hệ:

Email: support@tenapp.com

Hotline: 1900 123 456

Thời gian làm việc: 8:00 – 18:00 từ Thứ 2 đến Thứ 7

""";
