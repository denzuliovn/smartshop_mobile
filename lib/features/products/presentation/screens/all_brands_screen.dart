// FILE PATH: lib/features/products/presentation/screens/all_brands_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/utils/icon_mapper.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';

class AllBrandsScreen extends ConsumerWidget {
  const AllBrandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Thương hiệu'),
      ),
      body: brandsAsync.when(
        data: (brands) {
          if (brands.isEmpty) {
            return const Center(child: Text('Không có thương hiệu nào.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(
                    '/products?brandId=${brand.id}&brandName=${Uri.encodeComponent(brand.name)}',
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconMapper.getBrandIcon(brand.name),
                        size: 48,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        brand.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải thương hiệu: $err')),
      ),
    );
  }
}