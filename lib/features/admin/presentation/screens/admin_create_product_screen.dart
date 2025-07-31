import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:smartshop_mobile/features/admin/presentation/widgets/product_form.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/features/admin/data/upload_repository.dart'; 

class AdminCreateProductScreen extends ConsumerWidget {
  const AdminCreateProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo sản phẩm mới')),
      body: ProductForm(
        onSave: (data, imageFiles) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final newProduct = await ref.read(adminRepositoryProvider).createProduct(data);
      
      if (imageFiles.isNotEmpty) {
        // Chỉ cần gọi upload và không cần đợi kết quả
        await ref.read(uploadRepositoryProvider).uploadProductImages(newProduct.id, imageFiles);
      }
      
      ref.refresh(adminProductsProvider); // Làm mới danh sách sản phẩm
      context.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Tạo sản phẩm thành công!'), backgroundColor: Colors.green));

        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
        }
      },

      ),
    );
  }
}