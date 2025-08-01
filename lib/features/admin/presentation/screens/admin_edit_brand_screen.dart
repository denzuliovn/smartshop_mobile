// FILE PATH: lib/features/admin/presentation/screens/admin_edit_brand_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';

class AdminEditBrandScreen extends ConsumerStatefulWidget {
  final Brand brand;
  const AdminEditBrandScreen({super.key, required this.brand});

  @override
  ConsumerState<AdminEditBrandScreen> createState() => _AdminEditBrandScreenState();
}

class _AdminEditBrandScreenState extends ConsumerState<AdminEditBrandScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  // Thêm các controller khác nếu muốn sửa các trường khác của Brand
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand.name);
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = { 'name': _nameController.text.trim() };
        await ref.read(adminRepositoryProvider).updateBrand(widget.brand.id, data);

        ref.refresh(brandsProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sửa Thương hiệu')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên thương hiệu'),
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Lưu thay đổi'),
            )
          ],
        ),
      ),
    );
  }
}