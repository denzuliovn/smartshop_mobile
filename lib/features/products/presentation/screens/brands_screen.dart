import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);

    return Scaffold(
      // AppBar đã được cung cấp bởi MainScreen
      body: brandsAsync.when(
        data: (brands) => GridView.builder(
          padding: const EdgeInsets.all(16),
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
                onTap: () { /* TODO: Navigate to products by brand */ },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    imageUrl: brand.logoUrl ?? '',
                    errorWidget: (context, url, error) => Center(child: Text(brand.name, textAlign: TextAlign.center)),
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: ${err.toString()}')),
      ),
    );
  }
}