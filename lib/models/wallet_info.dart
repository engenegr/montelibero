import 'package:json_annotation/json_annotation.dart';

class WalletInfo {
  /*
  {
    "walletname": "mtl",
    "walletversion": 169900,
    "format": "bdb",
    "balance": {
      "bitcoin": 0.00000000
    },
    "unconfirmed_balance": {
      "bitcoin": 0.00000000
    },
    "immature_balance": {
      "bitcoin": 0.00000000
    },
    "txcount": 0,
    "keypoololdest": 1647628433,
    "keypoolsize": 1000,
    "hdseedid": "2ba3ebf89a25b67f0b9fa6f20bc872bbdb169f99",
    "keypoolsize_hd_internal": 1000,
    "paytxfee": 0.00000000,
    "private_keys_enabled": true,
    "avoid_reuse": false,
    "scanning": false,
    "descriptors": false
  }
  */

  WalletInfo(
      {error,
        required this.assets,
        required this.txCount,
        required this.date,
        required this.name});

  String error = "";
  //List<Asset> assets = List.empty();
  Map<String, dynamic> assets = {};
  int txCount = 0;
  String name;
  String date;

  get formatDate {
    var today = DateTime.parse(date);
    String dateSlug =
        "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return dateSlug;
  }

  factory WalletInfo.fromJson(Map<String, dynamic> json) => WalletInfo(
    date: DateTime.now().toString(),
    name: json['walletname'] == null ? null : json["walletname"],
    txCount: json['txcount'] == null ? null : json["txcount"],
    assets: json['balance'] == null ? null : json["balance"],
  );

  Map<String, dynamic> toJson() => {"date": date};

  getCurrentBTCBalance() async {
    return assets["bitcoin"];
  }
}
