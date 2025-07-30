import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/application/product_providers.dart';

final filterDataProvider = FutureProvider.autoDispose((ref) async {
  final results = await Future.wait([
    ref.watch(categoriesProvider.future),
    ref.watch(brandsProvider.future),
  ]);
  return {
    'categories': results[0] as List<Category>,
    'brands': results[1] as List<Brand>,
  };
});

class FilterScreen extends ConsumerStatefulWidget {
  final ProductListFilter initialFilter;
  const FilterScreen({super.key, required this.initialFilter});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late String? _selectedCategory;
  late String? _selectedBrand;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialFilter.condition['category'];
    _selectedBrand = widget.initialFilter.condition['brand'];
    _minPriceController.text = widget.initialFilter.condition['price']?['min']?.toString() ?? '';
    _maxPriceController.text = widget.initialFilter.condition['price']?['max']?.toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final Map<String, dynamic> newCondition = {};
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) newCondition['category'] = _selectedCategory;
    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) newCondition['brand'] = _selectedBrand;

    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    if (minPrice != null || maxPrice != null) {
      newCondition['price'] = {
        if (minPrice != null) 'min': minPrice,
        if (maxPrice != null) 'max': maxPrice,
      };
    }
    
    // Tạo một object filter mới, giữ nguyên orderBy và trả về
    final newFilter = widget.initialFilter.copyWith(condition: newCondition, page: 1);
    Navigator.of(context).pop(newFilter);
  }
  
  void _clearFilters() {
     // Tạo một object filter đã xóa condition và trả về
     final newFilter = widget.initialFilter.copyWith(condition: {}, page: 1);
     Navigator.of(context).pop(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final filterDataAsync = ref.watch(filterDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lọc sản phẩm'),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Xóa bộ lọc'))
        ],
      ),
      body: filterDataAsync.when(
        data: (data) {
          final categories = data['categories'] as List<Category>;
          final brands = data['brands'] as List<Brand>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Danh mục', style: Theme.of(context).textTheme.titleLarge),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                hint: const Text('Tất cả danh mục'),
                onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Tất cả danh mục')),
                  ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
              ),
              const SizedBox(height: 24),
              Text('Thương hiệu', style: Theme.of(context).textTheme.titleLarge),
              DropdownButton<String>(
                value: _selectedBrand,
                isExpanded: true,
                hint: const Text('Tất cả thương hiệu'),
                onChanged: (String? newValue) => setState(() => _selectedBrand = newValue),
                items: [
                   const DropdownMenuItem<String>(value: null, child: Text('Tất cả thương hiệu')),
                   ...brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                ],
              ),
              const SizedBox(height: 24),
              Text('Khoảng giá', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _minPriceController, decoration: const InputDecoration(labelText: 'Từ', prefixText: '₫ '), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: _maxPriceController, decoration: const InputDecoration(labelText: 'Đến', prefixText: '₫ '), keyboardType: TextInputType.number)),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu lọc: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: _applyFilters, child: const Text('Áp dụng')),
      ),
    );
  }
}