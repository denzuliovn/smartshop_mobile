// FILE PATH: lib/features/products/presentation/widgets/review_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';

class ReviewList extends ConsumerWidget {
  final String productId;
  const ReviewList({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Chưa có đánh giá nào.')));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(review.user.avatarUrl ?? '')),
              title: Text('${review.user.firstName} ${review.user.lastName}'),
              subtitle: Text(review.comment),
              trailing: Text(AppFormatters.formatDate(review.createdAt)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Lỗi tải đánh giá: $e')),
    );
  }
}