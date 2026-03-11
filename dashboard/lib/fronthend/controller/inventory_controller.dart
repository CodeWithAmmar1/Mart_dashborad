import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class InventoryController extends GetxController {
  var itemList = <dynamic>[].obs; // Database items
  var currentSale = <dynamic>[].obs; // Current invoice items
  final String url = "http://localhost:3000/api/items";

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  Future<void> fetchItems() async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) itemList.value = jsonDecode(res.body);
  }
// Inside InventoryController
Future<void> addNewItem(String name, double price, int stock) async {
  final res = await http.post(
    Uri.parse("$url/add"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"name": name, "price": price, "stock": stock}),
  );
  
  if (res.statusCode == 200) {
    fetchItems(); // Refresh the list
    Get.snackbar("Success", "Item added to inventory");
  }
}
Future<void> deleteItem(String name) async {
  try {
    // Make sure your backend has a route like 'POST /api/items/delete'
    final res = await http.post(
      Uri.parse("$url/delete"), 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );

    if (res.statusCode == 200) {
      await fetchItems(); // Refresh the list from the DB
      Get.snackbar("Success", "Item deleted", backgroundColor: Colors.green);
    } else {
      Get.snackbar("Error", "Could not delete item", backgroundColor: Colors.red);
    }
  } catch (e) {
    Get.snackbar("Error", "Server error: $e", backgroundColor: Colors.red);
  }
}
  // logic: Just enter name, auto-fetch price and qty
  void addItemByName(String name) {
    // 1. Find the item in the database (itemList)
    var dbItem = itemList.firstWhere(
      (element) => element['name'].toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );

    if (dbItem == null) {
      Get.snackbar("Error", "Item not found in Inventory", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 2. Check if already in the current invoice
    int index = currentSale.indexWhere((item) => item['name'].toLowerCase() == name.toLowerCase());

    if (index != -1) {
      // If exists, check if we have enough stock in DB
      if (currentSale[index]['qty'] < dbItem['stock']) {
        currentSale[index]['qty'] += 1;
        currentSale.refresh();
      } else {
        Get.snackbar("Warning", "Insufficient Stock in DB", backgroundColor: Colors.orange);
      }
    } else {
      // If new to list, add first one
      currentSale.add({
        'name': dbItem['name'],
        'price': dbItem['price'],
        'qty': 1,
      });
    }
  }
// logic inside InventoryController
Future<void> confirmSaleInDB() async {
  try {
    for (var item in currentSale) {
      final res = await http.post(
        Uri.parse("$url/sell"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": item['name'], "quantity": item['qty']}),
      );
      if (res.statusCode != 200) throw Exception("Failed to update ${item['name']}");
    }
    await fetchItems(); // Refresh inventory stock from DB
  } catch (e) {
    Get.snackbar("Error", "Stock update failed: $e", backgroundColor: Colors.red);
  }
}
  void clearSale() => currentSale.clear();

  // Future<void> confirmSaleInDB() async {
  //   for (var item in currentSale) {
  //     await http.post(Uri.parse("$url/sell"),
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode({"name": item['name'], "quantity": item['qty']}));
  //   }
  //   fetchItems(); // Refresh stock counts
  // }
}