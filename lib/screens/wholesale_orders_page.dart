import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WholesaleOrdersPage extends StatefulWidget {
  @override
  _WholesaleOrdersPageState createState() => _WholesaleOrdersPageState();
}

class _WholesaleOrdersPageState extends State<WholesaleOrdersPage> {
  String? selectedSchool;
  String? selectedCategory;
  String? selectedSize;
  final TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> activeOrders = [];
  Set<String> schoolSet = Set();
  Set<String> categorySet = Set();

  final List<String> schools = [];
  final List<String> categories = [];
  final List<String> sizes = [];
  Map<String, List<String>> schoolCategoriesMap = {}; // Okul -> Kategoriler Map'i

  @override
  void initState() {
    super.initState();
    fetchActiveOrders();
    fetchSchoolsAndCategories();
    quantityController.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchActiveOrders() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('siparisler').get();
      setState(() {
        activeOrders = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Siparişler alınırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> fetchSchoolsAndCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('ürünler').get();

      for (var doc in querySnapshot.docs) {
        String schoolName = doc['okul adı'];
        String category = doc['kategori'];

        schoolSet.add(schoolName);
        categorySet.add(category);

        if (!schoolCategoriesMap.containsKey(schoolName)) {
          schoolCategoriesMap[schoolName] = [];
        }
        if (!schoolCategoriesMap[schoolName]!.contains(category)) {
          schoolCategoriesMap[schoolName]!.add(category);
        }
      }

      setState(() {
        schools.addAll(schoolSet);
        if (selectedSchool != null) {
          categories.clear();
          categories.addAll(schoolCategoriesMap[selectedSchool] ?? []);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Okul ve kategori verileri alınırken bir hata oluştu: $e')),
      );
    }
  }

  void onSchoolChanged(String? newSchool) {
    setState(() {
      selectedSchool = newSchool;
      selectedCategory = null;
      selectedSize = null;
      categories.clear();
      sizes.clear();
      if (newSchool != null && schoolCategoriesMap.containsKey(newSchool)) {
        categories.addAll(schoolCategoriesMap[newSchool]!);
      }
    });
  }

  Future<void> fetchSizesForCategory(String? school, String? category) async {
    if (school == null || category == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: school)
          .where('kategori', isEqualTo: category)
          .get();

      Set<String> sizeSet = Set();
      for (var doc in querySnapshot.docs) {
        sizeSet.add(doc['beden']);
      }

      setState(() {
        sizes.clear();
        sizes.addAll(sizeSet);
        selectedSize = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beden verileri alınırken bir hata oluştu: $e')),
      );
    }
  }

  void onCategoryChanged(String? newCategory) {
    setState(() {
      selectedCategory = newCategory;
      selectedSize = null;
      sizes.clear();
    });

    if (selectedSchool != null && newCategory != null) {
      fetchSizesForCategory(selectedSchool, newCategory);
    }
  }

  Future<void> addOrder() async {
    if (selectedSchool == null ||
        selectedCategory == null ||
        selectedSize == null ||
        quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    var newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'okul adı': selectedSchool!,
      'kategori': selectedCategory!,
      'beden': selectedSize!,
      'adet': int.parse(quantityController.text),
      'orderDate': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('siparisler').add(newOrder);
      setState(() {
        activeOrders.add(newOrder);
      });

      selectedSchool = null;
      selectedCategory = null;
      selectedSize = null;
      quantityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş başarıyla eklendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş eklenirken bir hata oluştu: $e')),
      );
    }
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
                      return DropdownMenuItem<String>(value: school, child: Text(school));
                    }).toList(),
                    onChanged: onSchoolChanged,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'Kategori'),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
                    onChanged: selectedSchool != null ? onCategoryChanged : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSize,
                    decoration: InputDecoration(labelText: 'Beden'),
                    items: sizes.map((String size) {
                      return DropdownMenuItem<String>(value: size, child: Text(size));
                    }).toList(),
                    onChanged: selectedCategory != null
                        ? (String? newValue) {
                      setState(() {
                        selectedSize = newValue;
                      });
                    }
                        : null,
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
                    enabled: selectedSize != null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: (selectedSchool != null &&
                    selectedCategory != null &&
                    selectedSize != null &&
                    quantityController.text.isNotEmpty)
                    ? addOrder
                    : null,
                child: Text('Sipariş Oluştur'),
              ),
            ),
            SizedBox(height: 20),
            Text('Aktif Siparişler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  var order = activeOrders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${order['okul adı']} - ${order['kategori']}', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Beden: ${order['beden']}, Adet: ${order['adet']}'),
                          Text('Sipariş Tarihi: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order['orderDate']))}'),
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

  Future<void> receiveOrder(String orderId) async {
    try {
      var orderDoc = await FirebaseFirestore.instance
          .collection('siparisler')
          .where('id', isEqualTo: orderId)
          .limit(1)
          .get();

      if (orderDoc.docs.isNotEmpty) {
        var orderData = orderDoc.docs.first.data();
        await orderDoc.docs.first.reference.delete();
        setState(() {
          activeOrders.removeWhere((order) => order['id'] == orderId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş teslim alındı ve stoka eklendi')),
        );

        String okulAdi = orderData['okul adı'];
        String kategori = orderData['kategori'];
        String beden = orderData['beden'];
        int siparisAdet = orderData['adet'];

        var urunQuery = await FirebaseFirestore.instance
            .collection('ürünler')
            .where('okul adı', isEqualTo: okulAdi)
            .where('kategori', isEqualTo: kategori)
            .where('beden', isEqualTo: beden)
            .limit(1)
            .get();

        if (urunQuery.docs.isNotEmpty) {
          var urunDoc = urunQuery.docs.first;
          var mevcutAdet = urunDoc.data()['adet'] ?? 0;
          await urunDoc.reference.update({
            'adet': mevcutAdet + siparisAdet,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Eşleşen bir ürün bulunamadı')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş silinirken bir hata oluştu: $e')),
      );
    }
  }
}
