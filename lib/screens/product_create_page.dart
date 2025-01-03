import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCreatePage extends StatefulWidget {
  @override
  _ProductCreatePageState createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  String? selectedCategory;
  String? selectedSchool;
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController schoolSearchController = TextEditingController();
  TextEditingController productCodeController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> categories = [
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
    {'name': 'Yeni Kategori'},
  ];

//okullar girrilecek
  final List<String> schools =
      List.generate(70, (index) => 'Okul ${index + 1}');
  List<String> filteredSchools = [];

  @override
  void initState() {
    super.initState();
    filteredSchools = schools;
  }

  //buraya sistemdeki barkodu getirilecek
  void generateBarcode() {
    setState(() {
      productCodeController.text = 'PRD${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void filterSchools(String query) {
    setState(() {
      filteredSchools = schools
          .where((school) => school.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Ürün Oluştur'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori Seçin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(categories[index]['name'],
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              SizedBox(height: 10),
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
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Fiyat',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: generateBarcode,
                    child: Text('Barkod Üret'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //burası da değişebilir gelen barkoda göre
                      children: [
                        Text("Ürün Kodu: ${productCodeController.text}")
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Firebase'e kaydetme işlemi
                    FirebaseFirestore.instance.collection('ürünler').add({
                      'okul adı': selectedSchool,
                      'kategori': selectedCategory,
                      'beden': sizeController.text, // Beden bilgisi
                      'adet': quantityController.text, // Adet bilgisi
                      'fiyat': priceController.text, // Fiyat bilgisi
                      'ürün kodu': productCodeController.text,
                    }).then((_) {
                      // Başarılı olursa
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Başarılı'),
                            content: Text('Veri başarıyla kaydedildi!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Tamam'),
                              ),
                            ],
                          );
                        },
                      );
                      // Giriş alanlarını sıfırla
                      setState(() {
                        sizeController.clear();
                        quantityController.clear();
                        priceController.clear();
                        productCodeController.clear();
                        selectedSchool=null;
                        selectedCategory=null;
                      });

                    }).catchError((error) {
                      // Hata olursa
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Hata'),
                            content: Text(
                                'Veri kaydedilirken bir hata oluştu: $error'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Tamam'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                  child: Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
