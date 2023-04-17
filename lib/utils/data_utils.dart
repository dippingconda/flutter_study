import 'package:intl/intl.dart';

class DataUtils {
  static final oCcy = NumberFormat("#,###", "ko_KR");
  static String calcStringToWon(String price) {
    if (price != "") {
      return "${oCcy.format(int.parse(price))}원";
    } else {
      return "-원";
    }
  }
}
