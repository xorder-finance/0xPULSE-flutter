import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zeroin/investors_list_item.dart';
import 'package:zeroin/model/constants.dart';
import 'package:zeroin/model/investor.dart';

class InvestorsList extends StatefulWidget {
  const InvestorsList({Key? key}) : super(key: key);

  @override
  _InvestorsListState createState() => _InvestorsListState();
}

class _InvestorsListState extends State<InvestorsList> {
  List<Investor> investorsList = [];
  int openInvestorIndex = -1;

  void getList() async {
    final users = (jsonDecode(
        (await http.get(Uri.parse("$tachkaAddress/api/users"))).body) as List);
    // .where((element) =>
    //     element["publicAddress"] !=
    //     "0x931b23DaC01EF88BE746d752252D831464a3834C");

    print(users);
    final percents = (await Future.wait(users.map((e) => http.get(Uri.parse(
            "$tachkaAddress/api/blockchain/profit/${(e["publicAddress"] as String).toLowerCase()}")))))
        .map((e) => double.parse(e.body))
        .toList();

    print(percents);

    setState(() {
      investorsList = users
          .where((element) =>
              element["username"] != null && element["username"] != "")
          .mapIndexed((index, element) => Investor(
              twitterId: (element["username"] as String).substring(1),
              address: (element["publicAddress"] as String).toLowerCase(),
              percent: percents[index]))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: investorsList.length,
      itemBuilder: (context, index) {
        final investor = investorsList[index];
        return InvestorsListItem(
            investor: investor,
            isExpanded: index == openInvestorIndex,
            onExpandRequired: () => setState(() {
                  if (openInvestorIndex == index) {
                    openInvestorIndex = -1;
                  } else {
                    openInvestorIndex = index;
                  }
                }));
      },
    );
  }
}
