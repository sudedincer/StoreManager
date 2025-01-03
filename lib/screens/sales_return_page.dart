import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, Map<String, dynamic>> productDatabase = {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchProductsAsMap(); // Verileri çek
  }

  // Verileri Firestore'dan çekme ve Map olarak döndürme
  void fetchProductsAsMap() async {
    try {
      // 'ürünler' koleksiyonundaki dökümanları çek
      QuerySnapshot querySnapshot = await firestore.collection('ürünler').get();

      // Dökümanları döngüyle işleyerek Map'e dönüştür
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Dökümandaki verileri Map'e ekle
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
    print(productDatabase);

  }
  Map<String, dynamic>? findProductByCode(String productCode) {
    for (var entry in productDatabase.entries) {
      if (entry.value['ürün kodu'] != null && entry.value['ürün kodu'] == productCode) {
        return entry.value;
      }
    }
    return null;
  }


  void addItemToCart(String productCode) {

    // Ürün koduna göre ürünü bul
    var foundProduct = findProductByCode(productCode);
    print('Product Code: $productCode');
    print('Found Product: $foundProduct');

    if (foundProduct != null) {
      setState(() {
        // Sepette ürün zaten varsa miktarını artır
        var existingItemIndex = cartItems.indexWhere((item) => item['barcode'] == productCode);
        if (existingItemIndex != -1) {
          cartItems[existingItemIndex]['quantity']++;
        } else {
          // Ürünü sepete ekle
          var newItem = Map<String, dynamic>.from(foundProduct); // Doğrudan foundProduct kullanılıyor
          newItem['barcode'] = productCode; // Barkod (ürün kodu) ekleniyor
          newItem['quantity'] = 1;
          cartItems.add(newItem);
        }
        // Toplamı yeniden hesapla
        calculateTotal();
      });

      // Barkod giriş alanını temizle
      _barcodeController.clear();
    } else {
      // Ürün bulunamadığında kullanıcıya bilgi ver
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


  void completeSale() async {
    // Satış yapılırken, sepetteki her ürün için Firestore'da adet güncellemesi yapılacak
    try {
      for (var item in cartItems) {
        String productCode = item['barcode']; // Ürün kodunu alıyoruz
        int soldQuantity = item['quantity'];  // Satılan miktarı alıyoruz

        // Ürün koduna göre Firestore'da ilgili ürünü bulma
        QuerySnapshot querySnapshot = await firestore
            .collection('ürünler')
            .where('ürün kodu', isEqualTo: productCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot productDoc = querySnapshot.docs.first;

          // 'adet' değerini alıp int'e dönüştürme
          int currentQuantity = 0;
          if (productDoc['adet'] != null) {
            currentQuantity = int.tryParse(productDoc['adet'].toString()) ?? 0;
          }

          if (currentQuantity >= soldQuantity) {
            // Adeti düşürme
            int newQuantity = currentQuantity - soldQuantity;

            // Adeti güncelleme
            await firestore.collection('ürünler').doc(productDoc.id).update({
              'adet': newQuantity,
            });
            print('Ürün "${item['category']}" satışı tamamlandı ve stok güncellendi.');
          } else {
            print('Yeterli stok yok: ${item['category']}');
          }
        } else {
          print('Ürün "${item['category']}" Firestore\'da bulunamadı.');
        }
      }

      // Satış tamamlandığında, sepeti temizleyip toplam tutarı sıfırlıyoruz
      setState(() {
        cartItems.clear();
        totalAmount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Satış başarıyla tamamlandı')),
      );
    } catch (e) {
      print('Satış sırasında hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu.')),
      );
    }
  }

  void completeReturn() async {
    // İade yapılırken, sepetteki her ürün için Firestore'da adet güncellemesi yapılacak
    try {
      for (var item in cartItems) {
        String productCode = item['barcode']; // Ürün kodunu alıyoruz
        int returnedQuantity = item['quantity'];  // İade edilen miktarı alıyoruz

        // Ürün koduna göre Firestore'da ilgili ürünü bulma
        QuerySnapshot querySnapshot = await firestore
            .collection('ürünler')
            .where('ürün kodu', isEqualTo: productCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot productDoc = querySnapshot.docs.first;

          // 'adet' değerini alıp int'e dönüştürme
          int currentQuantity = 0;
          if (productDoc['adet'] != null) {
            currentQuantity = int.tryParse(productDoc['adet'].toString()) ?? 0;
          }

          // Adeti artırma
          int newQuantity = currentQuantity + returnedQuantity;

          // Adeti güncelleme
          await firestore.collection('ürünler').doc(productDoc.id).update({
            'adet': newQuantity,
          });
          print('Ürün "${item['category']}" iade alındı ve stok güncellendi.');
        } else {
          print('Ürün "${item['category']}" Firestore\'da bulunamadı.');
        }
      }

      // İade tamamlandığında, sepeti temizleyip toplam tutarı sıfırlıyoruz
      setState(() {
        cartItems.clear();
        totalAmount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İade başarıyla tamamlandı')),
      );
    } catch (e) {
      print('İade sırasında hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu.')),
      );
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

