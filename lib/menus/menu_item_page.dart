// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:montelibero/oracles/price_oracle.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bitcoinPriceProvider = Provider.of<BitcoinPriceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'menu item',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '\$${bitcoinPriceProvider.selectedPrice} ' +
                    bitcoinPriceProvider.currentCurrency!.code,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PriceCurrency(
                    value: bitcoinPriceProvider.priceCOP!,
                    currency: 'COP',
                  ),
                  _PriceCurrency(
                    value: bitcoinPriceProvider.priceEUR!,
                    currency: 'EUR',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCurrency extends StatelessWidget {
  const _PriceCurrency({
    required this.value,
    required this.currency,
  });

  final String value;
  final String currency;

  final textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '\$$value',
          style: textStyle,
        ),
        const SizedBox(height: 5),
        Text(
          currency,
          style: textStyle.copyWith(fontSize: 15),
        )
      ],
    );
  }
}
