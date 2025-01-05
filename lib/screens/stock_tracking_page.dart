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
  Set<String> activeCategories = {};

  @override
  void initState() {
    super.initState();
    getSchools();
  }

  Future<void> getSchools() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ürünler').get();
      Set<String> uniqueSchools = {};
      for (var doc in snapshot.docs) {
        String schoolName = doc['okul adı'];
        uniqueSchools.add(schoolName);
      }
      setState(() {
        schools = uniqueSchools.toList();
        if(!schools.contains(selectedSchool)){
          selectedSchool = null;
        }
      });
    } catch (e) {
      print("Okul verileri alınırken hata oluştu: $e");
    }
  }

  Future<void> getActiveCategories() async {
    if (selectedSchool == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool)
          .get();

      Set<String> categoriesInSchool = {};
      for (var doc in snapshot.docs) {
        String category = doc['kategori'];
        categoriesInSchool.add(category);
      }

      setState(() {
        activeCategories = categoriesInSchool;
      });
    } catch (e) {
      print("Kategoriler alınırken hata oluştu: $e");
    }
  }

  void searchStock() async {
    if (selectedSchool == null || selectedCategory == null) {
      return;
    }

    try {
      setState(() {
        stockData = [];
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool)
          .where('kategori', isEqualTo: selectedCategory)
          .get();

      List<Map<String, dynamic>> fetchedStockData = [];
      for (var doc in snapshot.docs) {
        fetchedStockData.add({
          'beden': doc['beden'],
          'adet': doc['adet'],
          'fiyat': doc['fiyat'],
          'ürün kodu': doc['ürün kodu'],
        });
      }

      setState(() {
        stockData = fetchedStockData;
      });
    } catch (e) {
      print("Stok verileri alınırken hata oluştu: $e");
    }
  }

  void deleteStock(int index) async {
    try {
      String productCode = stockData[index]['ürün kodu'];

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('ürün kodu', isEqualTo: productCode)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        setState(() {
          stockData.removeAt(index);
        });
        print("Ürün başarıyla silindi.");
        await getSchools();
      } else {
        print("Silinecek ürün bulunamadı.");
      }
    } catch (e) {
      print("Ürün silinirken hata oluştu: $e");
    }
  }

  void updateStock(int index) async {
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
                String productCode = stockData[index]['ürün kodu'];
                try {
                  await FirebaseFirestore.instance
                      .collection('ürünler')
                      .where('ürün kodu', isEqualTo: productCode)
                      .get()
                      .then((querySnapshot) async {
                    if (querySnapshot.docs.isNotEmpty) {
                      var productDoc = querySnapshot.docs.first;
                      await productDoc.reference.update({
                        'adet': int.parse(quantityController.text),
                        'fiyat': priceController.text,
                      });
                      setState(() {
                        stockData[index]['adet'] = int.parse(quantityController.text);
                        stockData[index]['fiyat'] = double.parse(priceController.text);
                      });
                      Navigator.of(context).pop();
                    } else {
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
                    selectedCategory = null;
                    activeCategories.clear();
                  });
                  getActiveCategories();
                },
              ),

              SizedBox(height: 20),

              Text('Kategori Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String categoryName = categories[index]['name'];
                    bool isActive = activeCategories.contains(categoryName);
                    return GestureDetector(
                      onTap: isActive
                          ? () {
                        setState(() {
                          selectedCategory = categoryName;
                        });
                      }
                          : null,
                      child: Card(
                        color: selectedCategory == categoryName
                            ? Colors.blue[100]
                            : isActive
                            ? Colors.white
                            : Colors.grey[300],
                        child: Center(
                          child: Text(
                            categoryName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: isActive ? Colors.black : Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

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

              if (stockData.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.1,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => updateStock(index),
                                  child: Text('Güncelle'),
                                ),
                                ElevatedButton(
                                  onPressed: () => deleteStock(index),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text('Sil',style: TextStyle(color: Colors.white)),
                                ),
                              ],
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