import 'package:flutter/material.dart';

class UpdateStatusDialog extends StatefulWidget {
  final String currentOrderStatus;
  final String currentPaymentStatus;
  
  const UpdateStatusDialog({
    super.key,
    required this.currentOrderStatus,
    required this.currentPaymentStatus
  });

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late String _selectedOrderStatus;
  late String _selectedPaymentStatus;

  // Danh sách các trạng thái để admin chọn
  final List<String> orderStatusOptions = ['pending', 'confirmed', 'processing', 'shipping', 'delivered', 'cancelled'];
  final List<String> paymentStatusOptions = ['pending', 'paid', 'failed', 'refunded'];

  @override
  void initState() {
    super.initState();
    _selectedOrderStatus = widget.currentOrderStatus;
    _selectedPaymentStatus = widget.currentPaymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật Trạng thái'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown cho trạng thái đơn hàng
          DropdownButtonFormField<String>(
            value: _selectedOrderStatus,
            decoration: const InputDecoration(labelText: 'Trạng thái Đơn hàng'),
            items: orderStatusOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedOrderStatus = newValue!;
              });
            },
          ),
          const SizedBox(height: 16),
          // Dropdown cho trạng thái thanh toán
          DropdownButtonFormField<String>(
            value: _selectedPaymentStatus,
            decoration: const InputDecoration(labelText: 'Trạng thái Thanh toán'),
            items: paymentStatusOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedPaymentStatus = newValue!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            // Trả về kết quả là một Map chứa các giá trị mới
            Navigator.of(context).pop({
              'orderStatus': _selectedOrderStatus,
              'paymentStatus': _selectedPaymentStatus,
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}