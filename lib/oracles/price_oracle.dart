import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:montelibero/models/currency.dart';
import 'package:montelibero/models/price_list_bitcoin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BitcoinPriceProvider extends ChangeNotifier {
  final String _baseUrl = 'api.coindesk.com';
  final String _currenPrice = '/v1/bpi/currentprice.json';
  final String _priceList = '/v1/bpi/historical/close.json';
  // final String _priceCop = '/v1/bpi/currentprice/COP.json';
  // final String _priceEur = '/v1/bpi/currentprice/EUR.json';
  final String _endpointConvert = 'free.currencyconverterapi.com';
  final String _apiKey = '0ade467a2d5d275185eb';
  List<PriceListBitcoinDates> prices = [];
  Currency? currentCurrency;
  String? selectedPrice;
  String? priceCOP;
  String? priceEUR;

  BitcoinPriceProvider() {
    getListPriceBitcoin();
    getCurrentPricebtn();
    Timer.periodic(const Duration(seconds: 60), (t) {
      getCurrentPricebtn();
    });
  }

  Future<String> _getJsonData(String endpoint) async {
    final url = Uri.https(_baseUrl, endpoint);

    final response = await http.get(url);
    return response.body;
  }

  getListPriceBitcoin() async {
    var formatter = DateFormat('yyyy-MM-dd');
    var dateNow = DateTime.now();
    var lastDate = DateTime(dateNow.year, dateNow.month, dateNow.day - 14);

    var url = Uri.https(_baseUrl, _priceList, {
      'start': formatter.format(lastDate),
      'end': formatter.format(dateNow)
    });
    var response = await http.get(url);

    final decodeData = json.decode(response.body);

    await decodeData['bpi'].forEach((k, v) {
      prices.add(PriceListBitcoinDates(date: k, price: v.toDouble()));
    });
    prices = prices.reversed.toList();
    notifyListeners();
    // return decodeData['bpi'];
  }

  getCurrentPricebtn() async {
    var response = await _getJsonData(_currenPrice);

    final decodeData = json.decode(response);

    currentCurrency = Currency.fromJson(decodeData['bpi']['USD']);
    notifyListeners();
  }

  convertcurrency() async {
    final url = Uri.https(_endpointConvert, '/api/v5/convert',
        {"q": "USD_EUR,USD_COP", "compact": "ultra", "apiKey": _apiKey});

    final response = await http.get(url);

    final decodeData = json.decode(response.body);

    final convertCop =
        (decodeData['USD_COP'].toDouble() * double.parse(selectedPrice!))
            .ceil();
    priceCOP = convertCop.toString();

    final convertEur =
        (decodeData['USD_EUR'].toDouble() * double.parse(selectedPrice!))
            .ceil();
    priceEUR = convertEur.toString();
  }
}
