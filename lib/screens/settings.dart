// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:provider/provider.dart';
import 'package:montelibero/models/chain_info.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final liquidOracle = Provider.of<LiquidOracle>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'settings',
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
                (liquidOracle.lastChainInfo != null) ? 'last block: ${liquidOracle.lastChainInfo!.height} updated ${liquidOracle.lastChainInfo!.date}' : "No connection",
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
                  _CardParameter(
                    name: "node uri",
                    value: "http://some",
                  ),
                  _CardParameter(
                    name: "user",
                    value: "user",
                  ),
                  _CardParameter(
                    name: "password",
                    value: "password",
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

class _CardParameter extends StatelessWidget {
  const _CardParameter({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  final textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: textStyle,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: textStyle.copyWith(fontWeight: FontWeight.normal),
        )
      ],
    );
  }
}
