import 'dart:convert';
import 'package:currency_converter/models/conversion_model.dart';
import 'package:currency_converter/models/currency_model.dart';
import 'package:http/http.dart' as http;

class Apiservices {
  static const String baseurl = 'https://api.frankfurter.app';

  Future<List<CurrencyModel>> getCurrenciesList() async {
    final response = await http.get(Uri.parse('$baseurl/currencies'));
    if (response.statusCode != 200) {
      throw Exception('Error getting currencies list');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);

    return data.entries.map((entry) {
      return CurrencyModel(
        code: entry.key,
        name: entry.value,
        flag: currencyToFlag[entry.key] ?? '🏳️',
      );
    }).toList();
  }

  Future<ConversionModel> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final response = await http.get(
      Uri.parse('$baseurl/latest?amount=$amount&from=$from&to=$to'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error converting currency');
    }

    return ConversionModel.fromJson(jsonDecode(response.body));
  }

  static const Map<String, String> currencyToFlag = {
    'AUD': '🇦🇺',
    'BRL': '🇧🇷',
    'CAD': '🇨🇦',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'CZK': '🇨🇿',
    'DKK': '🇩🇰',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'HKD': '🇭🇰',
    'HUF': '🇭🇺',
    'IDR': '🇮🇩',
    'ILS': '🇮🇱',
    'INR': '🇮🇳',
    'ISK': '🇮🇸',
    'JPY': '🇯🇵',
    'KRW': '🇰🇷',
    'MXN': '🇲🇽',
    'MYR': '🇲🇾',
    'NOK': '🇳🇴',
    'NZD': '🇳🇿',
    'PHP': '🇵🇭',
    'PLN': '🇵🇱',
    'RON': '🇷🇴',
    'SEK': '🇸🇪',
    'SGD': '🇸🇬',
    'THB': '🇹🇭',
    'TRY': '🇹🇷',
    'USD': '🇺🇸',
    'ZAR': '🇿🇦',
  };
}
