import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductCreatePage extends StatefulWidget {
  @override
  _ProductCreatePageState createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  String? selectedCategory;
  List<String> selectedSchools = [];
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController schoolSearchController = TextEditingController();
  String barcode = '';
  String productCode = '';

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
    {'name': 'Yeni Kategori', 'icon': Icons.add_circle},
  ];

//okullar girrilecek
  final List<String> schools = List.generate(70, (index) => 'Okul ${index + 1}');
  List<String> filteredSchools = [];

  @override
  void initState() {
    super.initState();
    filteredSchools = schools;
  }


  //buraya sistemdeki barkodu getirilecek
  void generateBarcode() {
    setState(() {
      barcode = 'BRCD${DateTime.now().millisecondsSinceEpoch}';
      productCode = 'PRD${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void filterSchools(String query) {
    setState(() {
      filteredSchools = schools.where((school) =>
          school.toLowerCase().contains(query.toLowerCase())
      ).toList();
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
              Text('Kategori Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              TextField(
                controller: schoolSearchController,
                decoration: InputDecoration(
                  labelText: 'Okul Ara',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterSchools,
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: filteredSchools.length,
                  itemBuilder: (context, index) {
                    final school = filteredSchools[index];
                    return CheckboxListTile(
                      title: Text(school),
                      value: selectedSchools.contains(school),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedSchools.add(school);
                          } else {
                            selectedSchools.remove(school);
                          }
                        });
                      },
                    );
                  },
                ),
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                        Text('Barkod: $barcode'),
                        Text('Ürün Kodu: $productCode'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Burada firebase'e kaydetme işlemi yapılacak
                  },
                  child: Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

