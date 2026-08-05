import 'dart:convert';
import 'package:flutter/services.dart';

class LocationService {
  static Map<String, List<String>>? _regionTownshipsMap;

  static Future<Map<String, List<String>>> loadLocationData() async {
    if (_regionTownshipsMap != null) return _regionTownshipsMap!;

    try {
      final String jsonString = await rootBundle.loadString('assets/myanmar-townships.json');
      _regionTownshipsMap = parseLocationJson(jsonString);
      if (_regionTownshipsMap!.isNotEmpty) {
        return _regionTownshipsMap!;
      }
    } catch (_) {}

    // Fallback to complete embedded dataset ensuring all 15 Regions/States work reliably
    _regionTownshipsMap = parseLocationJson(_embeddedLocationJson);
    return _regionTownshipsMap!;
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

  static List<String> getRegions(Map<String, List<String>> data) {
    if (data.isEmpty) {
      data = parseLocationJson(_embeddedLocationJson);
    }
    final regions = data.keys.toList()..sort();
    return regions;
  }

  static List<String> getTownships(Map<String, List<String>> data, String? region) {
    if (data.isEmpty) {
      data = parseLocationJson(_embeddedLocationJson);
    }
    if (region == null || !data.containsKey(region)) return [];
    return data[region]!;
  }

  static const String _embeddedLocationJson = r'''{
  "Magway Region": {
    "Gangaw": ["Gangaw", "Kyaukhtu", "Saw", "Tilin"],
    "Magway": ["Chauck", "Magway", "Myothit", "Natmauk", "Taungdwingyi", "Yenangyaung"],
    "Minbu": ["Minbu", "Ngape", "Pwintbyu", "Salin", "Sidoktaya"],
    "Pakokku": ["Myaing", "Pakokku", "Pauk", "Seikphyu", "Yesagyo"],
    "Thayet": ["Aunglan", "Kamma", "Mindon", "Minhla", "Sinbaungwe", "Thayet"]
  },
  "Mandalay Region": {
    "Kyaukse": ["Kyaukse", "Myittha", "Sintgaing", "Tada-U"],
    "Mandalay": ["Amarapura", "Aungmyethazan", "Chanayethazan", "Chanmyathazi", "Mahaaungmye", "Patheingyi", "Pyigyidagun"],
    "Meiktila": ["Mahlaing", "Meiktila", "Thazi", "Wundwin"],
    "Myingyan": ["Myingyan", "Natogyi", "Nganzun", "Thaungtha"],
    "Nyaung-U": ["Kyaukpadaung", "Ngathayauk", "Nyaung-U"],
    "Pyinoolwin": ["Madaya", "Mogok", "Pyinoolwin", "Singu", "Tagaung", "Thabeikkyin"],
    "Yamethin": ["Pyawbwe", "Yamethin"]
  },
  "Naypyidaw Union Territory": {
    "Dekkhina(South Naypyidaw)": ["Dekkhinathiri", "Lewe", "Pyinmana", "Zabuthiri"],
    "Ottara(North Naypyidaw)": ["Ottarathiri", "Pobbathiri", "Tatkon", "Zeyarthiri"]
  },
  "Kayah State": {
    "Bawlakhe": ["Bawlakhe", "Hpasawng", "Mese", "Ywathit"],
    "Loikaw": ["Demoso", "Hpruso", "Loikaw", "Shadaw"]
  },
  "Shan State": {
    "Kengtung": ["Kengtung", "Mine Pauk", "Minelar", "Mong Khet", "Mong La", "Mong Yang"],
    "Mong Hpayak": ["Mineyu", "Mong Hpayak", "Mong Yawng"],
    "Mong Hsat": ["Minekoke", "Monehta", "Mong Hsat", "Mong Ping", "Mong Tong", "Ponparkyin", "Tontar"],
    "Tachileik": ["Kyaing Lap", "Tachileik", "Talay"],
    "Kunlong": ["Kunlong"],
    "Kyaukme": ["Hsipaw", "Kyaukme", "Mantong", "Minelon", "Minengaw", "Namhsan", "Namtu", "Nawnghkio"],
    "Lashio": ["Hsenwi", "Lashio", "Mongyai", "Tangyan"],
    "Laukkaing": ["Chinshwehaw", "Konkyan", "Laukkaing", "Mawhtike"],
    "Mu Se": ["Kutkai", "Manhero", "Monekoe", "Mu Se", "Namhkam", "Pansai", "Tamoenye"],
    "Hopang": ["Hopang", "Mongmao", "Namtit", "Pangwaun", "Panlong"],
    "Matman": ["Man Kan", "Matman", "Namphan", "Pangsang Township"],
    "Mongmit": ["Mabein", "Mongmit"],
    "Langkho": ["Homane", "Kengtaung", "Langkho", "Mawkmai", "Mong Nai", "Mong Pan"],
    "Loilen": ["Karli", "Kholan", "Kunhing", "Kyethi", "Lai-Hka", "Loilen", "Minenaung", "Minesan", "Mong Hsu", "Mong Kung", "Nansang", "Panglong"],
    "Taunggyi": ["Hopong", "Hsi Hseng", "Indaw", "Kalaw", "Kyauktalongyi", "Lawksawk", "Naungtayar", "Nyaungshwe", "Pekon", "Pingdaya", "Pinlaung", "Taunggyi", "Ywangan"]
  },
  "Ayeyarwady Region": {
    "Hinthada": ["Hinthada", "Ingapu", "Kyangin", "Lemyethna", "Myanaung", "Zalun"],
    "Labutta": ["Labutta", "Mawlamyinegyun", "Pyinsalu"],
    "Ma-ubin": ["Danuphyu", "Ma-ubin", "Nyaungdon", "Pantanaw"],
    "Myaungmya": ["Einme", "Myaungmya", "Wakema"],
    "Pathein": ["Hainggyikyun", "Kangyidaunk", "Kyaunggon", "Kyonpyaw", "Ngapudaw", "Ngathaingchaung", "Ngayokaung", "Ngwehsaung", "Pathein", "Shwethaungyan", "Thabaung", "Yekyi"],
    "Pyapon": ["Ahmar", "Bogale", "Dedaye", "Kyaiklat", "Pyapon"]
  },
  "Bago Region": {
    "Bago": ["Aungmyin", "Bago", "Daik-U", "Hpayargyi", "Intagaw", "Kawa", "Kyauktaga", "Madauk", "Nyaunglebin", "Peinzalot", "Penwegon", "Pyuntaza", "Shwegyin", "Thanatpin", "Waw"],
    "Taungoo": ["Kanyutkwin", "Kaytumadi", "Kyaukkyi", "Kywebwe", "Mone", "Myohla", "Natthangwin", "Nyaungbinthar", "Oktwin", "Pyu", "Swa", "Tantabin", "Taungoo", "Thagara", "Yaeni", "Yedashe"],
    "Pyay": ["Innma", "Okshipin", "Padaung", "Padigone", "Paukkaung", "Paungdale", "Paungde", "Pyay", "Shwedaung", "Sinmeswe", "Thegon"],
    "Thayarwady": ["Gyobingauk", "Letpadan", "Minhla", "Monyo", "Nattalin", "Okpho", "Ooethegone", "Sitkwin", "Tapun", "Tharrawaddy", "Thonze", "Zigon"]
  },
  "Yangon Region": {
    "East Yangon": ["Botataung", "City", "Dagon Seikkan", "Dawbon", "East Dagon", "Mingala Taungnyunt", "North Dagon", "North Okkalapa", "Pazundaung", "South Dagon", "South Okkalapa", "Tamwe", "Thaketa", "Thingangyun", "Yankin"],
    "North Yangon": ["City", "Hlaingthaya", "Hlegu", "Hmawbi", "Htantabin", "Insein", "Mingaladon", "Rural", "Shwepyitha", "Taikkyi"],
    "South Yangon": ["City", "Cocokyun", "Dala", "Kawhmu", "Kayan", "Kungyangon", "Kyauktan", "Rural", "Seikkyi Kanaungto", "Tada", "Thanlyin", "Thongwa", "Twante"],
    "West Yangon(Downtown)": ["Ahlon", "Bahan", "City", "Dagon", "Hlaing", "Kamayut", "Kyauktada", "Kyimyindaing", "Lanmadaw", "Latha", "Mayangon", "Pabedan", "Sanchaung", "Seikkan"]
  },
  "Kachin State": {
    "Bhamo": ["Bhamo", "Dotphoneyan", "Lwegel", "Mansi", "Momauk", "Myohla", "Shwegu"],
    "Mohnyin": ["Hopin", "Hpakant", "Kamine", "Mogaung", "Mohnyin"],
    "Myitkyina": ["Chipwi", "Hsadone", "Hsawlaw", "Hsinbo", "Injangyang", "Kanpaikti", "Myitkyina", "Panwa", "Shinbwayyan", "Tanai", "Waingmaw"],
    "Putao": ["Kawnglanghpu", "Machanbaw", "Nogmung", "Pannandin", "Putao", "Sumprabum"]
  },
  "Sagaing Region": {
    "Hkamti": ["Donhee", "Hkamti", "Homalin", "Htanparkway", "Lahe", "Leshi", "Mobaingluk", "Nanyun", "Pansaung", "Sonemara"],
    "Kanbalu": ["Kanbalu", "Kyunhla", "Taze", "Ye-U"],
    "Kale": ["Kale", "Kalewa", "Mingin"],
    "Katha": ["Banmauk", "Indaw", "Katha", "Kawlin", "Pinlebu", "Tigyaing", "Wuntho"],
    "Mawlaik": ["Mawlaik", "Paungbyin"],
    "Monywa": ["Ayadaw", "Budalin", "Chaung-U", "Monywa"],
    "Sagaing": ["Myaung", "Myinmu", "Sagaing"],
    "Shwebo": ["Khin-U", "Kyaukmyaung", "Shwebo", "Tabayin", "Wetlet"],
    "Tamu": ["Khampat", "Myothit", "Tamu"],
    "Yinmabin": ["Kani", "Pale", "Salingyi", "Yinmabin"]
  },
  "Kayin State": {
    "Hpa-an": ["Bawgali", "Hlaignbwe", "Hpa-an", "Leiktho", "Paingkyon", "Shan Ywathit", "Thandaunggyi"],
    "Hpapun": ["Hpapun", "Kamamaung"],
    "Kawkareik": ["Kawkareik", "Kyaidon", "Kyain Seikgyi", "Payarthonezu"],
    "Myawaddy": ["Myawaddy", "Sugali", "Wawlaymyaing"]
  },
  "Mon State": {
    "Mawlamyine": ["Chaungzon", "Khawzar", "Kyaikkhami", "Kyaikmaraw", "Lamine", "Mawlamyine", "Mudon", "Thanbyuzayat", "Ye"],
    "Thaton": ["Bilin", "Kyaikto", "Mottama", "Paung", "Suvannawadi", "Thaton", "Zingyeik"]
  },
  "Tanintharyi Region": {
    "Dawei": ["Dawei", "Kaleinaung", "Launglon", "Myitta", "Thayetchaung", "Yebyu"],
    "Kawthoung": ["Bokpyin", "Karathuri", "Kawthoung", "Khamaukgyi", "Pyigyimandaing"],
    "Myeik": ["Kyunsu", "Myeik", "Palauk", "Palaw", "Tanintharyi"]
  },
  "Chin State": {
    "Falam": ["Cikha", "Falam", "Rikhuadal", "Tiddim", "Ton Zang"],
    "Hakha": ["Hakha", "Htantlang"],
    "Mindat": ["Kanpetlet", "Matupi", "Mindat", "Paletwa", "Reazu", "Sami"]
  },
  "Rakhine State": {
    "Kyaukpyu": ["Ann", "Kyaukpyu", "Manaung", "Ramree"],
    "Maungdaw": ["Buthidaung", "Maungdaw", "Taungpyoletwe"],
    "Sittwe": ["Pauktaw", "Ponnagyun", "Rathedaung", "Sittwe"],
    "Thandwe": ["Gaw", "Kyeintali", "Maei", "Thandwe", "Toungup"],
    "Mrauk-U": ["Kyauktaw", "Minbya", "Mrauk-U", "Myebon"]
  }
}''';
}
