import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/products/data/product_repository.dart';

// 1. Định nghĩa các trạng thái của việc tìm kiếm
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Product> products;
  final String query;
  SearchLoaded(this.products, this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// 2. Định nghĩa trạng thái Speech-to-Text
enum SpeechStatus { inactive, listening, stopped, error }

class SpeechState {
  final SpeechStatus status;
  final String recognizedText;
  final String errorMessage;
  final bool isAvailable;
  final double confidenceLevel;

  const SpeechState({
    this.status = SpeechStatus.inactive,
    this.recognizedText = '',
    this.errorMessage = '',
    this.isAvailable = false,
    this.confidenceLevel = 0.0,
  });

  SpeechState copyWith({
    SpeechStatus? status,
    String? recognizedText,
    String? errorMessage,
    bool? isAvailable,
    double? confidenceLevel,
  }) {
    return SpeechState(
      status: status ?? this.status,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
      isAvailable: isAvailable ?? this.isAvailable,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }
}

// 3. Tạo StateNotifier với Speech-to-Text
class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounce;
  late stt.SpeechToText _speech;
  
  // Speech state
  SpeechState _speechState = const SpeechState();
  SpeechState get speechState => _speechState;
  
  // Stream controller để emit speech state changes
  final _speechStateController = StreamController<SpeechState>.broadcast();
  Stream<SpeechState> get speechStateStream => _speechStateController.stream;

  SearchNotifier(this._ref) : super(SearchInitial()) {
    _initializeSpeech();
  }

  // Khởi tạo Speech-to-Text
  Future<void> _initializeSpeech() async {
    try {
      _speech = stt.SpeechToText();
      bool isAvailable = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      
      _updateSpeechState(_speechState.copyWith(isAvailable: isAvailable));
    } catch (e) {
      _updateSpeechState(_speechState.copyWith(
        errorMessage: 'Không thể khởi tạo Speech-to-Text: $e',
        status: SpeechStatus.error,
      ));
    }
  }

  // Cập nhật speech state và emit stream
  void _updateSpeechState(SpeechState newState) {
    _speechState = newState;
    _speechStateController.add(_speechState);
  }

  // Callback khi status speech thay đổi
  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    switch (status) {
      case 'listening':
        _updateSpeechState(_speechState.copyWith(status: SpeechStatus.listening));
        break;
      case 'notListening':
        _updateSpeechState(_speechState.copyWith(status: SpeechStatus.stopped));
        break;
      case 'done':
        _updateSpeechState(_speechState.copyWith(status: SpeechStatus.inactive));
        break;
    }
  }

  // Callback khi có lỗi speech
  void _onSpeechError(dynamic error) {
    debugPrint('Speech error: $error');
    _updateSpeechState(_speechState.copyWith(
      status: SpeechStatus.error,
      errorMessage: error.toString(),
    ));
  }

  // Bắt đầu nghe giọng nói
  Future<void> startListening({
    String localeId = 'vi_VN', // Mặc định tiếng Việt
    bool partialResults = true,
  }) async {
    if (!_speechState.isAvailable) {
      _updateSpeechState(_speechState.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Speech-to-Text không khả dụng',
      ));
      return;
    }

    if (_speechState.status == SpeechStatus.listening) {
      return; // Đã đang nghe rồi
    }

    try {
      _updateSpeechState(_speechState.copyWith(
        status: SpeechStatus.listening,
        recognizedText: '',
        errorMessage: '',
        confidenceLevel: 0.0,
      ));

      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: localeId,
        partialResults: partialResults,
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      _updateSpeechState(_speechState.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Lỗi khi bắt đầu nghe: $e',
      ));
    }
  }

  // Callback khi có kết quả speech - FIXED: Sử dụng đúng type
  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords;
    final confidence = result.confidence;
    
    _updateSpeechState(_speechState.copyWith(
      recognizedText: recognizedText,
      confidenceLevel: confidence,
    ));

    // Nếu là kết quả cuối cùng và có độ tin cậy cao, tự động tìm kiếm
    if (result.finalResult && confidence > 0.5 && recognizedText.isNotEmpty) {
      search(recognizedText);
    }
  }

  // Dừng nghe giọng nói
  Future<void> stopListening() async {
    if (_speechState.status == SpeechStatus.listening) {
      await _speech.stop();
      _updateSpeechState(_speechState.copyWith(status: SpeechStatus.stopped));
    }
  }

  // Hủy speech recognition
  Future<void> cancelListening() async {
    if (_speechState.status == SpeechStatus.listening) {
      await _speech.cancel();
      _updateSpeechState(_speechState.copyWith(
        status: SpeechStatus.inactive,
        recognizedText: '',
      ));
    }
  }

  // Toggle speech listening
  Future<void> toggleListening({String localeId = 'vi_VN'}) async {
    if (_speechState.status == SpeechStatus.listening) {
      await stopListening();
    } else {
      await startListening(localeId: localeId);
    }
  }

  // Tìm kiếm văn bản (từ keyboard hoặc speech)
  void search(String query) {
    // Hủy debounce timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        state = SearchInitial();
        return;
      }
      
      if (query.length < 2) {
        state = SearchInitial(); // Không tìm nếu query quá ngắn
        return;
      }
      
      state = SearchLoading();
      try {
        final products = await _ref
            .read(productRepositoryProvider)
            .searchProducts(query.trim(), limit: 20);
        state = SearchLoaded(products, query.trim());
      } catch (e) {
        state = SearchError(e.toString());
      }
    });
  }

  // Tìm kiếm ngay lập tức (không debounce) - dùng cho speech result
  Future<void> searchImmediate(String query) async {
    if (query.trim().isEmpty) {
      state = SearchInitial();
      return;
    }
    
    state = SearchLoading();
    try {
      final products = await _ref
          .read(productRepositoryProvider)
          .searchProducts(query.trim(), limit: 20);
      state = SearchLoaded(products, query.trim());
    } catch (e) {
      state = SearchError(e.toString());
    }
  }

  // Xóa kết quả tìm kiếm
  void clear() {
    state = SearchInitial();
    // Reset speech state nhưng giữ isAvailable
    _updateSpeechState(_speechState.copyWith(
      status: SpeechStatus.inactive,
      recognizedText: '',
      errorMessage: '',
      confidenceLevel: 0.0,
    ));
  }

  // Lấy danh sách locale có sẵn
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (_speechState.isAvailable) {
      return await _speech.locales();
    }
    return [];
  }

  // Kiểm tra xem có đang nghe không
  bool get isListening => _speechState.status == SpeechStatus.listening;

  // Kiểm tra xem speech có khả dụng không
  bool get isSpeechAvailable => _speechState.isAvailable;

  // Lấy text hiện tại từ speech
  String get currentSpeechText => _speechState.recognizedText;

  // Lấy độ tin cậy của speech
  double get speechConfidence => _speechState.confidenceLevel;

  // Lấy thông báo lỗi speech
  String get speechError => _speechState.errorMessage;

  @override
  void dispose() {
    _debounce?.cancel();
    _speechStateController.close();
    super.dispose();
  }
}

// 4. Tạo Provider
final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

// 5. Provider để truy cập speech state stream
final speechStateStreamProvider = StreamProvider.autoDispose<SpeechState>((ref) {
  final notifier = ref.watch(searchProvider.notifier);
  return notifier.speechStateStream;
});

// 6. Provider để lấy các locale có sẵn
final availableLocalesProvider = FutureProvider.autoDispose<List<stt.LocaleName>>((ref) async {
  final notifier = ref.read(searchProvider.notifier);
  return await notifier.getAvailableLocales();
});

// 7. Các extension methods hữu ích
extension SearchNotifierExtension on SearchNotifier {
  // Tìm kiếm bằng giọng nói với locale tùy chỉnh
  Future<void> searchWithSpeech({
    String localeId = 'vi_VN',
    bool autoSearch = true,
  }) async {
    await startListening(localeId: localeId, partialResults: autoSearch);
  }

  // Lấy text suggestion dựa trên speech
  String getSpeechSuggestion() {
    if (_speechState.recognizedText.isNotEmpty && 
        _speechState.confidenceLevel > 0.3) {
      return _speechState.recognizedText;
    }
    return '';
  }

  // Kiểm tra xem có nên hiển thị speech button không
  bool shouldShowSpeechButton() {
    return _speechState.isAvailable && 
           _speechState.status != SpeechStatus.error;
  }
}