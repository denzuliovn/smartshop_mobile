import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Phần thông tin giao hàng
          Text('Thông tin giao hàng', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Họ và tên')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Số điện thoại')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Địa chỉ')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Phương thức thanh toán
          Text('Phương thức thanh toán', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Thanh toán khi nhận hàng (COD)'),
                    value: 'cod',
                    groupValue: 'cod',
                    onChanged: (value) {},
                  ),
                  RadioListTile(
                    title: const Text('Chuyển khoản ngân hàng'),
                    value: 'bank',
                    groupValue: 'cod',
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Tóm tắt đơn hàng
          Text('Tóm tắt', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tạm tính'), Text('36,980,000₫')]),
                  SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Phí vận chuyển'), Text('Miễn phí')]),
                  Divider(height: 32),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('36,980,000₫', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                ],
              ),
            ),
          ),
        ],
      ),
       bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Handle place order
            // Tạm thời hiển thị dialog và quay về home
             showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đặt hàng thành công!'),
                  content: const Text('Cảm ơn bạn đã mua sắm tại SmartShop.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.go('/');
                      },
                      child: const Text('OK'),
                    )
                  ],
                ),
              );
          },
          child: const Text('Xác nhận đặt hàng'),
        ),
       ),
    );
  }
}