import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSheetService {
  GoogleSheetService._();

  static const _dataUrl =
      'https://hectororviz.github.io/csdsoler-data/data.json';

  static final Map<String, List<List<dynamic>>> _cache = {};
  static Map<String, dynamic>? _jsonData;
  static const _cacheKey = 'sheet_cache';
  static const _timestampKey = 'sheet_cache_timestamp';
  static const _cacheDuration = Duration(hours: 1);

  static const Map<String, String> _gidToKey = {
    '970777381': 'home',
    '1525215119': 'sabado',
    '761656977': 'domingo',
    '0': 'femenino',
    '1462115415': 'general',
    '1374959447': 'generald',
    '1086960525': 'generals',
    '1106797410': 'sub-9',
    '1925253457': 'sub-11',
    '1979916640': 'sub-14',
    '255628422': 'sub-17',
    '1643111789': 'primera',
    '11359234': 'damas',
    '1995683667': '2010',
    '1112937965': '2011',
    '498160849': '2012',
    '1037222485': '2013',
    '1385282857': '2014',
    '1076055031': '2015',
    '2003934986': '2016',
    '885589143': '2017',
    '175024698': '2018',
    '226882980': '2019',
    '1413392283': 's11',
    '1861449798': 's12',
    '1090489169': 's13',
    '1039814354': 's14',
    '885648606': 's15',
    '1975852740': 's16',
    '2063474123': 's17',
    '1940187087': 's18',
    '355695345': 's19',
  };

  static Future<List<List<dynamic>>> fetchSheet(String gid) async {
    if (_cache.containsKey(gid)) {
      return _cache[gid]!;
    }

    final key = _gidToKey[gid];
    if (key == null) {
      throw Exception('No data mapping for gid: $gid');
    }

    await _ensureData();

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

  static Future<void> _ensureData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final cached = prefs.getString(_cacheKey);
    final ts = prefs.getInt(_timestampKey);
    final cachedTime = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.fromMillisecondsSinceEpoch(0);
    final hasFreshCache =
        cached != null && now.difference(cachedTime) < _cacheDuration;

    if (_jsonData == null && hasFreshCache) {
      _jsonData = json.decode(cached!) as Map<String, dynamic>;
    }

    if (_jsonData == null || !hasFreshCache) {
      try {
        final response = await http.get(Uri.parse(_dataUrl));
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          _jsonData = decoded['data'] as Map<String, dynamic>;
          _cache.clear();
          await prefs.setString(_cacheKey, json.encode(_jsonData));
          await prefs.setInt(_timestampKey, now.millisecondsSinceEpoch);
          return;
        }
      } catch (_) {
        // ignore and fallback to cache if available
      }

      if (_jsonData == null) {
        if (cached != null) {
          _jsonData = json.decode(cached) as Map<String, dynamic>;
        } else {
          throw Exception('Failed to fetch data');
        }
      }
    }
  }
}
