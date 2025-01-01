import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class WholesaleOrdersPage extends StatefulWidget {
  @override
  _WholesaleOrdersPageState createState() => _WholesaleOrdersPageState();
}

class _WholesaleOrdersPageState extends State<WholesaleOrdersPage> {
  String? selectedSchool;
  String? selectedCategory;
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  //aktif siparişler veritabanından map olarak gelcek
  List<Map<String, dynamic>> activeOrders = [
    {
      'id': '1',
      'school': 'Atatürk İlkokulu',
      'category': 'Tişört',
      'size': 'M',
      'quantity': 100,
      'orderDate': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'id': '2',
      'school': 'Cumhuriyet Ortaokulu',
      'category': 'Sweatshirt',
      'size': 'L',
      'quantity': 50,
      'orderDate': DateTime.now().subtract(Duration(days: 1)),
    },
  ];

  //okullar güncellenecek
  final List<String> schools = [
    'Atatürk İlkokulu',
    'Cumhuriyet Ortaokulu',
    'Fatih Lisesi',
    'Gazi Üniversitesi',
    'İnönü İlkokulu',
  ];

  final List<String> categories = [
    'Tişört',
    'Sweatshirt',
    'Pantolon',
    'Ceket',
    'Şort',
    'Şort Etek',
    'Selanik',
    'Eşofman Takımı',
    'Eşofman Tişörtü',
    'Eşofman Altı',
  ];

  void addOrder() {
    if (selectedSchool == null ||
        selectedCategory == null ||
        sizeController.text.isEmpty ||
        quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      activeOrders.add({
        'id': (activeOrders.length + 1).toString(),
        'school': selectedSchool!,
        'category': selectedCategory!,
        'size': sizeController.text,
        'quantity': int.parse(quantityController.text),
        'orderDate': DateTime.now(),
      });
    });

    // Clear form
    selectedSchool = null;
    selectedCategory = null;
    sizeController.clear();
    quantityController.clear();

    //siparişi veri tabanına kaydetme işlemi yapılacak

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sipariş başarıyla eklendi')),
    );
  }

  void receiveOrder(String orderId) {
    setState(() {
      activeOrders.removeWhere((order) => order['id'] == orderId);
    });
    // Here you would typically update your database

    //sipariş içeriği veritabanında stoğa eklenecek
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sipariş teslim alındı ve stoka eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toptancı Siparişleri'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yeni Sipariş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSchool,
                    decoration: InputDecoration(labelText: 'Okul'),
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
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'Kategori'),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sizeController,
                    decoration: InputDecoration(
                      labelText: 'Beden',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Adet',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: addOrder,
                child: Text('Sipariş Oluştur'),
              ),
            ),
            SizedBox(height: 20),
            Text('Aktif Siparişler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  final order = activeOrders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${order['school']} - ${order['category']}', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Beden: ${order['size']}, Adet: ${order['quantity']}'),
                          Text('Sipariş Tarihi: ${DateFormat('dd/MM/yyyy').format(order['orderDate'])}'),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => receiveOrder(order['id']),
                              child: Text('Teslim Alındı'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

