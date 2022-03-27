// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:montelibero/models/price_list_bitcoin.dart';
import 'package:montelibero/oracles/price_oracle.dart';
// Liquid RPC
import 'package:montelibero/models/chain_info.dart';
import 'package:montelibero/models/wallet_info.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';

import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class MenuListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bitcoinPriceProvider = Provider.of<BitcoinPriceProvider>(context);
    final liquidOracle = Provider.of<LiquidOracle>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MTL Wallet',
          style: TextStyle(fontSize: 25),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _NetworkStatus(
                bitcoinPriceProvider: bitcoinPriceProvider,
                liquidOracle: liquidOracle),
            _ListWalletActions(
                liquidOracle: liquidOracle) //<< any widgets added
          ],
        ),
      ),
    );
  }
}

class _NetworkStatus extends StatelessWidget {
  _NetworkStatus({
    Key? key,
    required this.bitcoinPriceProvider,
    required this.liquidOracle,
  }) : super(key: key);

  final BitcoinPriceProvider bitcoinPriceProvider;
  final LiquidOracle liquidOracle;

  @override
  Widget build(BuildContext context) {
    ChainInfo? network;
    if (liquidOracle.lastChainInfo != null) {
      network = liquidOracle.lastChainInfo;
    }
    WalletInfo? wallet;
    if (liquidOracle.lastWalletInfo != null) {
      wallet = liquidOracle.lastWalletInfo;
    }
    final size = MediaQuery.of(context).size;
    return bitcoinPriceProvider.currentCurrency != null
        ? GestureDetector(
            onTap: () async {
              bitcoinPriceProvider.selectedPrice = bitcoinPriceProvider
                  .currentCurrency!.rateFloat
                  .ceil()
                  .toString();
              await bitcoinPriceProvider.convertcurrency();
              Navigator.pushNamed(context, 'details');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              // height: size.height * 0.2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'price \$${bitcoinPriceProvider.currentCurrency!.rate} ' +
                          bitcoinPriceProvider.currentCurrency!.code,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Text(
                    'height ${network!.height}\n balance: ${wallet!.assets["bitcoin"]} btc',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            height: size.height * 0.2,
          );
  }
}

class _ListWalletActions extends StatelessWidget {
  _ListWalletActions({
    Key? key,
    required this.liquidOracle,
  }) : super(key: key);

  final LiquidOracle liquidOracle;

  final menuPics = {
    'assets': 'assets/assets.svg',
    'signing': 'assets/signing.svg',
    'construct': 'assets/construct.svg',
    'settings': 'assets/settings.svg'
  };

  final menuHints = {
    'assets': 'show wallet tokens',
    'signing': 'sign raw transaction input',
    'construct': 'start multisig transaction',
    'settings': 'setup node'
  };


  @override
  Widget build(BuildContext context) {
    return liquidOracle.lastChainInfo != null
        ? ListView.builder(
            shrinkWrap: true, // use it
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: menuPics.keys.length,
            itemBuilder: (_, int index) {
              String key = menuPics.keys.elementAt(index);
              return _CardAction(name: key, hint: menuHints[key]!, icon: menuPics[key]!);
            })
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

class _CardAction extends StatelessWidget {
  _CardAction({
    required this.name,
    required this.hint,
    required this.icon,
  });

  final String name;
  final String hint;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        Navigator.pushNamed(context, name);
      },
      leading: SvgPicture.asset(icon, semanticsLabel: name),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        hint,
        style: const TextStyle(color: Colors.grey, fontSize: 15),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
