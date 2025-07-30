import 'package:flutter/material.dart';
// Bỏ các import của Riverpod và provider đi

class ReviewList extends StatelessWidget {
  final String productId;
  const ReviewList({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // Tạm thời hiển thị một thông báo thay vì gọi API
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tính năng đánh giá đang được phát triển',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}