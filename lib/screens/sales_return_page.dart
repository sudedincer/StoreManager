import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SalesReturnPage extends StatefulWidget {
  @override
  _SalesReturnPageState createState() => _SalesReturnPageState();
}

class _SalesReturnPageState extends State<SalesReturnPage> {
  final TextEditingController _barcodeController = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;

  // veritabanından gelen bilgiler map olarak buraya gelicek
  final Map<String, Map<String, dynamic>> productDatabase = {
    'BRCD001': {'name': 'Tişört', 'school': 'Atatürk İlkokulu', 'category': 'Tişört', 'size': 'M', 'price': 29.99},
    'BRCD002': {'name': 'Sweatshirt', 'school': 'Cumhuriyet Ortaokulu', 'category': 'Sweatshirt', 'size': 'L', 'price': 49.99},
    'BRCD003': {'name': 'Pantolon', 'school': 'Fatih Lisesi', 'category': 'Pantolon', 'size': '32', 'price': 59.99},
    'BRCD004': {'name': 'Ceket', 'school': 'Gazi Üniversitesi', 'category': 'Ceket', 'size': 'XL', 'price': 79.99},
    'BRCD005': {'name': 'Şort', 'school': 'İnönü İlkokulu', 'category': 'Şort', 'size': 'S', 'price': 39.99},
  };

  void addItemToCart(String barcode) {
    if (productDatabase.containsKey(barcode)) {
      setState(() {
        var existingItemIndex = cartItems.indexWhere((item) => item['barcode'] == barcode);
        if (existingItemIndex != -1) {
          cartItems[existingItemIndex]['quantity']++;
        } else {
          var newItem = Map<String, dynamic>.from(productDatabase[barcode]!);
          newItem['barcode'] = barcode;
          newItem['quantity'] = 1;
          cartItems.add(newItem);
        }
        calculateTotal();
      });
      _barcodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün bulunamadı')),
      );
    }
  }

  void removeItemFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
      calculateTotal();
    });
  }

  void updateItemQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] = (cartItems[index]['quantity'] + change).clamp(1, 99);
      calculateTotal();
    });
  }

  void calculateTotal() {
    totalAmount = cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void completeSale() {
    //satış yapıldıpında burada stoktan azaltma yapılacak
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Satış tamamlandı')),
    );
    setState(() {
      cartItems.clear();
      totalAmount = 0;
    });
  }

  void completeReturn() {
    //iade yapıldığında burada stoğa geri ekleme yapılacak
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('İade tamamlandı')),
    );
    setState(() {
      cartItems.clear();
      totalAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satış / İade'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barkod',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => addItemToCart(_barcodeController.text),
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => addItemToCart(value),
            ),
            SizedBox(height: 20),
            Text('Sepet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text('${item['school']} - ${item['category']} - ${item['size']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => updateItemQuantity(index, -1),
                          ),
                          Text('${item['quantity']}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => updateItemQuantity(index, 1),
                          ),
                          SizedBox(width: 8),
                          Text('₺${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => removeItemFromCart(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Toplam Tutar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₺${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: completeSale,
                  child: Text('Satışı Tamamla'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: completeReturn,
                  child: Text('İade Et'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

