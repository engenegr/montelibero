// To parse this JSON data, do
//
//     final currency = currencyFromJson(jsonString);

import 'dart:convert';

Currency currencyFromJson(String str) => Currency.fromJson(json.decode(str));

String currencyToJson(Currency data) => json.encode(data.toJson());

class Currency {
  Currency({
    required this.code,
    this.symbol,
    required this.rate,
    required this.description,
    required this.rateFloat,
  });

  String code;
  String? symbol;
  String rate;
  String description;
  double rateFloat;

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json["code"],
        symbol: json["symbol"] ?? '',
        rate: json["rate"],
        description: json["description"],
        rateFloat: json["rate_float"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "symbol": symbol,
        "rate": rate,
        "description": description,
        "rate_float": rateFloat,
      };
}
