import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Services {
  Future isAuth(String userId, String password) async {
    var url = Uri.https(dotenv.env['SERVER'], '/isauth');
    var response =
        await http.post(url, body: {'userid': userId, 'password': password});
    print(response.body);
    var decoded = json.decode(response.body);

    if (decoded['success'].toString().compareTo("True") == 0) {
      return true;
    } else {
      return false;
    }
  }
}
