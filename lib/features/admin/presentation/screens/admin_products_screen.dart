// FILE PATH: lib/features/admin/presentation/screens/admin_products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/admin/application/admin_providers.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';
import 'package:smartshop_mobile/features/admin/data/admin_repository.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  // --- CÁC BIẾN STATE MỚI ---
  bool _isSelectionMode = false;
  final Set<String> _selectedProductIds = {};

  Future<void> _showBulkUpdateDialog() async {
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật hàng loạt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhập giá trị mới cho ${_selectedProductIds.length} sản phẩm đã chọn. Bỏ trống nếu không muốn thay đổi.'),
            SizedBox(height: 16),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Giá mới'), keyboardType: TextInputType.number),
            SizedBox(height: 16),
            TextField(controller: stockController, decoration: InputDecoration(labelText: 'Số lượng kho mới'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop({
              'price': priceController.text,
              'stock': stockController.text
            }),
            child: Text('Cập nhật'),
          ),
        ],
      ),
    );

    if (result != null) {
      final double? newPrice = double.tryParse(result['price']!);
      final int? newStock = int.tryParse(result['stock']!);

      if (newPrice == null && newStock == null) return;

      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(adminRepositoryProvider).bulkUpdateProducts(
          ids: _selectedProductIds.toList(),
          price: newPrice,
          stock: newStock,
        );
        messenger.showSnackBar(SnackBar(content: Text('Đã cập nhật hàng loạt thành công.'), backgroundColor: Colors.green));
        _exitSelectionMode();
        ref.refresh(adminProductsProvider);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // Future<void> _importProducts() async {
  //   // 1. Chọn file
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['csv'],
  //   );

  //   if (result != null) {
  //     File file = File(result.files.single.path!);
  //     final messenger = ScaffoldMessenger.of(context);
  //     messenger.showSnackBar(SnackBar(content: Text('Đang import file: ${result.files.single.name}...')));

  //     try {
  //       // 2. Gọi API
  //       final importResult = await ref.read(adminRepositoryProvider).importProducts(file);

  //       // 3. Hiển thị kết quả
  //       await showDialog(
  //         context: context,
  //         builder: (ctx) => AlertDialog(
  //           title: Text('Kết quả Import'),
  //           content: Text(
  //             'Thành công: ${importResult['success']}\n'
  //             'Tạo mới: ${importResult['created']}\n'
  //             'Cập nhật: ${importResult['updated']}\n'
  //             'Lỗi: ${importResult['errors']?.length ?? 0}'
  //           ),
  //           actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))],
  //         ),
  //       );
  //       ref.refresh(adminProductsProvider); // Làm mới danh sách

  //     } catch (e) {
  //       messenger.showSnackBar(SnackBar(content: Text('Lỗi khi import: $e'), backgroundColor: Colors.red));
  //     }
  //   } else {
  //     // User canceled the picker
  //   }
  // }


  Future<void> _exportProducts() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Đang chuẩn bị file export...')));

    try {
      // 1. Lấy toàn bộ sản phẩm
      final products = await ref.read(adminRepositoryProvider).getAllProductsSimple();
      if (products.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Không có sản phẩm để export.'), backgroundColor: Colors.orange));
        return;
      }

      // 2. Chuyển đổi sang dạng List<List<dynamic>> cho thư viện CSV
      List<List<dynamic>> rows = [];
      // Thêm hàng tiêu đề
      rows.add(['ID', 'Name', 'SKU', 'Price', 'Stock', 'Category', 'Brand']);
      // Thêm dữ liệu sản phẩm
      for (var product in products) {
        rows.add([
          product.id,
          product.name,
          product.id, // Assuming SKU is the same as ID based on your code
          product.price,
          product.stock,
          product.category?.name ?? '',
          product.brand?.name ?? '',
        ]);
      }

      // 3. Tạo chuỗi CSV
      String csv = const ListToCsvConverter().convert(rows);

      // 4. Lưu vào file tạm và chia sẻ
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/products_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      Share.shareXFiles([XFile(path)], text: 'Danh sách sản phẩm SmartShop');

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi khi export: $e'), backgroundColor: Colors.red));
    }
  }


  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
      // Tự động thoát chế độ chọn nếu không còn sản phẩm nào được chọn
      if (_selectedProductIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode(String productId) {
    setState(() {
      _isSelectionMode = true;
      _selectedProductIds.add(productId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedProductIds.clear();
    });
  }

  Future<void> _deleteSelectedProducts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ${_selectedProductIds.length} sản phẩm đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(adminRepositoryProvider).deleteManyProducts(_selectedProductIds.toList());
        messenger.showSnackBar(SnackBar(content: Text('Đã xóa ${_selectedProductIds.length} sản phẩm.'), backgroundColor: Colors.green));
        _exitSelectionMode();
        ref.refresh(adminProductsProvider); // Làm mới danh sách
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // --- APPBAR ĐỘNG ---

  AppBar _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode),
        title: Text('${_selectedProductIds.length} đã chọn'),
        actions: [
          // THÊM NÚT MỚI
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _showBulkUpdateDialog,
            tooltip: 'Cập nhật hàng loạt',
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteSelectedProducts),
        ],
      );
    } else {
    return AppBar(
      title: const Text('Quản lý Sản phẩm'),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.upload_file_outlined),
        //   onPressed: _importProducts,
        //   tooltip: 'Import từ CSV',
        // ),
        IconButton(
          icon: const Icon(Icons.download_for_offline_outlined),
          onPressed: _exportProducts,
          tooltip: 'Export ra CSV',
        )
      ],
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminProductsProvider.future),
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('Không có sản phẩm nào.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductListItem(context, ref, products[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/products/create'),
        child: const Icon(Icons.add),
        tooltip: 'Thêm sản phẩm',
      ),
    );
  }

  // --- WIDGET DANH SÁCH ĐƯỢC CẬP NHẬT ---
  Widget _buildProductListItem(BuildContext context, WidgetRef ref, Product product) {
    final isSelected = _selectedProductIds.contains(product.id);

    String getImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return '';
      if (imagePath.startsWith('http')) return imagePath;
      if (imagePath.startsWith('/')) return "${ApiConstants.baseUrl}$imagePath";
      return "${ApiConstants.baseUrl}/img/$imagePath";
    }
    final imageUrl = product.images.isNotEmpty ? getImageUrl(product.images[0]) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(product.id);
          } else {
            context.push('/admin/products/detail/${product.id}');
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            _enterSelectionMode(product.id);
          }
        },
        leading: isSelected
            ? CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.check, color: Colors.white),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => Container(width: 50, height: 50, color: Colors.grey[200]),
                  placeholder: (c, u) => Container(width: 50, height: 50, color: Colors.grey[200]),
                ),
              ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Kho: ${product.stock}'),
        trailing: Text(AppFormatters.currency.format(product.price), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
      ),
    );
  }
}