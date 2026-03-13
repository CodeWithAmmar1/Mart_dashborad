import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryController extends GetxController {
  var itemList = <dynamic>[].obs; // Database items
  var currentSale = <dynamic>[].obs; // Current invoice items
  final String url = "https://martdashborad-production.up.railway.app/api/items";

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  Future<void> fetchItems() async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        itemList.value = jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  // --- ADD TO INVENTORY ---
  Future<void> addNewItem(String name, double price, int stock) async {
    final res = await http.post(
      Uri.parse("$url/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "price": price, "stock": stock}),
    );

    if (res.statusCode == 200) {
      fetchItems();
      Get.snackbar(
        "Success",
        "Item added to inventory",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // --- DELETE FROM INVENTORY ---
  Future<void> deleteItem(String name) async {
    try {
      final res = await http.post(
        Uri.parse("$url/delete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      );

      if (res.statusCode == 200) {
        await fetchItems();
        Get.snackbar(
          "Deleted",
          "$name removed",
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Server error: $e", backgroundColor: Colors.red);
    }
  }

  // --- SILENT SCANNER LOGIC ---
  void addItemByName(String query) {
    if (query.isEmpty) return;

    // 1. Search by Name OR Barcode (incase you store barcodes in your DB)
    var dbItem = itemList.firstWhere(
      (element) =>
          element['name'].toString().toLowerCase() == query.toLowerCase() ||
          (element['barcode'] != null &&
              element['barcode'].toString() == query),
      orElse: () => null,
    );

    if (dbItem == null) {
      Get.snackbar(
        "Not Found",
        "Item '$query' not in Inventory",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 2. Check current sale list
    int index = currentSale.indexWhere(
      (item) =>
          item['name'].toString().toLowerCase() ==
          dbItem['name'].toString().toLowerCase(),
    );

    if (index != -1) {
      // Increase qty if stock allows
      if (currentSale[index]['qty'] < dbItem['stock']) {
        currentSale[index]['qty'] += 1;
        currentSale.refresh();
      } else {
        Get.snackbar(
          "Stock Limit",
          "No more ${dbItem['name']} in stock",
          backgroundColor: Colors.amber,
        );
      }
    } else {
      // Add as new entry
      currentSale.add({
        'name': dbItem['name'],
        'price': dbItem['price'],
        'qty': 1,
      });
    }
  }

  // --- CONFIRM SALE & UPDATE DB ---
  Future<void> confirmSaleInDB() async {
    try {
      for (var item in currentSale) {
        final res = await http.post(
          Uri.parse("$url/sell"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"name": item['name'], "quantity": item['qty']}),
        );
        if (res.statusCode != 200)
          throw Exception("Failed to update ${item['name']}");
      }
      await fetchItems();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Stock update failed: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  void clearSale() => currentSale.clear();
}
