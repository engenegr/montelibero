// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:montelibero/oracles/price_oracle.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:provider/provider.dart';
import 'package:montelibero/models/wallet_info.dart';


class AssetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bitcoinPriceProvider = Provider.of<BitcoinPriceProvider>(context);
    final liquidOracle = Provider.of<LiquidOracle>(context);

    Map<String, dynamic>? assets;
    int? txCount;
    if (liquidOracle.lastWalletInfo != null) {
      assets = liquidOracle.lastWalletInfo!.assets;
      txCount = liquidOracle.lastWalletInfo!.txCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'assets',
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
                //"Tapped some action",
                '${txCount} transactions / \$${bitcoinPriceProvider.currentCurrency!.rate} ' +
                    bitcoinPriceProvider.currentCurrency!.code,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListView.builder(
                  shrinkWrap: true, // use it
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: assets!.keys.length,
                  itemBuilder: (_, int index) {
                    String key = assets!.keys.elementAt(index);
                    return _CardAsset(name: key, balance: assets[key]!);
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class _CardAsset extends StatelessWidget {
  _CardAsset({
    required this.name,
    required this.balance,
  });

  final String name;
  final double balance;
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Navigator.pushNamed(context, name);
      },
      //leading: SvgPicture.asset(icon, semanticsLabel: name),
      title: Text(
        "${name} :: ${balance}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}",
        style: const TextStyle(color: Colors.grey, fontSize: 15),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
