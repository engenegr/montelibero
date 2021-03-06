// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:montelibero/oracles/sidechain_oracle.dart';
import 'package:montelibero/oracles/price_oracle.dart';


// Create a Form widget.
class SigningScreen extends StatefulWidget {
  const SigningScreen({Key? key}) : super(key: key);

  @override
  SigningScreenState createState() {
    return SigningScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SigningScreenState extends State<SigningScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final txController = TextEditingController();
  final keyController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txController.dispose();
    keyController.dispose();
    super.dispose();
  }

  String txInfo = "";

  @override
  Widget build(context) {
    final liquidOracle = Provider.of<LiquidOracle>(context);
    return FutureBuilder<String>(
        future: liquidOracle.getNewAddress("legacy"),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
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
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: '${snapshot.data}')).then((_){
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Address copied to clipboard"))
                            );
                          });
                        },
                        child: Text(
                          '${snapshot.data}',
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter raw transaction / blinded tx id here',
                              ),
                              controller: txController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please, enter transaction';
                                }
                                return null;
                              },
                            ),
                            const Divider(
                              height: 30,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.black,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Enter signing key here (Optional)',
                              ),
                              controller: keyController,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        txInfo = '';
                                        setState(() {
                                          txInfo = txInfo;
                                        });
                                        if (_formKey.currentState!.validate()) {
                                          // If the form is valid, display a snackbar. In the real world,
                                          // you'd often call a server or save the information in a database.
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Requesting info...')),
                                          );
                                          liquidOracle.getDecodedTx(txController.text).then((value) {
                                            txInfo = value;
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          }).catchError((_){
                                            txInfo = 'An error occurred';
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          });
                                        }
                                      },
                                      child: const Text("Decode"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        liquidOracle.getRawTx(txController.text).then((value) {
                                          setState(() {
                                            txController.text = value;
                                            txInfo = 'Received transaction. Press Unblind next';
                                          });
                                        }).catchError((_){
                                          setState(() {
                                            txController.text = "";
                                            txInfo = 'An error occurred while requesting raw tx';
                                          });
                                        });
                                      },
                                      child: const Text("Get Transaction"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if(txController.text == "") {
                                          setState(() {
                                            txInfo = 'Not transaction found in corresponding field';
                                          });
                                          return;
                                        }
                                        liquidOracle.unblindRawTx(txController.text).then((value) {
                                          setState(() {
                                            txController.text = value;
                                            txInfo = 'Unblinded';
                                          });
                                        }).catchError((_){
                                          txInfo = 'An error occurred while unblinding';
                                          setState(() {
                                            txController.text = "";
                                          });
                                        });
                                      },
                                      child: const Text("Unblind"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if(txController.text == "") {
                                          setState(() {
                                            txInfo = 'Not transaction found in corresponding field';
                                          });
                                          return;
                                        }
                                        if (_formKey.currentState!.validate()) {
                                          liquidOracle.getSignedTx(txController.text, "").then((value) {
                                            txInfo = value;
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          }).catchError((_){
                                            txInfo = 'An error occurred';
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          });
                                        } else {
                                          liquidOracle.getSignedTx(txController.text, keyController.text).then((value) {
                                            txInfo = value;
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          }).catchError((_){
                                            txInfo = 'An error occurred';
                                            setState(() {
                                              txInfo = txInfo;
                                            });
                                          });
                                        }
                                      },
                                      child: const Text("Sign"),
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
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }
}
