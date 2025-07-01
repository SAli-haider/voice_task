import 'package:intl/intl.dart';

extension FormattedDate on DateTime {
  String toFormattedString() {
    return DateFormat('yyyy-MM-dd hh:mm a').format(this);
  }
}
