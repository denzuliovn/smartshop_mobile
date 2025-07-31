import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/products/data/product_repository.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String productId;
  const WriteReviewScreen({super.key, required this.productId});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  void _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn số sao.')));
      return;
    }
    
    try {
      await ref.read(productRepositoryProvider).createReview(
        productId: widget.productId,
        rating: _rating,
        comment: _commentController.text,
      );
      Navigator.of(context).pop(true); // Trả về true để báo hiệu đã submit thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viết đánh giá')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bạn đánh giá sản phẩm này thế nào?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
              onPressed: () => setState(() => _rating = index + 1),
            )),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Chia sẻ cảm nhận của bạn',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Gửi đánh giá'),
          ),
        ],
      ),
    );
  }
}