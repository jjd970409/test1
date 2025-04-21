import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currency_converter/api/exchange_api.dart';
import 'package:currency_converter/models/exchange_rate.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '원화 환율 계산기',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      ),
      home: const CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  // 기준 환율 (원화 대비 각 통화)
  final Map<String, double> exchangeRatesKRW = {
    'USD': 1350.50,
    'GBP': 1705.20,
    'JPY': 9.55,
    'EUR': 1450.80,
  };

   final Map<String, String> currencyImages = {
    'USD': 'assets/images/USD.svg',
    'GBP': 'assets/images/GBP.svg',
    'JPY': 'assets/images/JPY.svg',
    'EUR': 'assets/images/EUR.svg',
    'KRW': 'assets/images/KOR.svg',
  };

  List<ExchangeRate> exchangeRates = []; // 환율 정보 리스트
  String authKey = '6i3mz7fIOVoQ3BnSiKQ7xbxyc0f9oerL'; // 실제 API 인증키로 변경

  // 환전 내역 목록
  final List<Map<String, dynamic>> conversionHistory = [];

  // 통화 심볼 매핑
  final Map<String, String> currencySymbols = {
    'USD': '\$',
    'GBP': '£',
    'JPY': '¥',
    'EUR': '€',
  };

  // 입력 금액
  double amount = 0;
  // 현재 선택된 통화
  String fromCurrency = 'USD';
  final String toCurrency = 'KRW'; // 대상 통화는 항상 원화
  // 계산된 결과
  double result = 0;
  String amountString = '0';
  bool isDecimalInput = false; // 소수점 입력 여부

  @override
  void initState() {
    super.initState();
    fetchData(); // 앱 시작 시 데이터 가져오기
  }

  Future<void> fetchData() async {
  try {
    final rates = await fetchExchangeRates(authKey);
    setState(() {
      exchangeRates = rates;
      // 초기 환율 설정 (예: USD) - 수정 필요
      if (exchangeRates.isNotEmpty) {
        _calculateResult(); // 초기 결과 계산
      }
    });
  } catch (e) {
    print('Error: $e');
    // 에러 처리 (예: 사용자에게 알림 표시)
  }
}

@override
void _onCurrencySelected(String currency) {
  setState(() {
    fromCurrency = currency;
    // 선택된 통화의 환율을 exchangeRates에서 찾아 갱신
    final selectedRate = exchangeRates.firstWhere(
        (rate) => rate.curUnit == currency,
        orElse: () => ExchangeRate(
            curUnit: currency, ttb: 0.0, tts: 0.0, dealBasR: 0.0));
    // exchangeRatesKRW[currency] = selectedRate.dealBasR;
    _calculateResult();
  });
}
  


  // 숫자 키패드 버튼 클릭 시 호출되는 함수
  void _onNumberPressed(String number) {
    setState(() {
    if (number == '.') {
      if (!amountString.contains('.')) {
        if (amountString == '0') {
          amountString += '.';
        } else {
          amountString += '.';
        }
        isDecimalInput = true;
      }
    } else {
      if (amountString == '0' && number == '0' && !isDecimalInput) {
        // 0만 입력 방지 (소수점 앞)
        return;
      } else if (amountString == '0' && number != '0' && !isDecimalInput) {
        // 0이 아닌 숫자로 시작
        amountString = number;
      } else {
        amountString += number;
      }
    }
    amount = double.parse(amountString);
    _calculateResult();
  });
}

  // 환율 계산 함수 (원화로)
  void _calculateResult() {
  if (exchangeRates.isNotEmpty) {
    final selectedRate = exchangeRates.firstWhere(
        (rate) => rate.curUnit == fromCurrency,
        orElse: () => ExchangeRate(
            curUnit: fromCurrency, ttb: 0.0, tts: 0.0, dealBasR: 0.0));
    result = amount * selectedRate.dealBasR;
    if (fromCurrency == 'JPY') {
      result /= 100;
    }
  } else {
    result = 0;
  }
}

  // 삭제 버튼 클릭 시 호출되는 함수
  void _onDeletePressed() {
    setState(() {
    if (amountString.length <= 1) {
      amountString = '0';
      isDecimalInput = false;
    } else {
      if (amountString.endsWith('.')) {
        isDecimalInput = false;
      }
      amountString = amountString.substring(0, amountString.length - 1);
    }
    amount = double.parse(amountString);
    result = 0;
  });
}

  // 환전 내역 추가 함수
  void _addConversionToHistory() {
    setState(() {
      conversionHistory.insert(0, {
        'from': fromCurrency,
        'amount': amount,
        'to': toCurrency,
        'result': result,
        'timestamp': DateTime.now().toString().substring(0, 16),
      });
      amount = 0;
      result = 0;
    });
  }

  String _formatAmount(double amount) {
  if (isDecimalInput || amount % 1 != 0) {
    return amount.toStringAsFixed(2);
  } else {
    return amount.toInt().toString();
  }
}

  Widget _buildCurrencySelectAndInputField() {
    return Container(
      color: const Color(0xFF333333),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  amountString == '0'
                   ? '${currencySymbols[fromCurrency]} 0 → ₩ ${NumberFormat('#,###.##').format(result)} 원'
                   : '${currencySymbols[fromCurrency]} ${amountString} → ₩ ${NumberFormat('#,###.##').format(result)} 원',
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: _addConversionToHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 60),
                  alignment: Alignment.center,
                ),
                child: const Text('+', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: exchangeRatesKRW.keys.map((currency) {
              return _buildSingleCurrencyButton(currency, currencySymbols[currency]!);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCurrencyButton(String currencyCode, String symbol) {
    return TextButton(
      onPressed: () => _onCurrencySelected(currencyCode),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        alignment: Alignment.center,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(symbol, style: const TextStyle(fontSize: 20, color: Colors.white)),
          Text(currencyCode, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String text) {
    return SizedBox(
      width: 80,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _onNumberPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333333),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(fontSize: 24.0),
          padding: EdgeInsets.zero,
        ),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 80,
      height: 60,
      child: ElevatedButton(
        onPressed: _onDeletePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF333333),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Center(child: Icon(Icons.backspace_outlined, size: 24.0)),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('직구 환율 계산기'),
      centerTitle: true,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: conversionHistory.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1),
            itemBuilder: (context, index) {
              final historyItem = conversionHistory[index];
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: currencyImages.containsKey(historyItem['from'])
                            ? SvgPicture.asset(
                                currencyImages[historyItem['from']]!,
                                width: 30, // 고정된 너비
                                height: 20, // 고정된 높이
                                fit: BoxFit.fill,
                              )
                            : SizedBox(width: 30, height: 20), // 이미지가 없는 경우 빈 공간
                      ),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${currencySymbols[historyItem['from']]} ${historyItem['amount'].toStringAsFixed(2)} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: '→ '),
                              TextSpan(text: '₩ ${NumberFormat('#,###').format(historyItem['result'].toInt())}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            conversionHistory.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.grey, height: 1),
        ),
        _buildCurrencySelectAndInputField(),
        Container( // 숫자 패드
          color: const Color(0xFF333333),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min, // 크기를 내용에 맞게 조정
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNumberButton('7'),
                  _buildNumberButton('8'),
                  _buildNumberButton('9'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNumberButton('4'),
                  _buildNumberButton('5'),
                  _buildNumberButton('6'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNumberButton('1'),
                  _buildNumberButton('2'),
                  _buildNumberButton('3'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNumberButton('0'),
                  _buildNumberButton('.'),
                  _buildDeleteButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}