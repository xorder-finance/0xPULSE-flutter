import 'dart:convert';

import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';

import 'constants.dart';

Future<void> connectWeb3(String twitter) async {
  final eth = ethereum;
  if (eth == null) {
    return;
  }

  final web3 = Web3Provider(eth);
  await promiseToFuture(
      eth.request(RequestParams(method: 'eth_requestAccounts')));

  final publicAddress = eth.selectedAddress;

  int userId;
  final users = jsonDecode((await http.get(
          Uri.parse("$tachkaAddress/api/users?publicAddress=$publicAddress")))
      .body) as List;

  int nonce;
  if (users.isNotEmpty) {
    nonce = users[0]["nonce"];
    userId = users[0]["id"];
  } else {
    final nonceResponse = jsonDecode((await http.post(
            Uri.parse("$tachkaAddress/api/users"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"publicAddress": publicAddress})))
        .body);
    nonce = nonceResponse["nonce"];
    final users = jsonDecode((await http.get(
            Uri.parse("$tachkaAddress/api/users?publicAddress=$publicAddress")))
        .body) as List;
    userId = users[0]["id"];
  }

  print("Nonce: $nonce");

  final signature = await promiseToFuture(
      web3.getSigner().signMessage("I am signing my one-time nonce: $nonce"));

  print("Signature: $signature");

  final auth = jsonDecode((await http.post(Uri.parse("$tachkaAddress/api/auth"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"publicAddress": publicAddress, "signature": signature})))
      .body);

  print("Auth: $auth");

  final accessToken = auth["accessToken"];

  final rename = jsonDecode((await http.patch(
          Uri.parse("$tachkaAddress/api/users/$userId"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode({"username": twitter})))
      .body);

  print("Rename: $rename");
}
