class ExchangeRate {
  final String curUnit; // 통화 단위
  final double ttb;     // 전신환 매입률
  final double tts;     // 전신환 판매율
  final double dealBasR; // 매매 기준율

  ExchangeRate({
    required this.curUnit,
    required this.ttb,
    required this.tts,
    required this.dealBasR,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      curUnit: json['cur_unit'] ?? '',
      ttb: double.tryParse(json['ttb']?.toString() ?? '0.0') ?? 0.0,
      tts: double.tryParse(json['tts']?.toString() ?? '0.0') ?? 0.0,
      dealBasR: double.tryParse(json['deal_bas_r']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}