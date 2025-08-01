

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/search_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

// class SearchScreen extends ConsumerStatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   ConsumerState<SearchScreen> createState() => _SearchScreenState();
// }


class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  // Danh sách các từ khóa gợi ý
  final List<String> _hotKeywords = [
    'iPhone 15', 'Macbook Pro', 'Tai nghe', 'Samsung S24', 
    'Flip', 'Apple Watch'
  ];

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(searchProvider);
    String currentQuery = '';
    if (currentState is SearchLoaded) {
      currentQuery = currentState.query;
    }
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


//   String _getImageUrl(String? imagePath) {
//     if (imagePath == null || imagePath.isEmpty) return '';
//     if (imagePath.startsWith('http')) return imagePath;
//     if (imagePath.startsWith('/')) return "${ApiConstants.baseUrl}$imagePath";
//     return "${ApiConstants.baseUrl}/img/$imagePath";
//   }


  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clear();
                      });
                    },
                  )
                : null,
          ),
          onChanged: (query) {
            setState(() {}); // Cập nhật UI để nút clear hiện ra
            ref.read(searchProvider.notifier).search(query);
          },
        ),
      ),
      body: _buildSearchResults(searchState),
    );
  }

  // Widget để hiển thị các gợi ý tìm kiếm
  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm kiếm phổ biến',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12.0, // Khoảng cách ngang
            runSpacing: 12.0, // Khoảng cách dọc
            children: _hotKeywords.map((keyword) {
              return ActionChip(
                label: Text(keyword),
                onPressed: () {
                  _searchController.text = keyword;
                  // Di chuyển con trỏ đến cuối text
                  _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _searchController.text.length));
                  setState(() {});
                  ref.read(searchProvider.notifier).search(keyword);
                },
                backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300)
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget để build kết quả tìm kiếm hoặc gợi ý
  Widget _buildSearchResults(SearchState searchState) {
    return switch (searchState) {
      // SỬA Ở ĐÂY: Hiển thị gợi ý khi ở trạng thái ban đầu
      SearchInitial() => _buildSuggestions(),

      SearchLoading() => const Center(child: CircularProgressIndicator()),
      
      SearchLoaded(products: final products) => products.isEmpty
          ? const Center(child: Text('Không tìm thấy sản phẩm nào.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = _getImageUrl(
                    product.images.isNotEmpty ? product.images[0] : null);

                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported),
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  title: Text(product.name),
                  subtitle: Text(AppFormatters.currency.format(product.price)),
                  onTap: () => context.push('/product/${product.id}'),
                );
              },
            ),
      
      SearchError(message: final message) =>
          Center(child: Text('Lỗi: $message')),
      
      _ => const Center(child: Text('Trạng thái không xác định.')),
    };
  }
}
