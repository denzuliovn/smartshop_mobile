import 'package:intl/intl.dart';

class AppFormatters {
  static final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}