import 'dart:convert';
import 'package:home_widget/home_widget.dart';

class MatchWidgetUpdater {
  static Future<void> updateMatches(List<List<dynamic>> data) async {
    if (data.isEmpty) return;
    final matches = <Map<String, String>>[];
    for (var i = 1; i < data.length; i++) {
      final row = data[i];
      if (row.length < 4) continue;
      matches.add({
        'dia': row[0].toString(),
        'fecha': row[1].toString(),
        'localia': row[2].toString(),
        'rival': row[3].toString(),
        'lat': row.length > 4 ? row[4].toString() : '',
        'long': row.length > 5 ? row[5].toString() : '',
      });
    }
    await HomeWidget.saveWidgetData<String>('matches', jsonEncode(matches));
    await HomeWidget.saveWidgetData<int>('match_index', 0);
    await HomeWidget.updateWidget(
      androidName: 'MatchHomeWidgetProvider',
      qualifiedAndroidName:
          'com.example.csdsolerapk.MatchHomeWidgetProvider',
    );
  }
}
