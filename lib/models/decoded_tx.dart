import 'package:json_annotation/json_annotation.dart';

class DecodedTx {
  /*
  {
    txid: 726827 bf16e8a392cf344bfcc206e9ca3c335f2a00d3868ee258e42198352520,
    hash: 726827 bf16e8a392cf344bfcc206e9ca3c335f2a00d3868ee258e42198352520,
    wtxid: 726827 bf16e8a392cf344bfcc206e9ca3c335f2a00d3868ee258e42198352520,
    withash: 7714 b57149a7fe65e55cb528b1c091f3fa8cd52d0eed028e926ab270dd75801b,
    version: 2,
    size: 150,
    vsize: 150,
    weight: 600,
    locktime: 0,
    vin: [{
      txid: 7584e0 ae2c088a98d20d205897ecde812a0218c5f95f3ad287785227f24d3315,
      vout: 0,
      scriptSig: {
        asm: ,
        hex:
      },
      is_pegin: false,
      sequence: 4294967295
    }],
    vout: [{
      value: 0.0002,
      asset: 144 c654344aa716d6f3abcc1ca90e5641e4e2a7f633bc09fe3baf64585819a49,
      commitmentnonce: 02 aa2071e303b0f9baec3ebd9f1391bf6fd577a1a9df0fb7fbfbbe66368c728006,
      commitmentnonce_fully_valid: true,
      n: 0,
      scriptPubKey: {
        asm: 0 078e4 d2c27c1dbd2d1d4f90178d4881e2c4e9928,
        hex: 0014078e4 d2c27c1dbd2d1d4f90178d4881e2c4e9928,
        reqSigs: 1,
        type: witness_v0_keyhash,
        addresses: [tex1qq78y6tp8c8da95w5lyqh34ygrckyaxfg479lj6]
      }
    }]
  }
  */

  DecodedTx(
      {error,
        required this.vout
      });

  String error = "";
  List<dynamic> vout = [];

  get stringInfo {
    String dateSlug =
        "Transaction decoded\n"
        "Amount: ${vout[0]['value']}\n"
        "Asset: ${vout[0]['asset']}";
    return dateSlug;
  }

  factory DecodedTx.fromJson(Map<String, dynamic> json) => DecodedTx(
    vout: json['vout'] == null ? null : json["vout"],
  );

  Map<String, dynamic> toJson() => {"vout": vout};
}
