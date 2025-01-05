import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RevenueTrackingPage extends StatefulWidget {
  @override
  _RevenueTrackingPageState createState() => _RevenueTrackingPageState();
}

class _RevenueTrackingPageState extends State<RevenueTrackingPage> {
  List<Map<String, dynamic>> dailySales = [];
  List<Map<String, dynamic>> weeklySales = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      // Günlük satışlar
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String currentWeek = DateFormat('w').format(DateTime.now()); // Haftanın numarasını alıyoruz
      List<String> daysOfWeek = ['Mon', 'Thu', 'Wed', 'Tue', 'Fri', 'Sat', 'Sun'];

      QuerySnapshot dailySnapshot = await FirebaseFirestore.instance
          .collection('satışlar')
          .doc(currentDate)
          .collection('kategoriler')
          .get();

      List<Map<String, dynamic>> fetchedDailySales = dailySnapshot.docs.map((doc) {
        return {
          'category': doc.id,
          'quantity': doc['sales'],
          'revenue': doc['price']*doc['sales'],
        };
      }).toList();

      // Haftalık satışlar

      QuerySnapshot<Map<String, dynamic>> weeklySnapshot = await FirebaseFirestore.instance
          .collection('haftalık satışlar')
          .doc('haftalar')
          .collection(currentWeek)
          .get();

      List<Map<String, dynamic>> fetchedWeeklySales = weeklySnapshot.docs.map((doc) {
        return {
          'day':doc.id,
          'revenue': doc['totalAmount'],
        };
      }).toList();

      // Gün sırasına göre veriyi sıralıyoruz
      fetchedWeeklySales.sort((a, b) {
        int dayA = daysOfWeek.indexOf(a['day']);
        int dayB = daysOfWeek.indexOf(b['day']);
        return dayA.compareTo(dayB);
      });

      setState(() {
        dailySales = fetchedDailySales;
        weeklySales = fetchedWeeklySales;
        isLoading = false;
        print(weeklySales);
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalDailyRevenue = dailySales.fold(0, (sum, item) => sum + item['revenue']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ciro Takibi'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Günlük Satışlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dailySales.length,
                  itemBuilder: (context, index) {
                    final sale = dailySales[index];
                    return Card(
                      child: Container(
                        width: 150,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sale['category'], style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text('Adet: ${sale['quantity']}'),
                            Text('Ciro: ₺${sale['revenue'].toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Toplam Günlük Ciro: ₺${totalDailyRevenue.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text('Haftalık Satışlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Kategoriler'),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Adet'),
                        ),
                        series: <ChartSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: dailySales,
                            xValueMapper: (Map<String, dynamic> sales, _) => sales['category'],
                            yValueMapper: (Map<String, dynamic> sales, _) => sales['quantity'],
                            name: 'Satış Adedi',
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Günler'),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Ciro (₺)'),
                          numberFormat: NumberFormat.currency(
                            locale: 'tr_TR',
                            symbol: '₺',
                            decimalDigits: 0,
                          ),
                        ),
                        series: <ChartSeries>[
                          LineSeries<Map<String, dynamic>, String>(
                            dataSource: weeklySales,
                            xValueMapper: (Map<String, dynamic> sales, _) =>  sales['day'], // Günler
                            yValueMapper: (Map<String, dynamic> sales, _) => sales['revenue'], // Ciro
                            name: 'Günlük Ciro',
                            color: Colors.red,
                            markerSettings: MarkerSettings(isVisible: true),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
