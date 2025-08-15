import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetService {
  GoogleSheetService._();

  static const _dataUrl =
      'https://hectororviz.github.io/csdsoler-data/data.json';

  static final Map<String, List<List<dynamic>>> _cache = {};
  static Map<String, dynamic>? _jsonData;

  static const Map<String, String> _gidToKey = {
    '970777381': 'home',
    '1525215119': 'sabado',
    '761656977': 'domingo',
    '0': 'femenino',
    '1462115415': 'general',
    '1106797410': 'sub-9',
    '1925253457': 'sub-11',
    '1979916640': 'sub-14',
    '255628422': 'sub-17',
    '1643111789': 'primera',
    '11359234': 'damas',
  };

  static Future<List<List<dynamic>>> fetchSheet(String gid) async {
    if (_cache.containsKey(gid)) {
      return _cache[gid]!;
    }

    final key = _gidToKey[gid];
    if (key == null) {
      throw Exception('No data mapping for gid: $gid');
    }

    if (_jsonData == null) {
      final response = await http.get(Uri.parse(_dataUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch data');
      }
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      _jsonData = decoded['data'] as Map<String, dynamic>;
    }

    final section = _jsonData![key] as List<dynamic>?;
    if (section == null || section.isEmpty) {
      throw Exception('No data for section: $key');
    }

    final headers = (section.first as Map<String, dynamic>).keys.toList();
    final List<List<dynamic>> rows = [headers];

    for (final item in section) {
      final map = item as Map<String, dynamic>;
      rows.add(headers.map((h) => map[h] ?? '').toList());
    }

    _cache[gid] = rows;
    return rows;
  }
}
