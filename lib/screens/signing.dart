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

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }
  String txInfo = "";
  String buttonLabel = 'Submit';

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
                                hintText: 'Enter raw transaction here',
                              ),
                              controller: myController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please, enter transaction';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  txInfo = '';
                                  setState(() {
                                    txInfo = txInfo;
                                  });
                                  if(buttonLabel == "Submit"){
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState!.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Requesting info...')),
                                      );
                                      liquidOracle.getDecodedTx(myController.text).then((value) {
                                        txInfo = value;
                                        setState(() {
                                          txInfo = txInfo;
                                          buttonLabel = "Sign";
                                        });
                                      }).catchError((_){
                                        txInfo = 'An error occurred';
                                        setState(() {
                                          txInfo = txInfo;
                                        });
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Sending transaction...')),
                                    );
                                    liquidOracle.getSignedTx(myController.text).then((value) {
                                      txInfo = value;
                                      setState(() {
                                        txInfo = txInfo;
                                        buttonLabel = "Sign";
                                      });
                                    }).catchError((_){
                                      txInfo = 'An error occurred';
                                      setState(() {
                                        txInfo = txInfo;
                                      });
                                    });
                                  }
                                },
                                child: Text(buttonLabel),
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
