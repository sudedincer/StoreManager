import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;

class MyBarcodesPage extends StatefulWidget {
  @override
  _MyBarcodesPageState createState() => _MyBarcodesPageState();
}

class _MyBarcodesPageState extends State<MyBarcodesPage> {
  String? selectedSchool;
  String? selectedCategory;
  String? selectedSize;
  String? generatedBarcode;

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

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  void generateBarcode() {
    if (selectedSchool != null && selectedCategory != null && selectedSize != null) {
      setState(() {
        generatedBarcode = '${selectedSchool!.substring(0, 3).toUpperCase()}'
            '${selectedCategory!.substring(0, 3).toUpperCase()}'
            '${selectedSize!}'
            '${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
    }
  }

  Future<void> exportBarcode() async {
    if (generatedBarcode == null) return;

    final qrPainter = QrPainter(
      data: generatedBarcode!,
      version: QrVersions.auto,
      gapless: false,
    );

    final qrImage = await qrPainter.toImage(200);
    final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qrcode.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

     // await Share.shareFiles([filePath], text: 'Barkod: $generatedBarcode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barkodlarım'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
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
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
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
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSize,
              decoration: InputDecoration(labelText: 'Beden'),
              items: sizes.map((String size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSize = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: generateBarcode,
                child: Text('Barkod Oluştur'),
              ),
            ),
            SizedBox(height: 20),
            if (generatedBarcode != null) ...[
              Center(
                child: QrImageView(
                  data: generatedBarcode!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              SizedBox(height: 10),
              Center(child: Text('Barkod: $generatedBarcode')),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: exportBarcode,
                  child: Text('Barkodu Dışa Aktar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

