import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class RevenueTrackingPage extends StatelessWidget {

  //bunlar veritabanından gelicek
  final List<Map<String, dynamic>> dailySales = [
    {'category': 'Tişört', 'quantity': 15, 'revenue': 450.0},
    {'category': 'Pantolon', 'quantity': 10, 'revenue': 800.0},
    {'category': 'Sweatshirt', 'quantity': 8, 'revenue': 560.0},
    {'category': 'Ceket', 'quantity': 5, 'revenue': 750.0},
    {'category': 'Şort', 'quantity': 12, 'revenue': 360.0},
  ];

  //bunlar veritabanından gelicek
  final List<Map<String, dynamic>> weeklySales = [
    {'day': 'Pazartesi', 'revenue': 2500.0},
    {'day': 'Salı', 'revenue': 2200.0},
    {'day': 'Çarşamba', 'revenue': 2800.0},
    {'day': 'Perşembe', 'revenue': 2600.0},
    {'day': 'Cuma', 'revenue': 3000.0},
    {'day': 'Cumartesi', 'revenue': 3500.0},
    {'day': 'Pazar', 'revenue': 2900.0},
  ];

  @override
  Widget build(BuildContext context) {
    double totalDailyRevenue = dailySales.fold(0, (sum, item) => sum + item['revenue']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ciro Takibi'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
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
                            xValueMapper: (Map<String, dynamic> sales, _) => sales['day'].substring(0, 3),
                            yValueMapper: (Map<String, dynamic> sales, _) => sales['revenue'],
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

