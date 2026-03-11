import 'package:dashboard/fronthend/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MartDashboard extends StatelessWidget {
  MartDashboard({super.key});
  final controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFD700),
          title: const Text("CYBER MART", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

  // --- TAB 1: INVENTORY ---
// --- TAB 1: INVENTORY ---
Widget _inventoryList() => Scaffold(
      body: Obx(() => ListView.builder(
            itemCount: controller.itemList.length,
            itemBuilder: (context, i) {
              var item = controller.itemList[i];
              return ListTile(
                title: Text(item['name'].toString().toUpperCase()),
                subtitle: Text("Price: \$${item['price']} | Stock: ${item['stock']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteItem(item['name']),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: () => _showAddItemDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
    void _showAddItemDialog() {
  final name = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();

  Get.defaultDialog(
    title: "ADD NEW ITEM",
    content: Column(
      children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Item Name")),
        TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
        TextField(controller: stock, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Ensure you have this 'addNewItem' method in your InventoryController
            controller.addNewItem(
              name.text, 
              double.parse(price.text), 
              int.parse(stock.text)
            );
            Get.back();
          },
          child: const Text("SAVE TO DATABASE"),
        )
      ],
    ),
  );
}
  // --- TAB 2: SALES ---
  Widget _salesList() => Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() => controller.currentSale.isEmpty
            ? const Center(
                child: Text("Ready to Scan / Enter Name", 
                  style: TextStyle(color: Colors.white)))
            : ListView.builder(
                itemCount: controller.currentSale.length,
                itemBuilder: (context, i) {
                  var item = controller.currentSale[i];
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(item['name'].toString().toUpperCase(), 
                        style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Qty: ${item['qty']} | Price: \$${item['price']}", 
                        style: const TextStyle(color: Colors.amber)),
                      trailing: Text("\$${(item['price'] * item['qty']).toStringAsFixed(2)}", 
                        style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              )),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "add",
              backgroundColor: Colors.white,
              onPressed: () => _showQuickAddDialog(),
              child: const Icon(Icons.search, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Obx(() => controller.currentSale.isNotEmpty
                ? FloatingActionButton.extended(
                    heroTag: "gen",
                    backgroundColor: const Color(0xFFFFD700),
                    onPressed: () => _showInvoiceDialog(),
                    label: const Text("GENERATE INVOICE", 
                      style: TextStyle(color: Colors.black)),
                    icon: const Icon(Icons.receipt, color: Colors.black),
                  )
                : const SizedBox()),
          ],
        ),
      );

  void _showQuickAddDialog() {
    final nameController = TextEditingController();
    Get.defaultDialog(
      backgroundColor: Colors.grey[900],
      title: "QUICK ADD",
      titleStyle: const TextStyle(color: Color(0xFFFFD700)),
      content: TextField(
        controller: nameController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: "Enter Item Name",
          labelStyle: TextStyle(color: Colors.amber),
        ),
        onSubmitted: (val) {
          controller.addItemByName(val);
          Get.back();
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
        onPressed: () {
          controller.addItemByName(nameController.text);
          Get.back();
        },
        child: const Text("OK", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showInvoiceDialog() {
    double total = controller.currentSale.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

    Get.defaultDialog(
      backgroundColor: Colors.black,
      title: "PRINT INVOICE",
      titleStyle: const TextStyle(color: Color(0xFFFFD700)),
      content: Column(
        children: [
          ...controller.currentSale.map((item) => _invoiceRow(
            "${item['name']} x${item['qty']}", 
            "\$${(item['price'] * item['qty']).toStringAsFixed(2)}")).toList(),
          const Divider(color: Colors.amber),
          _invoiceRow("TOTAL", "\$${total.toStringAsFixed(2)}", isBold: true),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              minimumSize: const Size(double.infinity, 45)),
            onPressed: () => _generatePdfAndSave(total),
            child: const Text("SAVE PDF & CLEAR", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future<void> _generatePdfAndSave(double total) async {
    try {
      final pdf = pw.Document();
      // Using a standard font to avoid Unicode "Boxes" errors
      final font = await PdfGoogleFonts.nunitoExtraLight();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("CYBER MART", 
                    style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Divider(),
                ...controller.currentSale.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("${item['name']} x${item['qty']}", style: pw.TextStyle(font: font)),
                    pw.Text("${(item['price'] * item['qty']).toStringAsFixed(2)}", 
                      style: pw.TextStyle(font: font)),
                  ],
                )).toList(),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL", style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                    pw.Text(total.toStringAsFixed(2), 
                      style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      // Opens native print dialog for PDF saving/printing
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Invoice_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Only proceed to clear database/UI if printing didn't fail
      await controller.confirmSaleInDB();
      controller.clearSale();
      
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Success", "Stock Updated & List Cleared", 
        backgroundColor: Colors.white);

    } catch (e) {
      debugPrint("PDF Error: $e");
      Get.snackbar("Error", "Restart the app to link Printer services.");
    }
  }

  Widget _invoiceRow(String l, String v, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Colors.grey)),
      Text(v, style: TextStyle(
        color: Colors.white, 
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: isBold ? 16 : 14)),
    ]),
  );
}