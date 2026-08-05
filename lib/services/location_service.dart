import 'dart:convert';
import 'package:flutter/services.dart';

class LocationService {
  static Map<String, List<String>>? _regionTownshipsMap;

  static Future<Map<String, List<String>>> loadLocationData() async {
    if (_regionTownshipsMap != null) return _regionTownshipsMap!;

    try {
      final String jsonString = await rootBundle.loadString('assets/myanmar-townships.json');
      _regionTownshipsMap = parseLocationJson(jsonString);
      return _regionTownshipsMap!;
    } catch (_) {
      // Fallback default dataset for offline/unit test execution
      return getFallbackLocationData();
    }
  }

  static Map<String, List<String>> parseLocationJson(String jsonString) {
    final Map<String, dynamic> rawJson = jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<String, List<String>> resultMap = {};

    rawJson.forEach((regionName, districtsMap) {
      final Set<String> townshipsSet = {};
      if (districtsMap is Map<String, dynamic>) {
        districtsMap.forEach((districtName, townshipsList) {
          if (townshipsList is List) {
            for (final t in townshipsList) {
              if (t is String) {
                townshipsSet.add(t);
              }
            }
          }
        });
      }
      final sortedTownships = townshipsSet.toList()..sort();
      resultMap[regionName] = sortedTownships;
    });

    return resultMap;
  }

  static Map<String, List<String>> getFallbackLocationData() {
    return {
      'Yangon Region': [
        'Ahlone',
        'Bahan',
        'Dagon',
        'Hledan',
        'Kamayut',
        'Kyauktada',
        'Mayangone',
        'Pabedan',
        'Sanchaung',
        'Tamwe',
        'Yankin',
      ],
      'Mandalay Region': [
        'Amarapura',
        'Aungmyethazan',
        'Chanayethazan',
        'Chanmyathazi',
        'Mahaaungmye',
        'Patheingyi',
        'Pyigyidagun',
        'Pyinoolwin',
      ],
      'Naypyidaw Union Territory': [
        'Dekkhinathiri',
        'Ottarathiri',
        'Pyinmana',
        'Tatkon',
        'Zabuthiri',
      ],
      'Shan State': [
        'Kengtung',
        'Lashio',
        'Taunggyi',
      ],
    };
  }

  static List<String> getRegions(Map<String, List<String>> data) {
    final regions = data.keys.toList()..sort();
    return regions;
  }

  static List<String> getTownships(Map<String, List<String>> data, String? region) {
    if (region == null || !data.containsKey(region)) return [];
    return data[region]!;
  }
}
