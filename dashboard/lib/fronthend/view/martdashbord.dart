import 'package:dashboard/fronthend/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Hardware Keyboard events
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MartDashboard extends StatefulWidget {
  // Changed to StatefulWidget to manage TabController
  const MartDashboard({super.key});

  @override
  State<MartDashboard> createState() => _MartDashboardState();
}

class _MartDashboardState extends State<MartDashboard>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(InventoryController());
  late TabController _tabController;
  final FocusNode _scannerFocusNode = FocusNode();
  String _barcodeBuffer = "";

  @override
  void initState() {
    super.initState();
    // Initialize TabController to track which tab we are on
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _scannerFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_barcodeBuffer.isNotEmpty) {
              _handleScannerInput(_barcodeBuffer.trim());
              _barcodeBuffer = "";
            }
          } else if (event.character != null) {
            _barcodeBuffer += event.character!;
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFD700),
          title: const Text(
            "CYBER MART",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController, // Attach controller
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: const [Tab(text: "INVENTORY"), Tab(text: "SALES")],
          ),
        ),
        body: TabBarView(
          controller: _tabController, // Attach controller
          children: [_inventoryList(), _salesList()],
        ),
      ),
    );
  }

  void _handleScannerInput(String data) {
    if (_tabController.index == 0) {
      // TAB 1: INVENTORY - Open Dialog to add/update stock
      _showAddItemDialog(scannedName: data);
    } else {
      // TAB 2: SALES - Directly push to the sales list
      controller.addItemByName(data);
    }
  }

  // --- TAB 1: INVENTORY ---
  Widget _inventoryList() => Scaffold(
    body: Obx(
      () => ListView.builder(
        itemCount: controller.itemList.length,
        itemBuilder: (context, i) {
          var item = controller.itemList[i];
          return ListTile(
            title: Text(item['name'].toString().toUpperCase()),
            subtitle: Text(
              "Price: \$${item['price']} | Stock: ${item['stock']}",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.deleteItem(item['name']),
            ),
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xFFFFD700),
      onPressed: () => _showAddItemDialog(),
      child: const Icon(Icons.add, color: Colors.black),
    ),
  );

  void _showAddItemDialog({String? scannedName}) {
    final name = TextEditingController(text: scannedName ?? "");
    final price = TextEditingController();
    final stock = TextEditingController();

    Get.defaultDialog(
      backgroundColor: Colors.black, // Match Invoice Theme
      title: scannedName != null ? "NEW INVENTORY ITEM" : "ADD NEW ITEM",
      titleStyle: const TextStyle(
        color: Color(0xFFFFD700),
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Divider(color: Colors.amber, thickness: 0.5),
          const SizedBox(height: 10),

          // Item Name Field
          TextField(
            controller: name,
            readOnly: scannedName != null,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Item Name / Barcode",
              labelStyle: const TextStyle(color: Colors.amber),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Price Field
          TextField(
            controller: price,
            autofocus: scannedName != null,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Set Price (\$)",
              labelStyle: TextStyle(color: Colors.amber),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Stock Field
          TextField(
            controller: stock,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Initial Stock Quantity",
              labelStyle: TextStyle(color: Colors.amber),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Save Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (name.text.isNotEmpty &&
                  price.text.isNotEmpty &&
                  stock.text.isNotEmpty) {
                controller.addNewItem(
                  name.text,
                  double.parse(price.text),
                  int.parse(stock.text),
                );
                Get.back();
                _scannerFocusNode.requestFocus();
              } else {
                Get.snackbar(
                  "Error",
                  "Please fill all fields",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              "SAVE TO DATABASE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: SALES ---
  Widget _salesList() => Scaffold(
    backgroundColor: Colors.black,
    body: Obx(
      () =>
          controller.currentSale.isEmpty
              ? const Center(
                child: Text(
                  "Ready to Scan Items...",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: controller.currentSale.length,
                itemBuilder: (context, i) {
                  var item = controller.currentSale[i];
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        item['name'].toString().toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Qty: ${item['qty']} | Price: \$${item['price']}",
                        style: const TextStyle(color: Colors.amber),
                      ),
                      trailing: Text(
                        "\$${(item['price'] * item['qty']).toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
    ),
    floatingActionButton: Obx(
      () =>
          controller.currentSale.isNotEmpty
              ? FloatingActionButton.extended(
                backgroundColor: const Color(0xFFFFD700),
                onPressed: () => _showInvoiceDialog(),
                label: const Text(
                  "GENERATE INVOICE",
                  style: TextStyle(color: Colors.black),
                ),
                icon: const Icon(Icons.receipt, color: Colors.black),
              )
              : const SizedBox(),
    ),
  );
  // --- Invoice & PDF logic remains the same ---
  void _showInvoiceDialog() {
    double total = controller.currentSale.fold(
      0,
      (sum, item) => sum + (item['price'] * item['qty']),
    );
    Get.defaultDialog(
      backgroundColor: Colors.black,
      title: "PRINT INVOICE",
      titleStyle: const TextStyle(color: Color(0xFFFFD700)),
      content: Column(
        children: [
          ...controller.currentSale
              .map(
                (item) => _invoiceRow(
                  "${item['name']} x${item['qty']}",
                  "\$${(item['price'] * item['qty']).toStringAsFixed(2)}",
                ),
              )
              .toList(),
          const Divider(color: Colors.amber),
          _invoiceRow("TOTAL", "\$${total.toStringAsFixed(2)}", isBold: true),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () => _generatePdfAndSave(total),
            child: const Text(
              "SAVE PDF & CLEAR",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfAndSave(double total) async {
    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.nunitoExtraLight();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build:
              (pw.Context context) => pw.Column(
                children: [
                  pw.Center(
                    child: pw.Text(
                      "CYBER MART",
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Divider(),
                  ...controller.currentSale.map(
                    (item) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "${item['name']} x${item['qty']}",
                          style: pw.TextStyle(font: font),
                        ),
                        pw.Text(
                          "${(item['price'] * item['qty']).toStringAsFixed(2)}",
                          style: pw.TextStyle(font: font),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "TOTAL",
                        style: pw.TextStyle(
                          font: font,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        total.toStringAsFixed(2),
                        style: pw.TextStyle(
                          font: font,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      );
      final bytes = await pdf.save();
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Invoice_${DateTime.now().millisecondsSinceEpoch}',
      );
      await controller.confirmSaleInDB();
      controller.clearSale();
      if (Get.isDialogOpen!) Get.back();
      _scannerFocusNode.requestFocus();
    } catch (e) {
      debugPrint("PDF Error: $e");
    }
  }

  Widget _invoiceRow(String l, String v, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(color: Colors.grey)),
        Text(
          v,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    ),
  );
}
