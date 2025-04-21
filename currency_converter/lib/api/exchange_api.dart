import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/exchange_rate.dart';
import 'package:intl/intl.dart'; // DateFormat 사용

Future<List<ExchangeRate>> fetchExchangeRates(String authKey) async {
  final now = DateTime.now();
  final searchDate = DateFormat('yyyyMMdd').format(now); // 현재 날짜를 YYYYMMDD 형식으로 포맷팅
  final url = Uri.parse(
      'https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=$authKey&searchdate=$searchDate&data=AP01');

    print('🔗 요청 URL: $url');
  final response = await http.get(url, headers: {
    'Accept': 'application/json', // JSON 응답을 기대한다고 명시
    'User-Agent': 'Mozilla/5.0',
  });

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => ExchangeRate.fromJson(json)).toList();
  } else {
    throw Exception('API 요청 실패: ${response.statusCode}');
  }
}