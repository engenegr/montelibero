// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:path_provider/path_provider.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();

    hostInput.text = GlobalConfiguration().get("host"); // ?? "http://host:port";
    portInput.text = GlobalConfiguration().get("port").toString(); // ?? "password";
    userInput.text = GlobalConfiguration().get("user"); // ?? "user";
    passwordInput.text = GlobalConfiguration().get("password"); // ?? "password";
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
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                (liquidOracle.lastChainInfo!.height > 0) ? 'last block: ${liquidOracle.lastChainInfo!.height} updated ${liquidOracle.lastChainInfo!.date}' : "no connection",
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
                    return 'can not be empty';
                  } else {
                    final uri = Uri.tryParse(value);
                    final isValid = uri != null &&
                        uri.scheme.startsWith('http');
                    if(isValid){
                      return null;
                    }
                    return "please, enter correct uri $value";
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
                    return 'can not be empty';
                  } else {
                    try {
                      final port = int.parse(value);
                      return null;
                    } catch(_) {
                      return "please, enter numeric value";
                    }
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
                    return 'can not be empty';
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
                    return 'can not be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      GlobalConfiguration().updateValue("host", hostInput.text);
                      GlobalConfiguration().updateValue("port", int.parse(portInput.text));
                      GlobalConfiguration().updateValue("user", userInput.text);
                      GlobalConfiguration().updateValue("password", passwordInput.text);
                      final result = liquidOracle.reset();
                      //print("RPC client reset: " + result.toString());
                    });
                  }
                },
                child: const Text("Check"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final localDirectory = getApplicationDocumentsDirectory();
                  const configPath = 'config.json';
                  final file = File(configPath);

                  final settings = jsonEncode(GlobalConfiguration().appConfig);
                  file.writeAsString(settings);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('saved configuration file')),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          ),
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
