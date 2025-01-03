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
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> activeOrders = [];

  final List<String> schools = [
    '19 Mayıs Ortaokulu',
    '7 Eylül Ortaokulu',
    'Akçapınar İsmail Türk İlkokulu',
    'Akçapınar İsmail Türk Ortaokulu',
    'Arif Canpoyraz İlkokulu',
    'Atatürk İlkokulu',
    'Avşar Ortaokulu',
    'Besime Elagöz Anadolu Lisesi',
    'Cahit Gönlübol Mesleki Ve Teknik Anadolu Lisesi',
    'Çampınar İlkokulu',
    'Çatalköprü İlkokulu',
    'Çatalköprü Ortaokulu',
    'Çepni Bektaş İlkokulu',
    'Çıkrıkçı Yaşar Kazimet Aybars İlkokulu',
    'Çıkrıkçı Yaşar Kazimet Aybars Ortaokulu',
    'Cumhuriyet Anaokulu',
    'Cumhuriyet İlkokulu',
    'Dağmarmara Niyazi Üzmez İlkokulu',
    'Dağmarmara Niyazi Üzmez Ortaokulu',
    'Dalbahce İlkokulu',
    'Dr. Hüseyin Orhan İlkokulu',
    'Firdevs Gürel Özel Eğitim İş Uygulama Merkezi (Okulu)',
    'Firdevs Gürel Özel Eğitim Uygulama Merkezi I. Kademe',
    'Firdevs Gürel Özel Eğitim Uygulama Merkezi II. Kademe',
    'Gazi Ortaokulu',
    'Hacı Mukaddes Ahmet Altan Ortaokulu',
    'Hacı Mukaddes-Ahmet Altan İlkokulu',
    'Halil Kale Fen Lisesi',
    'Halk Eğitim Merkezi',
    'Hasan Ferdi Turgutlu Mesleki ve Teknik Anadolu Lisesi',
    'Hasan Ferdi Turgutlu Ortaokulu',
    'Hasan Üzmez Ortaokulu',
    'Hilmi Pekcan İlkokulu',
    'İhsan Erturgut İlkokulu',
    'İhsan Erturgut Ortaokulu',
    'İlçe Milli Eğitim Müdürlüğü',
    'İnci Üzmez Mesleki ve Teknik Anadolu Lisesi',
    'Irlamaz Refik Pınar İlkokulu',
    'Irlamaz Refik Pınar Ortaokulu',
    'İzzettin 75. Yıl Ortaokulu',
    'İzzettin 75. Yıl İlkokulu',
    'Kabaçınar İlkokulu',
    'Kamil Semizler İlkokulu',
    'Mehmet Akif Ersoy Ortaokulu',
    'Mehmet Altan Anaokulu',
    'Mehmet Gürel İlkokulu',
    'Mesleki Eğitim Merkezi',
    'Musacalı İlkokulu',
    'Musacalı Ortaokulu',
    'Namık Kemal İlkokulu',
    'Niyazi Üzmez Anadolu Lisesi',
    'Niyazi Üzmez İlkokulu',
    'Niyazi Üzmez İmam Hatip Ortaokulu',
    'Ören İlkokulu',
    'Orhan Polat Yağcı İlkokulu',
    'Rotary İlkokulu',
    'Sabiha Erturgut İlkokulu',
    'Sabiha Erturgut Ortaokulu',
    'Şadi Turgutlu Ortaokulu',
    'Samiye- Nuri Sevil İlkokulu',
    'Samiye-Nuri Sevil Ortaokulu',
    'Sarıbey Dr. Hüseyin Orhan İlkokulu',
    'Şehit Abdullah Tayyip Olçak Ortaokulu',
    'Şehit Sevda Güngör Anaokulu',
    'Şehit Suat Akıncı Kız Anadolu İmam Hatip Lisesi',
    'Senem Aka Anadolu Lisesi',
    'TEV-Cemile ve Samiye Bayar İlkokulu',
    'TOKİ-Şehit Komando Onbaşı Ömer Balkan İlkokulu',
    'TOKİ-Şehit Komando Onbaşı Ömer Balkan Ortaokulu',
    'Turgutlu Anadolu İmam Hatip Lisesi',
    'Turgutlu Anadolu Lisesi',
    'Turgutlu Anaokulu',
    'Turgutlu Bilim ve Sanat Merkezi',
    'Turgutlu İmam Hatip Ortaokulu',
    'Turgutlu Lisesi',
    'Turgutlu Mesleki ve Teknik Anadolu Lisesi',
    'Turgutlu Öğretmenevi ve Akşam Sanat Okulu',
    'Turgutlu Selman Işılak Mesleki ve Teknik Anadolu Lisesi',
    'Urganlı 23 Nisan Ortaokulu',
    'Urganlı Atatürk İlkokulu',
    'Urganlı Besime Işıldak İlkokulu',
    'Urganlı Çok Programlı Anadolu Lisesi',
    'Urganlı İmam Hatip Ortaokulu',
    'Vicdan Necati Parıldar İlkokulu',
    'Yarbay Fevzi Elagöz Anaokulu',
    'Zübeyde Hanım Mesleki ve Teknik Anadolu Lisesi',
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

  @override
  void initState() {
    super.initState();
    fetchActiveOrders();
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

  Future<void> addOrder() async {
    if (selectedSchool == null ||
        selectedCategory == null ||
        sizeController.text.isEmpty ||
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
      'beden': sizeController.text,
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
      sizeController.clear();
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

  Future<void> receiveOrder(String orderId) async {
    try {
      // Siparişi getir
      var orderDoc = await FirebaseFirestore.instance
          .collection('siparisler')
          .where('id', isEqualTo: orderId)
          .limit(1)
          .get();

      if (orderDoc.docs.isNotEmpty) {
        var orderData = orderDoc.docs.first.data();

        // Siparişi sil
        await orderDoc.docs.first.reference.delete();
        setState(() {
          activeOrders.removeWhere((order) => order['id'] == orderId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş teslim alındı ve stoka eklendi')),
        );

        // Siparişin detaylarını al
         String okulAdi = orderData['okul adı'];
         String kategori = orderData['kategori'];
         String beden = orderData['beden'];
         int siparisAdet = orderData['adet'];

         print("siparis adet: $siparisAdet");

        // Ürünler koleksiyonunu güncelle
        var urunQuery = await FirebaseFirestore.instance
            .collection('ürünler')
            .where('okul adı', isEqualTo: okulAdi)
            .where('kategori', isEqualTo: kategori)
            .where('beden', isEqualTo: beden)
            .limit(1)
            .get();

        print("ürünler koleksiyonundan gelen ürün boş mu ?");
        print(urunQuery.docs.isEmpty);

        if (urunQuery.docs.isNotEmpty) {
          var urunDoc = urunQuery.docs.first;
          var mevcutAdet = urunDoc.data()['adet'] ?? 0;

          print("mevcut adet: $mevcutAdet");

          // Yeni adet miktarını hesapla ve güncelle
          await urunDoc.reference.update({
            'adet': mevcutAdet + siparisAdet,
          });
        } else {
          // Eğer eşleşen ürün yoksa kullanıcıyı bilgilendir
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
}
