import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class InventoryController extends GetxController {
  var itemList = <dynamic>[].obs;
  final String url = "http://localhost:3000/api/items";

  @override
  void onInit() { fetchItems(); super.onInit(); }

  Future<void> fetchItems() async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) itemList.value = jsonDecode(res.body);
  }

  Future<void> addItem(String name, double price, int stock) async {
    await http.post(Uri.parse("$url/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "price": price, "stock": stock}));
    fetchItems(); // Refresh list
    Get.back(); // Close dialog
  }

Future<void> sellItem(String name, int qty) async {
  final res = await http.post(Uri.parse("$url/sell"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "quantity": qty}));

  if (res.statusCode == 200) {
    // This triggers the Obx in your UI to refresh automatically
    await fetchItems(); 
    Get.snackbar("Success", "Sale confirmed!", backgroundColor: Colors.green);
  } else {
    Get.snackbar("Error", "Insufficient Stock", backgroundColor: Colors.red);
  }
}
}