import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class BarcodeCreationPage extends StatefulWidget {
  @override
  _BarcodeCreationPageState createState() => _BarcodeCreationPageState();
}

class _BarcodeCreationPageState extends State<BarcodeCreationPage> {

  final ScreenshotController screenshotController = ScreenshotController();

  String? selectedSchool;
  String? selectedCategory;
  String? selectedSize;
  String? barcode;

  final List<String> schools = [];
  final List<String> categories = [];
  final List<String> sizes = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('ürünler').get();
      final Set<String> schoolSet = {};

      for (var doc in querySnapshot.docs) {
        schoolSet.add(doc['okul adı']);
      }

      setState(() {
        schools.addAll(schoolSet);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Okullar alınırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> fetchCategories() async {
    if (selectedSchool == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool)
          .get();
      final Set<String> categorySet = {};

      for (var doc in querySnapshot.docs) {
        categorySet.add(doc['kategori']);
      }

      setState(() {
        categories.clear();
        categories.addAll(categorySet);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategoriler alınırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> fetchSizes() async {
    if (selectedSchool == null || selectedCategory == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool)
          .where('kategori', isEqualTo: selectedCategory)
          .get();
      final Set<String> sizeSet = {};

      for (var doc in querySnapshot.docs) {
        sizeSet.add(doc['beden']);
      }

      setState(() {
        sizes.clear();
        sizes.addAll(sizeSet);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bedenler alınırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> searchBarcode() async {
    if (selectedSchool == null ||
        selectedCategory == null ||
        selectedSize == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('ürünler')
          .where('okul adı', isEqualTo: selectedSchool)
          .where('kategori', isEqualTo: selectedCategory)
          .where('beden', isEqualTo: selectedSize)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          barcode = querySnapshot.docs.first['ürün kodu'];
        });
      } else {
        setState(() {
          barcode = 'Ürün bulunamadı.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barkod aranırken bir hata oluştu: $e')),
      );
    }
  }
  Future<void> _captureAndSaveBarcode() async {
    try {
      // Barkod widget'ının ekran görüntüsünü al
      final Uint8List? image = await screenshotController.capture();

      if (image == null) {
        throw Exception('Screenshot alınamadı');
      }

      // Downloads klasörünü al
      final Directory? downloadsDir = await getDownloadsDirectory();

      if (downloadsDir == null) {
        throw Exception('Downloads klasörü bulunamadı');
      }

      // Dosya adını oluştur
      final String fileName = '${selectedSchool}_${selectedCategory}_${selectedSize}.png'
          .replaceAll(' ', '_') // Boşlukları alt çizgi ile değiştir
          .replaceAll(RegExp(r'[^\w\s\-\_\.]'), ''); // Özel karakterleri temizle

      // Tam dosya yolunu oluştur
      final String filePath = '${downloadsDir.path}${Platform.pathSeparator}$fileName';

      // Dosyayı kaydet
      final File imageFile = File(filePath);
      await imageFile.writeAsBytes(image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barkod başarıyla kaydedildi: $filePath'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Klasörü Aç',
            onPressed: () async {
              if (Platform.isWindows) {
                await Process.run('explorer.exe', ['/select,', filePath]);
              } else if (Platform.isMacOS) {
                await Process.run('open', ['-R', filePath]);
              } else if (Platform.isLinux) {
                await Process.run('xdg-open', [downloadsDir.path]);
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barkod kaydedilirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Barkod Oluştur"),
      ),
      body: Center( // Center widget'ı ekledik
        child: Container(
          constraints: BoxConstraints(maxWidth: 800), // Maksimum genişlik sınırı
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSchool,
                  decoration: InputDecoration(
                    labelText: 'Okul Adı',
                    border: OutlineInputBorder(),
                  ),
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
                      selectedSize = null;
                      barcode = null;
                      categories.clear();
                      sizes.clear();
                    });
                    fetchCategories();
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategoriler',
                    border: OutlineInputBorder(),
                  ),
                  items: selectedSchool != null
                      ? categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList()
                      : [],
                  onChanged: selectedSchool != null
                      ? (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      selectedSize = null;
                      barcode = null;
                      sizes.clear();
                    });
                    fetchSizes();
                  }
                      : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSize,
                  decoration: InputDecoration(
                    labelText: 'Beden',
                    border: OutlineInputBorder(),
                  ),
                  items: selectedCategory != null
                      ? sizes.map((String size) {
                    return DropdownMenuItem<String>(
                      value: size,
                      child: Text(size),
                    );
                  }).toList()
                      : [],
                  onChanged: selectedCategory != null
                      ? (String? newValue) {
                    setState(() {
                      selectedSize = newValue;
                      barcode = null;
                    });
                  }
                      : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (selectedSchool != null &&
                      selectedCategory != null &&
                      selectedSize != null)
                      ? searchBarcode
                      : null,
                  child: Text("Barkod Oluştur"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250, 50),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                SizedBox(height: 30),
                if (barcode != null && barcode != 'Ürün bulunamadı.')
                  Center(
                    child: SizedBox(
                      width: 500,
                      height: 300,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Screenshot(
                            controller: screenshotController,
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BarcodeWidget(
                                    barcode: Barcode.code128(),
                                    data: barcode!,
                                    width: 300,
                                    height: 100,
                                    drawText: true,
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                if (barcode != null && barcode != 'Ürün bulunamadı.')
                  ElevatedButton(
                    onPressed: _captureAndSaveBarcode,
                    child: Text("Barkodu dışa aktar"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 50),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}