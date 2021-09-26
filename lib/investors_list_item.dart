import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webviewx/webviewx.dart';
import 'package:zeroin/model/constants.dart';
import 'package:zeroin/model/investor.dart';

class InvestorsListItem extends StatefulWidget {
  final Investor investor;
  final bool isExpanded;
  final VoidCallback onExpandRequired;

  const InvestorsListItem(
      {Key? key,
      required this.investor,
      required this.isExpanded,
      required this.onExpandRequired})
      : super(key: key);

  @override
  _InvestorsListItemState createState() => _InvestorsListItemState();
}

class _InvestorsListItemState extends State<InvestorsListItem> {
  int currentPage = 0;
  List<FlSpot> balanceData = [];
  List<FlSpot> profitData = [];

  void loadBalanceData() async {
    final resp = jsonDecode((await http.get(Uri.parse(
            "$tachkaAddress/api/blockchain/chart/${widget.investor.address}")))
        .body);

    List dotsList;
    if (resp["eth"] != null) {
      dotsList = resp["eth"];
    } else {
      dotsList = resp["others"];
    }

    print(dotsList);
    setState(() {
      balanceData = dotsList.map((e) {
        return FlSpot(e[0], e[1]);
      }).toList();
    });
  }

  void loadProfitData() async {
    final resp = jsonDecode((await http.get(Uri.parse(
            "$tachkaAddress/api/blockchain/profitSliceV2/${widget.investor.address}")))
        .body) as List;

    print(resp);
    setState(() {
      profitData = resp
          .mapIndexed((index, e) {
            if (e is double) {
              return FlSpot(index.toDouble(), e);
            } else {
              return null;
            }
          })
          .whereType<FlSpot>()
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadBalanceData();
    loadProfitData();
  }

  Widget profitGraph() {
    if (profitData.isEmpty) {
      return const Center(
          child: Text("This trader has no transactions...",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Graphik", fontSize: 42)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (barData, indicators) {
                      return indicators.map((int index) {
                        return TouchedSpotIndicatorData(
                            FlLine(strokeWidth: 2, color: Colors.green),
                            FlDotData(show: false));
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots
                              .map((e) => LineTooltipItem(
                                  "${e.y.toStringAsFixed(2)} eth",
                                  TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "Graphik",
                                  )))
                              .toList();
                        })),
                titlesData: FlTitlesData(
                    show: false,
                    bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (val) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                              val.toInt() * 1000);
                          return "${d.day}.${d.month}";
                        },
                        interval: 1000 * 60 * 60),
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false)),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    colors: [Colors.green],
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradientFrom: const Offset(0, 0),
                        gradientTo: const Offset(0, 1),
                        colors: [Colors.green, Colors.green.withOpacity(0)]),
                    spots: profitData,
                  )
                ]),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
          child: RichText(
            textAlign: TextAlign.start,
            text: const TextSpan(
              children: [
                TextSpan(
                    text: "Profit dynamics for ",
                    style: TextStyle(
                        fontFamily: "Graphik",
                        fontSize: 12,
                        color: Colors.black)),
                TextSpan(
                    text: "100 transactions",
                    style: TextStyle(
                        fontFamily: "Graphik",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget balanceGraph() {
    if (balanceData.isEmpty) {
      return const Center(
          child: Text("This trader has no transactions...",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Graphik", fontSize: 42)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (barData, indicators) {
                      return indicators.map((int index) {
                        return TouchedSpotIndicatorData(
                            FlLine(strokeWidth: 2, color: Colors.green),
                            FlDotData(show: false));
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots
                              .map((e) => LineTooltipItem(
                                  "${e.y.toStringAsFixed(2)} \$",
                                  TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "Graphik",
                                  )))
                              .toList();
                        })),
                titlesData: FlTitlesData(
                    show: false,
                    bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (val) {
                          final d = DateTime.fromMillisecondsSinceEpoch(
                              val.toInt() * 1000);
                          return "${d.day}.${d.month}";
                        },
                        interval: 1000 * 60 * 60),
                    rightTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false)),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    colors: [Colors.green],
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradientFrom: const Offset(0, 0),
                        gradientTo: const Offset(0, 1),
                        colors: [Colors.green, Colors.green.withOpacity(0)]),
                    spots: balanceData,
                  )
                ]),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
          child: RichText(
            textAlign: TextAlign.start,
            text: const TextSpan(
              children: [
                TextSpan(
                    text: "Balance changes for ",
                    style: TextStyle(
                        fontFamily: "Graphik",
                        fontSize: 12,
                        color: Colors.black)),
                TextSpan(
                    text: "1 day",
                    style: TextStyle(
                        fontFamily: "Graphik",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget detailedData(Investor investor) {
    final pages = [
      profitGraph(),
      LayoutBuilder(builder: (context, constraints) {
        return WebViewX(
          initialSourceType: SourceType.html,
          initialContent:
              '<a class="twitter-timeline" href="https://twitter.com/${investor.twitterId}">Tweets by TwitterDev</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>',
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );
      }),
      balanceGraph(),
    ];

    return SizedBox(
      width: double.infinity,
      height: 350,
      child: Column(
        children: [
          Expanded(
              child: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl(
                  children: const {
                    0: Text("Profit"),
                    1: Text(
                      "Twitter",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    2: Text("Balance")
                  },
                  onValueChanged: ((tab) => setState(() {
                        currentPage = tab as int;
                      })),
                  groupValue: currentPage,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: IndexedStack(
                  index: currentPage,
                  children: pages,
                ),
              )
            ],
          )),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final investor = widget.investor;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    widget.onExpandRequired();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(42),
                              child: Image.network(
                                "https://unavatar.io/twitter/${investor.twitterId}",
                                height: 42,
                                width: 42,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "@${investor.twitterId}",
                                  style: const TextStyle(
                                      fontFamily: "Graphik", fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  investor.address,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontFamily: "Graphik",
                                      fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${investor.percent > 0 ? "+" : ""}${investor.percent.toStringAsFixed(2)}%",
                        style: TextStyle(
                            color: investor.percent >= 0
                                ? Colors.green
                                : Colors.red,
                            fontFamily: "Graphik",
                            fontSize: 18),
                      ),
                      Icon(
                        widget.isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.decelerate,
                child: widget.isExpanded
                    ? detailedData(investor)
                    : Container(height: 0)),
          ],
        ),
      ),
    );
  }
}
