import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(this);
  }

  String get formattedDateTime {
    return DateFormat('MMM d, HH:mm').format(this);
  }
}
