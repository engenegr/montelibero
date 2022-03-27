// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:montelibero/menus/menu_list_page.dart';
import 'package:montelibero/menus/menu_item_page.dart';
import 'package:montelibero/screens/assets.dart';
import 'package:montelibero/screens/construct.dart';
import 'package:montelibero/screens/signing.dart';
import 'package:montelibero/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Liquid RPC
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:montelibero/oracles/price_oracle.dart';
import 'package:global_configuration/global_configuration.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Map<String, dynamic> appSettings = {
  "uri": "http://127.0.0.1",
  "port": 18891,
  "user": "user",
  "password": "password"
};

void main() async {
  final localDirectory = await getApplicationDocumentsDirectory();
  const configPath = 'config.json';
  final file = File(configPath);

  if (!await file.exists()) {
    final initialContent = jsonEncode(appSettings);
    await file.create();
    await file.writeAsString(initialContent);
    print("config file dumped ${configPath}");
  } else {
    appSettings = jsonDecode(file.readAsStringSync());
    print("config file read ${configPath}");
  }

  GlobalConfiguration().loadFromMap(appSettings);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BitcoinPriceProvider()),
        ChangeNotifierProvider(create: (_) => LiquidOracle())
      ],
      child: MaterialApp(
        title: 'MTL Liquid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
            colorScheme:
                ThemeData().colorScheme.copyWith(primary: Colors.amber[800])),
        initialRoute: 'home',
        routes: {
          "home": (_) => MenuListPage(),
          "details": (_) => DetailPage(),
          "assets": (context) => AssetsScreen(),
          "signing": (context) => SigningScreen(),
          "construct": (context) => ConstructScreen(),
          "settings": (context) => SettingsScreen(),
        },
      ),
    );
  }
}
