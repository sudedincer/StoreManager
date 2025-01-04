import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockTrackingPage extends StatefulWidget {
  @override
  _StockTrackingPageState createState() => _StockTrackingPageState();
}

class _StockTrackingPageState extends State<StockTrackingPage> {
  String? selectedCategory;
  String? selectedSchool;
  List<Map<String, dynamic>> stockData = [];

  //buradaki iconlar değişecek
   List<Map<String, dynamic>> categories = [
    {'name': 'Tişört'},
    {'name': 'Sweatshirt'},
    {'name': 'Pantolon'},
    {'name': 'Ceket'},
    {'name': 'Şort'},
    {'name': 'Şort Etek'},
    {'name': 'Selanik'},
    {'name': 'Eşofman Takımı'},
    {'name': 'Eşofman Tişörtü'},
    {'name': 'Eşofman Altı'},
  ];

   List<String> schools = [];

  @override
  void initState() {
    super.initState();
    getSchools(); // Okul adlarını Firebase'den çekmek için çağrılıyor
  }

  Future<void> getSchools() async {
    try {
      // Firestore koleksiyonundan okul adlarını çekiyoruz
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ürünler').get();

      // Okul adlarını bir Set içinde saklıyoruz, böylece her okul adı yalnızca bir kez eklenir
      Set<String> uniqueSchools = {};

      for (var doc in snapshot.docs) {
        String schoolName = doc['okul adı']; // 'okul adı' alanını çekiyoruz
        uniqueSchools.add(schoolName); // Set'e ekliyoruz, otomatik olarak benzersiz olur
      }

      setState(() {
        schools = uniqueSchools.toList(); // Set'i listeye çevirip okulların listesini güncelliyoruz
      });
    } catch (e) {
      print("Okul verileri alınırken hata oluştu: $e");
    }
  }

  void searchStock() async {
    // Simulating API call or database query
    //veritavanından burada gerçek veriler gelecek
    if (selectedSchool == null || selectedCategory==null) {
      // Okul veya kategori seçilmemişse, uyarı verebilirsiniz
      return;
    }

    try {
      setState(() {
        stockData = []; // Önce mevcut veriyi sıfırlıyoruz
      });

      // Firestore koleksiyonundan okul adı ve kategoriye göre veri çekiyoruz
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool) // Okul adı filtresi
          .where('kategori', isEqualTo: selectedCategory) // Kategorileri filtreliyoruz
          .get();

      // Firestore'dan dönen verileri stockData listesine ekliyoruz
      List<Map<String, dynamic>> fetchedStockData = [];
      for (var doc in snapshot.docs) {
        // Veriyi map olarak ekliyoruz
        fetchedStockData.add({
          'beden': doc['beden'],
          'adet': doc['adet'],
          'fiyat': doc['fiyat'],
          'ürün kodu': doc['ürün kodu'],
        });
      }

      setState(() {
        stockData = fetchedStockData; // Veriyi stockData'ya ekliyoruz
      });
    } catch (e) {
      print("Stok verileri alınırken hata oluştu: $e");
    }
  }

  void updateStock(int index) async {
    // Firestore'da veri güncellemeleri yapmak için gerekli
    TextEditingController quantityController = TextEditingController(text: stockData[index]['adet'].toString());
    TextEditingController priceController = TextEditingController(text: stockData[index]['fiyat'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Güncelle: ${stockData[index]['beden']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Adet'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Güncelle'),
              onPressed: () async {
                // Kullanıcı yeni adet ve fiyat girerse bu verileri Firestore'a kaydediyoruz
                String productCode = stockData[index]['ürün kodu'];

                // Firestore veritabanında "ürünler" koleksiyonundaki ürün kodu ile eşleşen ürünü buluyoruz
                try {
                  // Firestore'dan ürün koduna göre belgeyi güncelleme
                  await FirebaseFirestore.instance
                      .collection('ürünler')
                      .where('ürün kodu', isEqualTo: productCode)
                      .get()
                      .then((querySnapshot) async {
                    if (querySnapshot.docs.isNotEmpty) {
                      // Ürün bulundu, güncelleme işlemi yapılacak
                      var productDoc = querySnapshot.docs.first;

                      // Ürün verilerini güncelleme
                      await productDoc.reference.update({
                        'adet': int.parse(quantityController.text),
                        'fiyat': priceController.text,
                      });

                      // Veriyi kullanıcı arayüzüne de yansıtıyoruz
                      setState(() {
                        stockData[index]['adet'] = int.parse(quantityController.text);
                        stockData[index]['fiyat'] = double.parse(priceController.text);
                      });
                      Navigator.of(context).pop(); // Dialogu kapat
                    } else {
                      // Ürün bulunamazsa kullanıcıya hata mesajı gösterilebilir
                      print('Ürün bulunamadı!');
                    }
                  });
                } catch (e) {
                  print("Güncellenirken hata oluştu: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Takibi'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori Seçin kısmı
              Text('Kategori Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.4, // Kategoriler için sabit bir yükseklik
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // Ekrana aynı anda kaç sütun sığacak
                    crossAxisSpacing: 8, // Kartlar arası yatay boşluk
                    mainAxisSpacing: 8, // Kartlar arası dikey boşluk
                    childAspectRatio: 1.8, // Kartların en-boy oranı
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = categories[index]['name'];
                        });
                      },
                      child: Card(
                        color: selectedCategory == categories[index]['name']
                            ? Colors.blue[100]
                            : Colors.white,
                        child: Center(
                          child: Text(
                            categories[index]['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // Okul Seçin kısmı
              Text('Okul Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedSchool,
                hint: Text('Okul Seçin'),
                isExpanded: true,
                items: schools.map((String school) {
                  return DropdownMenuItem<String>(
                    value: school,
                    child: Text(school),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSchool = newValue;
                  });
                },
              ),

              SizedBox(height: 20),

              // Arama butonu
              Center(
                child: ElevatedButton(
                  onPressed: searchStock,
                  child: Text('Arat'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Stok verileri
              if (stockData.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: stockData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stockData[index]['beden'],
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Adet: ${stockData[index]['adet']}'),
                            Text('Fiyat: ₺${double.parse(stockData[index]['fiyat'].toString()).toStringAsFixed(2)}'),
                            Text('Ürün Kodu: ${stockData[index]['ürün kodu']}'),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => updateStock(index),
                              child: Text('Güncelle'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );

  }
}

