import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

// Định nghĩa kiểu dữ liệu cho callback onSave, bao gồm cả data và file ảnh
typedef ProductSaveCallback = void Function(Map<String, dynamic> data, List<XFile> imageFiles);

class ProductForm extends ConsumerStatefulWidget {
  final Product? product; // null nếu là tạo mới, có giá trị nếu là sửa
  final ProductSaveCallback onSave;

  const ProductForm({super.key, this.product, required this.onSave});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _skuController;
  late TextEditingController _originalPriceController;

  String? _selectedCategory;
  String? _selectedBrand;
  bool _isActive = true;
  bool _isFeatured = false;

  // State để quản lý ảnh
  List<XFile> _imageFiles = []; // Danh sách file ảnh mới chờ upload
  late List<String> _existingImages; // Danh sách ảnh đã có trên server
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceController = TextEditingController(text: p?.originalPrice?.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _skuController = TextEditingController(text: p?.id ?? 'SKU-${DateTime.now().millisecondsSinceEpoch}');
    _selectedCategory = p?.category?.id;
    _selectedBrand = p?.brand?.id;
    _isActive = p?.isActive ?? true;
    _isFeatured = p?.isFeatured ?? false;
    _existingImages = List<String>.from(p?.images ?? []);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'originalPrice': double.tryParse(_originalPriceController.text),
        'sku': _skuController.text.trim(),
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'isActive': _isActive,
        'isFeatured': _isFeatured,
        'images': _existingImages, // Gửi lại danh sách ảnh cũ đã được cập nhật
      };
      widget.onSave(data, _imageFiles); 
    }
  }
  
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80, // Nén ảnh một chút
    );
    if (pickedFiles.isNotEmpty) {
      if ((_existingImages.length + _imageFiles.length + pickedFiles.length) > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chỉ được upload tối đa 5 ảnh.'), backgroundColor: Colors.orange,)
        );
        return;
      }
      setState(() {
        _imageFiles.addAll(pickedFiles);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }
  
  void _removeExistingImage(int index) {
    // Logic này sẽ xóa ảnh khỏi danh sách sẽ được gửi đi khi cập nhật.
    // Việc xóa file thật trên server cần được thực hiện riêng.
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm*'), validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _skuController, decoration: const InputDecoration(labelText: 'SKU*'), validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Giá bán*'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Bắt buộc' : null)),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _originalPriceController, decoration: const InputDecoration(labelText: 'Giá gốc'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 16),
          TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Số lượng kho*'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Mô tả sản phẩm'), maxLines: 5),
          const SizedBox(height: 16),

          categoriesAsync.when(
            data: (categories) => DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Chọn danh mục*'),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              validator: (value) => value == null ? 'Bắt buộc' : null,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e,s) => Text('Lỗi tải danh mục: $e'),
          ),
          const SizedBox(height: 16),

           brandsAsync.when(
            data: (brands) => DropdownButtonFormField<String>(
              value: _selectedBrand,
              hint: const Text('Chọn thương hiệu*'),
              items: brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (val) => setState(() => _selectedBrand = val),
               validator: (value) => value == null ? 'Bắt buộc' : null,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e,s) => Text('Lỗi tải thương hiệu: $e'),
          ),
          const SizedBox(height: 24),
          
          Text('Hình ảnh sản phẩm', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          
          if (_existingImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _existingImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: "${ApiConstants.baseUrl}${_existingImages[index]}", fit: BoxFit.cover, errorWidget: (c,u,e) => const Icon(Icons.error)),
                    Positioned(
                      top: -8, right: -8,
                      child: IconButton(
                        icon: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        onPressed: () => _removeExistingImage(index),
                      ),
                    )
                  ],
                );
              },
            ),
          
          if (_imageFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                 return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(_imageFiles[index].path), fit: BoxFit.cover),
                    Positioned(
                      top: -8, right: -8,
                      child: IconButton(
                        icon: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        onPressed: () => _removeNewImage(index),
                      ),
                    )
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Thêm ảnh'),
            onPressed: _pickImages,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),

          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Kích hoạt sản phẩm'),
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
          ),
           SwitchListTile(
            title: const Text('Sản phẩm nổi bật'),
            value: _isFeatured,
            onChanged: (val) => setState(() => _isFeatured = val),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.product == null ? 'Tạo mới' : 'Lưu thay đổi'),
          )
        ],
      ),
    );
  }
}