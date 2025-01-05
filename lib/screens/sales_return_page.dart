import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SalesReturnPage extends StatefulWidget {
  @override
  _SalesReturnPageState createState() => _SalesReturnPageState();
}

class _SalesReturnPageState extends State<SalesReturnPage> {
  final TextEditingController _barcodeController = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  Map<String, Map<String, dynamic>> productDatabase = {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchProductsAsMap(); // Verileri çek
  }

  void fetchProductsAsMap() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('ürünler').get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        productDatabase[doc.id] = {
          'ürün kodu': data['ürün kodu'] ?? '',
          'school': data['okul adı'] ?? '',
          'category': data['kategori'] ?? '',
          'size': data['beden'] ?? '',
          'price': double.tryParse(data['fiyat'].toString()) ?? 0.0,
          'quantity': int.tryParse(data['adet'].toString()) ?? 0,
        };
      }
    } catch (e) {
      print('Veriler alınırken hata oluştu: $e');
    }
  }

  Map<String, dynamic>? findProductByCode(String productCode) {
    for (var entry in productDatabase.entries) {
      if (entry.value['ürün kodu'] == productCode) {
        return entry.value;
      }
    }
    return null;
  }

  void addItemToCart(String productCode) {
    var foundProduct = findProductByCode(productCode);

    if (foundProduct != null) {
      setState(() {
        var existingItemIndex = cartItems.indexWhere((item) => item['barcode'] == productCode);
        if (existingItemIndex != -1) {
          cartItems[existingItemIndex]['quantity']++;
        } else {
          var newItem = Map<String, dynamic>.from(foundProduct);
          newItem['barcode'] = productCode;
          newItem['quantity'] = 1;
          cartItems.add(newItem);
        }
        calculateTotal();
      });
      _barcodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ürün bulunamadı')));
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

  Future<void> completeSale() async {
    try {
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String currentWeek = DateFormat('w').format(DateTime.now()); // Haftanın numarasını alıyoruz
      String currentDay = DateFormat('EEE').format(DateTime.now()); // gün

      // Satışa başlamadan önce stok kontrolü yapalım
      for (var item in cartItems) {
        String productCode = item['barcode'];
        int soldQuantity = item['quantity'];

        QuerySnapshot querySnapshot = await firestore
            .collection('ürünler')
            .where('ürün kodu', isEqualTo: productCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot productDoc = querySnapshot.docs.first;
          int currentQuantity = int.tryParse(productDoc['adet'].toString()) ?? 0;

          // Stok yetersizse, kullanıcıya uyarı ver
          if (currentQuantity < soldQuantity) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Stokta yeterli ürün yok: ${item['category']}'),
            ));
            return; // Stok yetersiz olduğunda satışı durdur
          }

          // Yeterli stok varsa, satış işlemini devam ettir
          int newQuantity = currentQuantity - soldQuantity;

          await firestore.collection('ürünler').doc(productDoc.id).update({
            'adet': newQuantity,
          });

          // Günlük satış kaydını oluştur
          await firestore.collection('satışlar').doc(currentDate).collection('kategoriler').doc(item['category']).set({
            'totalAmount': FieldValue.increment(totalAmount),
            'sales': FieldValue.increment(soldQuantity),
            'price': FieldValue.increment(item['price'] * soldQuantity),
          }, SetOptions(merge: true));

          // Haftalık satış kaydını oluştur
          await firestore.collection('haftalık satışlar').doc('haftalar').collection(currentWeek).doc(currentDay).set({
            'totalAmount': FieldValue.increment(totalAmount),
          }, SetOptions(merge: true));
        }
      }

      setState(() {
        cartItems.clear();
        totalAmount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Satış başarıyla tamamlandı')));
    } catch (e) {
      print('Satış sırasında hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bir hata oluştu.')));
    }
  }

  Future<void> completeReturn() async {
    try {
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String currentWeek = DateFormat('w').format(DateTime.now()); // Haftanın numarasını alıyoruz
      String currentDay = DateFormat('EEE').format(DateTime.now()); // gün adı

      for (var item in cartItems) {
        String productCode = item['barcode'];
        int returnedQuantity = item['quantity']; // İade edilen miktarı alıyoruz

        // Ürün koduna göre Firestore'da ilgili ürünü bulma
        QuerySnapshot querySnapshot = await firestore
            .collection('ürünler')
            .where('ürün kodu', isEqualTo: productCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot productDoc = querySnapshot.docs.first;

          // 'adet' değerini alıp int'e dönüştürme
          int currentQuantity = int.tryParse(productDoc['adet'].toString()) ?? 0;

          // Adeti artırma
          int newQuantity = currentQuantity + returnedQuantity;

          // Adeti güncelleme
          await firestore.collection('ürünler').doc(productDoc.id).update({
            'adet': newQuantity,
          });

          // Günlük satış kaydını güncelle
          await firestore.collection('satışlar').doc(currentDate).collection('kategoriler').doc(item['category']).set({
            'totalAmount': FieldValue.increment(-item['price'] * returnedQuantity),
            'sales': FieldValue.increment(-returnedQuantity),
            'price': FieldValue.increment(-item['price'] * returnedQuantity),
          }, SetOptions(merge: true));

          // Haftalık satış kaydını güncelle
          await firestore.collection('haftalık satışlar').doc('haftalar').collection(currentWeek).doc(currentDay).set({
            'totalAmount': FieldValue.increment(-item['price'] * returnedQuantity),
          }, SetOptions(merge: true));

          print('Ürün "${item['category']}" iade alındı ve stok güncellendi.');
        } else {
          print('Ürün "${item['category']}" Firestore\'da bulunamadı.');
        }
      }

      setState(() {
        cartItems.clear();
        totalAmount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İade işlemi başarıyla tamamlandı')));
    } catch (e) {
      print('İade sırasında hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bir hata oluştu.')));
    }
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
                  onPressed: () => addItemToCart(_barcodeController.text.trim()),
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
                      title: Text(item['category']),
                      subtitle: Text('${item['school']}  - ${item['size']}'),
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
                  onPressed: completeReturn,  // İade et butonu tekrar eklendi
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