import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zeroin/investors_list.dart';
import 'package:zeroin/investors_list_item.dart';
import 'package:zeroin/model/constants.dart';
import 'package:zeroin/model/investor.dart';

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
  TextEditingController twitterController = TextEditingController(text: "");
  TextEditingController searchController = TextEditingController(text: "");
  bool canSearch = false;
  Investor? investor;

  void loadInvestor() async {
    final address = searchController.text.toLowerCase();

    final profit = jsonDecode((await http
            .get(Uri.parse("$tachkaAddress/api/blockchain/profit/$address")))
        .body);

    setState(() {
      investor =
          Investor(twitterId: "UnknownTwitter", address: address, percent: profit);
    });
  }

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
      InvestorsList(
        onLoad: () {
          setState(() {
            canSearch = true;
          });
        },
      ),
      if (canSearch)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderSide: BorderSide()),
                    label: Text("Find any other investor by wallet"),
                    hintText: "0xdead...beaf"),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    loadInvestor();
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (investor != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    InvestorsListItem(
                      key: ValueKey(investor!.address),
                      investor: investor!,
                      isExpanded: true,
                      onExpandRequired: () {},
                    ),
                  ],
                )
            ],
          ),
        ),
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
        onPressed: () async {
          await connectWeb3(twitterController.text);
          setState(() {
            investorMode = false;
          });
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
