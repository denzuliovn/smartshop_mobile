import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/features/products/application/search_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartshop_mobile/core/utils/formatter.dart';
import 'package:smartshop_mobile/core/constants/api_constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) return "${ApiConstants.baseUrl}$imagePath";
    return "${ApiConstants.baseUrl}/img/$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.watch(searchProvider.notifier);
    
    // Watch speech state stream
    final speechStateAsync = ref.watch(speechStateStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  border: InputBorder.none,
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchNotifier.clear();
                          },
                        )
                      : null,
                ),
                onChanged: (query) {
                  searchNotifier.search(query);
                },
              ),
            ),
            // Speech button
            speechStateAsync.when(
              data: (speechState) {
                return _buildSpeechButton(speechState, searchNotifier);
              },
              loading: () => const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Speech status indicator
          speechStateAsync.when(
            data: (speechState) => _buildSpeechStatusBar(speechState),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Search results
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechButton(SpeechState speechState, SearchNotifier notifier) {
    if (!speechState.isAvailable) {
      return const SizedBox.shrink();
    }

    final isListening = speechState.status == SpeechStatus.listening;
    final hasError = speechState.status == SpeechStatus.error;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: hasError ? null : () async {
            if (isListening) {
              await notifier.stopListening();
            } else {
              await notifier.startListening();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening 
                  ? Colors.red.withOpacity(0.1)
                  : hasError 
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
              border: Border.all(
                color: isListening 
                    ? Colors.red
                    : hasError 
                        ? Colors.grey
                        : Colors.blue,
                width: 2,
              ),
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening 
                  ? Colors.red
                  : hasError 
                      ? Colors.grey
                      : Colors.blue,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechStatusBar(SpeechState speechState) {
    if (speechState.status == SpeechStatus.inactive || 
        !speechState.isAvailable) {
      return const SizedBox.shrink();
    }

    String statusText = '';
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black87;

    switch (speechState.status) {
      case SpeechStatus.listening:
        statusText = 'Đang nghe... Hãy nói gì đó';
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case SpeechStatus.stopped:
        statusText = 'Đã dừng nghe';
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case SpeechStatus.error:
        statusText = 'Lỗi: ${speechState.errorMessage}';
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case SpeechStatus.inactive:
        return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            speechState.status == SpeechStatus.listening 
                ? Icons.mic 
                : speechState.status == SpeechStatus.error
                    ? Icons.error_outline
                    : Icons.mic_off,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (speechState.recognizedText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${speechState.recognizedText}"',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (speechState.status == SpeechStatus.listening && speechState.confidenceLevel > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(speechState.confidenceLevel * 100).toInt()}%',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    return switch (searchState) {
      SearchInitial() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nhập từ khóa để tìm kiếm\n(ít nhất 2 ký tự)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hoặc nhấn nút mic để tìm kiếm bằng giọng nói',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
      ),
      SearchLoading() => const Center(child: CircularProgressIndicator()),
      SearchLoaded(products: final products, query: final query) => products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy sản phẩm nào\ncho từ khóa "$query"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = _getImageUrl(product.images.isNotEmpty ? product.images[0] : null);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                      placeholder: (context, url) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    AppFormatters.currency.format(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () => context.push('/product/${product.id}'),
                );
              },
            ),
      SearchError(message: final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
      _ => const Center(child: Text('Trạng thái không xác định.')),
    };
  }
}