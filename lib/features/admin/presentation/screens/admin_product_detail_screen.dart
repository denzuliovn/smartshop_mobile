// FILE PATH: lib/features/admin/presentation/screens/admin_product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductDetailScreen extends ConsumerWidget {
  final String productId;
  const AdminProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết Sản phẩm'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Thông số'),
              Tab(text: 'Đánh giá'),
            ],
          ),
        ),
        body: productAsync.when(
          data: (product) => TabBarView(
            children: [
              // Tab 1: Tổng quan
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (product.images.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: CachedNetworkImage(imageUrl: product.images[0], fit: BoxFit.contain),
                    ),
                  const SizedBox(height: 16),
                  Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(AppFormatters.currency.format(product.price), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Kho: ${product.stock}"),
                ],
              ),
              // Tab 2: Thông số
              ListView(padding: const EdgeInsets.all(16), children: [Text(product.description)]),
              // Tab 3: Đánh giá
              const Center(child: Text("Tính năng đánh giá đang phát triển.")),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Lỗi: $e')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/admin/products/edit/${productId}'),
          child: const Icon(Icons.edit),
          tooltip: 'Chỉnh sửa',
        ),
      ),
    );
  }
}