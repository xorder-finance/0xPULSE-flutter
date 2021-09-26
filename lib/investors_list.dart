import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zeroin/investors_list_item.dart';
import 'package:zeroin/model/investor.dart';

const mockList = [
  Investor(
      twitterId: "ForkLog",
      address: "0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503"),
  Investor(
      twitterId: "ASCapital6",
      address: "0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D504"),
];

class InvestorsList extends StatefulWidget {
  const InvestorsList({Key? key}) : super(key: key);

  @override
  _InvestorsListState createState() => _InvestorsListState();
}

class _InvestorsListState extends State<InvestorsList> {
  List<Investor> investorsList = [];
  int openInvestorIndex = -1;

  void getList() async {
    final users = jsonDecode(
        (await http.get(Uri.parse("http://185.241.53.33:8000/api/users")))
            .body) as List;
    print(users);
    setState(() {
      investorsList = users
          .where((element) =>
              element["username"] != null && element["username"] != "")
          .map((element) => Investor(
              twitterId: (element["username"] as String).substring(1),
              address: element["publicAddress"]))
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
