// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:provider/provider.dart';
import 'package:montelibero/models/chain_info.dart';
import 'package:global_configuration/global_configuration.dart';

// Create a Form widget.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() {
    return SettingsScreenState();
  }
}


class SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final hostInput = TextEditingController();
  final portInput = TextEditingController();
  final userInput = TextEditingController();
  final passwordInput = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    hostInput.dispose();
    portInput.dispose();
    userInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }

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
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: GlobalConfiguration().get("host") ?? "http://host:port",
                  labelText: "host",
                ),
                controller: hostInput,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, enter correct URI';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: (GlobalConfiguration().get("port") ?? 18333).toString(),
                  labelText: "port",
                ),
                controller: portInput,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, check host and enter correct port';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: GlobalConfiguration().get("user") ?? "user",
                  labelText: "api credentials",
                ),
                controller: userInput,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, enter correct user';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: GlobalConfiguration().get("password") ?? "password",
                  labelText: "api credentials",
                ),
                controller: passwordInput,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, check user and enter correct password';
                  }
                  return null;
                },
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
