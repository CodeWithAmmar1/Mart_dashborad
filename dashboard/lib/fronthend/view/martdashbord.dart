import 'package:dashboard/fronthend/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MartDashboard extends StatelessWidget {
  MartDashboard({super.key});
  final controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFD700),
          title: const Text(
            "CYBER MART",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [Tab(text: "INVENTORY"), Tab(text: "SALES")],
          ),
        ),
        body: TabBarView(children: [_inventoryList(), _salesList()]),
      ),
    );
  }

  Widget _inventoryList() => Scaffold(
    backgroundColor: Colors.white,
    body: Obx(
      () => ListView.builder(
        itemCount: controller.itemList.length,
        itemBuilder: (context, i) {
          var item = controller.itemList[i];
          return Card(
            color: Colors.grey[250],
            child: ListTile(
              title: Text(
                item['name'].toUpperCase(),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Price: \$${item['price']} | Stock: ${item['stock']}",
                style: const TextStyle(color: Colors.amber),
              ),
            ),
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xFFFFD700),
      onPressed: () => _showDialog(isSell: false),
      child: const Icon(Icons.add, color: Colors.black),
    ),
  );

  Widget _salesList() => Scaffold(
    backgroundColor: Colors.white,
    body: Obx(
      () => ListView.builder(
        itemCount: controller.itemList.length,
        itemBuilder: (context, i) {
          var item = controller.itemList[i];
          return Card(
            color: Colors.grey[250],
            child: ListTile(
              title: Text(
                item['name'].toUpperCase(),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Price: \$${item['price']} | Stock: ${item['stock']}",
                style: const TextStyle(color: Colors.amber),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => controller.sellItem(item['name'], 1),
                child: const Text(
                  "SELL 1",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  void _showDialog({required bool isSell}) {
    final name = TextEditingController();
    final price = TextEditingController();
    final qty = TextEditingController();
    Get.defaultDialog(
      title: "ADD NEW ITEM",
      content: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: price,
            decoration: const InputDecoration(labelText: "Price"),
          ),
          TextField(
            controller: qty,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),
          ElevatedButton(
            onPressed:
                () => controller.addItem(
                  name.text,
                  double.parse(price.text),
                  int.parse(qty.text),
                ),
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }
}
