import 'package:flutter/material.dart';

class StockTrackingPage extends StatefulWidget {
  @override
  _StockTrackingPageState createState() => _StockTrackingPageState();
}

class _StockTrackingPageState extends State<StockTrackingPage> {
  List<String> selectedCategories = [];
  String? selectedSchool;
  List<Map<String, dynamic>> stockData = [];

  //buradaki iconlar değişecek
  final List<Map<String, dynamic>> categories = [
    {'name': 'Tişört', 'icon': Icons.accessibility_new},
    {'name': 'Sweatshirt', 'icon': Icons.accessibility},
    {'name': 'Pantolon', 'icon': Icons.pan_tool},
    {'name': 'Ceket', 'icon': Icons.wallet_travel},
    {'name': 'Şort', 'icon': Icons.sports_handball},
    {'name': 'Şort Etek', 'icon': Icons.straighten},
    {'name': 'Selanik', 'icon': Icons.texture},
    {'name': 'Eşofman Takımı', 'icon': Icons.sports_soccer},
    {'name': 'Eşofman Tişörtü', 'icon': Icons.sports_tennis},
    {'name': 'Eşofman Altı', 'icon': Icons.sports_basketball},
  ];

  final List<String> schools = List.generate(70, (index) => 'Okul ${index + 1}');

  void searchStock() {
    // Simulating API call or database query
    //veritavanından burada gerçek veriler gelecek
    setState(() {
      stockData = [
        {'size': 'S', 'quantity': 10, 'price': 29.99},
        {'size': 'M', 'quantity': 15, 'price': 29.99},
        {'size': 'L', 'quantity': 20, 'price': 34.99},
        {'size': 'XL', 'quantity': 5, 'price': 34.99},
      ];
    });
  }

  void updateStock(int index) {
    //güncelleme yapıldığında veritabanında da güncellenme sağlanmalı
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController quantityController = TextEditingController(text: stockData[index]['quantity'].toString());
        TextEditingController priceController = TextEditingController(text: stockData[index]['price'].toString());

        return AlertDialog(
          title: Text('Güncelle: ${stockData[index]['size']}'),
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
              onPressed: () {
                setState(() {
                  stockData[index]['quantity'] = int.parse(quantityController.text);
                  stockData[index]['price'] = double.parse(priceController.text);
                });
                Navigator.of(context).pop();
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
              Text('Kategori Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategories.contains(categories[index]['name'])) {
                          selectedCategories.remove(categories[index]['name']);
                        } else {
                          selectedCategories.add(categories[index]['name']);
                        }
                      });
                    },
                    child: Card(
                      color: selectedCategories.contains(categories[index]['name'])
                          ? Colors.blue[100]
                          : Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(categories[index]['icon'], size: 40),
                          Text(categories[index]['name'], textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
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
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
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
                              stockData[index]['size'],
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Adet: ${stockData[index]['quantity']}'),
                            Text('Fiyat: ₺${stockData[index]['price'].toStringAsFixed(2)}'),
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

