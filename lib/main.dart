import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeroin/investors_list.dart';

import 'model/connector.dart' if (dart.library.html) 'model/connector_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool investorMode = false;
  TextEditingController twitterController =
      TextEditingController(text: "@scaptaincap");

  List<Widget> defaultModeWidget(BuildContext context) {
    return [
      const SizedBox(height: 50),
      RichText(
          text: TextSpan(children: [
        TextSpan(
          text: "0x",
          style: TextStyle(
              fontFamily: "Graphik",
              fontSize: 56,
              color: Theme.of(context).colorScheme.secondary),
        ),
        TextSpan(
          text: "PULSE",
          style: TextStyle(
              fontFamily: "Graphik",
              fontSize: 56,
              color: Theme.of(context).colorScheme.primary),
        ),
      ])),
      const SizedBox(height: 8),
      const Text(
        "Find your trader",
        style: TextStyle(fontFamily: "Graphik", fontSize: 20),
      ),
      const SizedBox(height: 8),
      if (kIsWeb)
        Column(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  investorMode = true;
                });
              },
              child: const Text("Join the list"),
            ),
          ],
        ),
      const SizedBox(height: 16),
      const InvestorsList(),
      const SizedBox(height: 50),
    ];
  }

  List<Widget> investorModeWidget(BuildContext context) {
    return [
      const SizedBox(height: 50),
      TextButton(
        onPressed: () {
          setState(() {
            investorMode = false;
          });
        },
        child: const Text("Return to investors list"),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: twitterController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide()),
            label: Text("Your twitter account (starting with @)"),
            hintText: "@YourAccount"),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () {
          connectWeb3(twitterController.text);
        },
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Theme.of(context).primaryColor),
        child: const Text(
          "Connect",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Zeroin',
        theme: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF03A9F4), secondary: Color(0xFFFF5722))),
        home: Scaffold(
            body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Builder(builder: (context) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: 500,
                        minHeight: MediaQuery.of(context).size.height),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: investorMode
                            ? investorModeWidget(context)
                            : defaultModeWidget(context)),
                  );
                }),
              ],
            ),
          ),
        )));
  }
}
