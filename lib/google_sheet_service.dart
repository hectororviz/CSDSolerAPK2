import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

class GoogleSheetService {
  GoogleSheetService._();

  static final Map<String, List<List<dynamic>>> _cache = {};

  static Future<List<List<dynamic>>> fetchSheet(String gid) async {
    if (_cache.containsKey(gid)) {
      return _cache[gid]!;
    }

    final url = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTH5wcJur5ysIqKDdpaRP3M1YDAXVME5Ztuo0zffL27P9crNqlDlbNp3Kg-DSOE9XapLGl9qwUO1hrZ/pub?gid=' + gid + '&output=csv';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = const CsvToListConverter().convert(response.body);
      _cache[gid] = data;
      return data;
    }
    throw Exception('Failed to fetch sheet');
  }
}
