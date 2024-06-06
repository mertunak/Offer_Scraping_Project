import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/product/constants/utils/color_constants.dart';

class FlaskService {
  Future<void> runScraper(BuildContext context, String siteUrl) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.18.11.3:5000/run_scraper'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'site_url': siteUrl}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('Scraper Result: ${data['result']}');
          Fluttertoast.showToast(
            msg: "Site başarıyla eklendi",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: ButtonColors.PRIMARY_COLOR,
            textColor: Colors.white,
            fontSize: 20,
          );
        } else {
          print('Error running scraper: ${data['error']}');
          Fluttertoast.showToast(
            msg: "Site eklenemedi",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 20,
          );
        }
      } else {
        print('Failed to connect to the server');
      }
    } catch (e) {
      print('Exception during HTTP request: $e');
    }
  }
}