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
    name: json['walletname'] == null ? "none" : json["walletname"],
    txCount: json['txcount'] == null ? 0 : json["txcount"],
    assets: json['balance'] == null ? {"bitcoin": 0} : json["balance"],
  );

  Map<String, dynamic> toJson() => {"date": date};

  getCurrentBTCBalance() async {
    return assets["bitcoin"];
  }
}

class AddressInfo {
  /*
    {
    "address": "vtSE19Kp6wwJvkogxfrNuKwLB7Rt3kkSQs3svrpnu7Vkumkt9DsmhPHZPJfEV4HX5XonCaR2WfVZJ8dF",
    "scriptPubKey": "76a9140d1d9cd5d2f267dd61fbc44cddf4e092f1e79ad388ac",
    "ismine": true,
    "solvable": true,
    "desc": "pkh([df210b65/0'/0'/108']02a7c4a0a6d1ced0cbd1ee165a0ddec1188684f2cb3b2ac9e2cc450b1e642e1db7)#t6g43g7f",
    "iswatchonly": false,
    "isscript": false,
    "iswitness": false,
    "pubkey": "02a7c4a0a6d1ced0cbd1ee165a0ddec1188684f2cb3b2ac9e2cc450b1e642e1db7",
    "iscompressed": true,
    "confidential": "vtSE19Kp6wwJvkogxfrNuKwLB7Rt3kkSQs3svrpnu7Vkumkt9DsmhPHZPJfEV4HX5XonCaR2WfVZJ8dF",
    "confidential_key": "031500c2121d515615bafd0c09238c5b464fabc9cfff2be9baf43bc39d7e0b410e",
    "unconfidential": "FWN4hveyLtWPT84f1xBAmpYcTh4mKZsz3J",
    "ischange": false,
    "timestamp": 1647628432,
    "hdkeypath": "m/0'/0'/108'",
    "hdseedid": "2ba3ebf89a25b67f0b9fa6f20bc872bbdb169f99",
    "hdmasterfingerprint": "df210b65",
    "labels": [
      "multisig"
    ]
  }
  */
  AddressInfo(
      {error,
        required this.confidentialKey
      });

  String error = "";
  String confidentialKey = "";

  get stringInfo {
    String dateSlug =
        "Address Info\n"
            "confidentialKey: " + confidentialKey;
    return dateSlug;
  }

  factory AddressInfo.fromJson(Map<String, dynamic> json) => AddressInfo(
    confidentialKey: json["confidential_key"] == null ? null : json["confidential_key"],
  );

  Map<String, dynamic> toJson() => {"confidential_key": confidentialKey};
}