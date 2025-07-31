import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:smartshop_mobile/features/admin/presentation/widgets/product_form.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:smartshop_mobile/features/admin/data/upload_repository.dart';

class AdminEditProductScreen extends ConsumerWidget {
  final String productId;
  const AdminEditProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa sản phẩm')),
      body: productAsync.when(
        data: (product) => ProductForm(
          product: product,
          onSave: (data, imageFiles) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              // Bước 1: Cập nhật thông tin text và danh sách ảnh CŨ
              await ref.read(adminRepositoryProvider).updateProduct(productId, data);

              // Bước 2: Upload ảnh MỚI nếu có
              if (imageFiles.isNotEmpty) {
                 await ref.read(uploadRepositoryProvider).uploadProductImages(productId, imageFiles);
                 messenger.showSnackBar(
                   SnackBar(content: Text('Đã upload ${imageFiles.length} ảnh mới.'))
                 );
              }

              // Bước 3: Làm mới danh sách và quay lại
              ref.refresh(adminProductsProvider); // Làm mới danh sách chung
              ref.refresh(productDetailProvider(productId)); // Làm mới chi tiết sản phẩm này
              context.pop();
              messenger.showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
            } catch (e) {
               messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
            }
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Lỗi tải sản phẩm: $e')),
      ),
    );
  }
}