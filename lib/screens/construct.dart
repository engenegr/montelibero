// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:montelibero/oracles/price_oracle.dart';
import 'package:provider/provider.dart';

import '../models/wallet_info.dart';
import '../oracles/sidechain_oracle.dart';

// Create a Form widget.
class ConstructScreen extends StatefulWidget {
  const ConstructScreen({Key? key}) : super(key: key);

  @override
  ConstructScreenState createState() {
    return ConstructScreenState();
  }
}

class ConstructScreenState extends State<ConstructScreen> {
  final _formKey = GlobalKey<FormState>();

  final addressInput = TextEditingController();
  final amountInput = TextEditingController();
  final assetInput = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    addressInput.dispose();
    amountInput.dispose();
    assetInput.dispose();
    super.dispose();
  }

  String txInfo = "";

  @override
  Widget build(context) {
    final liquidOracle = Provider.of<LiquidOracle>(context);
    WalletInfo? wallet;
    if (liquidOracle.lastWalletInfo != null) {
      wallet = liquidOracle.lastWalletInfo;
    }
    assetInput.text = wallet != null ? wallet.assets.keys.elementAt(0): "btc";
    int currentIndex = -1;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'construct',
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
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter address',
                      ),
                      controller: addressInput,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Can not be empty';
                        } else {
                          // Here put address validation logic
                        }
                        return null;
                      },
                    ),
                    const Divider(
                      height: 30,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.transparent,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter amount',
                      ),
                      controller: amountInput,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Can not be empty';
                        } else {
                          try {
                            double.parse(value);
                          } catch(err) {
                            return err.toString();
                          }
                        }
                        return null;
                      },
                    ),
                    const Divider(
                      height: 30,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.transparent,
                    ),
                    DropdownButton<String>(
                      value: assetInput.text,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          assetInput.text = newValue!;
                        });
                      },
                      items: wallet!.assets.keys.map<DropdownMenuItem<String>>((String value)
                      {
                          return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              txInfo = '';
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Check your transaction')),
                                );
                              }
                              liquidOracle.createRawTx(addressInput.text, amountInput.text).then((value) {
                                setState(() {
                                  txInfo = 'Received transaction\n' + value;
                                });
                              }).catchError((_){
                                setState(() {
                                  txInfo = 'An error occurred while requesting raw tx';
                                });
                              });
                            },
                            child: const Text("Prepare"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                            },
                            child: const Text("Sign&Broadcast"),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: txInfo)).then((_){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Data has been copied into clipboard"))
                          );
                        });
                      },
                      child: Text(
                        txInfo,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
