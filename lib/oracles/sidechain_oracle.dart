import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:montelibero/models/chain_info.dart';
import 'package:montelibero/models/decoded_tx.dart';
import 'package:montelibero/models/wallet_info.dart';
import 'package:montelibero/models/currency.dart';
import 'package:montelibero/models/price_list_bitcoin.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:jsonrpc_client/jsonrpc_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/tx.dart';

class LiquidOracle extends ChangeNotifier {

  var rpc = Client.withWallet(
      GlobalConfiguration().get("host"),
      GlobalConfiguration().get("port"),
      '1.0',
      GlobalConfiguration().get("user"),
      GlobalConfiguration().get("password"),
      GlobalConfiguration().get("wallet")
  );

  var host = GlobalConfiguration().get("host");
  var port = GlobalConfiguration().get("port");
  var user = GlobalConfiguration().get("user");
  var pass = GlobalConfiguration().get("password");
  var wallet = GlobalConfiguration().get("wallet");

  ChainInfo? lastChainInfo;
  WalletInfo? lastWalletInfo;
  AddressInfo? lastAddressInfo;
  String infoString = "";
  String? lastAddress;

  LiquidOracle() {
    getChainData();
    getWalletInfo();
    Timer.periodic(const Duration(seconds: 1), (t) {
      getChainData();
      getWalletInfo();
    });
  }

  reset() {
    bool result=false;
    if (host != GlobalConfiguration().get("host") ||
        port != GlobalConfiguration().get("port") ||
        user != GlobalConfiguration().get("user") ||
        pass != GlobalConfiguration().get("password") ||
        wallet != GlobalConfiguration().get("wallet")
    ) {
      print("resetting Elements Core settings");
      final newRPC = Client.withWallet(
          GlobalConfiguration().get("host"),
          GlobalConfiguration().get("port"),
          '1.0',
          GlobalConfiguration().get("user"),
          GlobalConfiguration().get("password"),
          GlobalConfiguration().get("wallet"),
      );
      var response = newRPC.call("getblockchaininfo").then((_){
        host = GlobalConfiguration().get("host");
        port = GlobalConfiguration().get("port");
        wallet = GlobalConfiguration().get("wallet");
        user = GlobalConfiguration().get("user");
        pass = GlobalConfiguration().get("password");
        rpc = Client.withWallet(host, port, '1.0', user, pass, wallet);
        print("updated Elements Core settings");
        print("$host wallet $wallet $port $user $pass");
        result = true;
      }).catchError((_){
        print("invalid API credentials");
        GlobalConfiguration().updateValue("host", host);
        GlobalConfiguration().updateValue("port", port);
        GlobalConfiguration().updateValue("user", user);
        GlobalConfiguration().updateValue("password", pass);
        GlobalConfiguration().updateValue("wallet", wallet);
      });
    }
    return result;
  }

  getChainData() async {
    try {
      var response = await rpc.call("getblockchaininfo");
      lastChainInfo = ChainInfo.fromJson(response.result);
    } catch(err) {
      print("Can't connect to Elements Core: " + err.toString());
      lastChainInfo = ChainInfo(
          date: DateTime.now().toString(),
          height: -1);
    }
    //infoString = response.result;
    //print(infoString);
    notifyListeners();
  }

  getWalletInfo() async {
    try {
      print('Awaiting wallet info...');
      var response = await rpc.call("getwalletinfo");
      lastWalletInfo = WalletInfo.fromJson(response.result);
      print("wallet info: ${lastWalletInfo!.assets}");
      notifyListeners();
    } catch (err) {
      print(err);
      lastWalletInfo = WalletInfo(
          error: "no wallet",
          date: DateTime.now().toString(),
          name: "Not Found",
          txCount: 0,
          assets: {});
    }
  }

  Future<String> getNewAddress(String type) async {
    if (lastAddress != null) {
      return Future.value(lastAddress);
    }
    var response = null;
    try {
      response = await rpc.call("getaddressesbylabel", params: ["multisig"]);
    } catch (err) {
      print("Error requesting getaddressesbylabel " + err.toString());
    }
    try {
      if (response == null) {
        var response =
            await rpc.call("getnewaddress", params: ["multisig", type]);
        //{"result":"tlq1qqfat5d...","error":null,"id":"curltest"}
        lastAddress = response.result.toString();
        return Future.value(lastAddress);
      } else {
        lastAddress = response.result.keys.first;
        return Future.value(lastAddress);
      }
    } catch (err) {
      print("Error requesting getaddressesbylabel " + err.toString());
      return Future.value("");
    }
  }

  Future<String> getAddressInfo(String address) async {
    if (lastAddressInfo != null) {
      return Future.value(lastAddressInfo!.confidentialKey);
    }
    var response = null;
    try {
      response = await rpc.call("getaddressinfo", params: [address]);
      lastAddressInfo = AddressInfo.fromJson(response.result);
      return Future.value(lastAddressInfo!.confidentialKey);
    } catch (err) {
      print("Error requesting getaddressesbylabel " + err.toString());
      return Future.value("error");
    }
  }

  Future<String> getRawTx(String txId) async {
    var response = null;
    try {
      response =
      await rpc.call("gettransaction", params: [txId]);
      final tx = RawTx.fromJson(response.result);
      return Future.value(tx.hex);
    } catch (err) {
      print("Error requesting gettransaction " + err.toString());
      return Future.value(err.toString());
    }
  }

  Future<String> unblindRawTx(String blindedHex) async {
    var response = null;
    try {
      response =
      await rpc.call("unblindrawtransaction", params: [blindedHex]);
      final unblindedTx = UnblindedTx.fromJson(response.result);
      return Future.value(unblindedTx.hex);
    } catch (err) {
      print("Error requesting gettransaction " + err.toString());
      return Future.value(err.toString());
    }
  }


  Future<String> getDecodedTx(String tx) async {
    var response = null;
    try {
      response =
      await rpc.call("decoderawtransaction", params: [tx]);
      final txInfo = DecodedTx.fromJson(response.result);
      return Future.value(txInfo.stringInfo);
    } catch (err) {
      print("Error requesting decoderawtransaction " + err.toString());
      return Future.value(err.toString());
    }
  }

  Future<String> getSignedTx(String tx, String key) async {
    var response = null;
    try {
      if(key.isEmpty) {
        response = await rpc.call("signrawtransactionwithwallet", params: [tx]);
        final signedTx = response.result as Map<String, dynamic>;
        return Future.value(signedTx["hex"]);
      } else {
        response = await rpc.call("signrawtransactionwithkey",
            params: [tx, [key]]);
        final signedTx = response.result as Map<String, dynamic>;
        return Future.value(signedTx["hex"]);
      }
    } catch (err) {
      print("Error while requesting signing " + err.toString());
      return Future.value(err.toString());
    }
  }

  Future<String> createRawTx(String dest, String amount) async {
    var response = null;
    try {
      response =
      await rpc.call("createrawtransaction", params: [[],[{dest: amount}]]);
      return Future.value(response.result.toString());
    } catch (err) {
      print("Error requesting createrawtransaction " + err.toString());
      return Future.value(err.toString());
    }
  }

  Future<String> importAddress(String address) async {
    var response = null;
    try {
      response =
      await rpc.call("importaddress", params: [address]);
      return Future.value(response.result.toString());
    } catch (err) {
      print("Error requesting importaddress " + err.toString());
      return Future.value(err.toString());
    }
  }

  Future<String> importBlindingKey(String address, String blindingKey) async {
    var response = null;
    try {
      response =
      await rpc.call("importblindingkey", params: [address, blindingKey]);
      return Future.value(response.result.toString());
    } catch (err) {
      print("Error requesting importblindingkey " + err.toString());
      return Future.value(err.toString());
    }
  }
}
