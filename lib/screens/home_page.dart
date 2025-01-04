import 'package:flutter/material.dart';
import 'package:semihgiyim/screens/barcode_create_page.dart';
import 'product_create_page.dart';
import 'stock_tracking_page.dart';
import 'sales_return_page.dart';
import 'wholesale_orders_page.dart';
import 'revenue_tracking_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Semih Giyim',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800]),
                ),
                SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.5,
                    children: <Widget>[
                      _buildMenuCard(context, 'Satış / İade',
                          Icons.shopping_cart, Colors.green, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SalesReturnPage()),
                        );
                      }),
                      _buildMenuCard(context, 'Toptancı Siparişleri',
                          Icons.local_shipping, Colors.orange, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WholesaleOrdersPage()),
                        );
                      }),
                      _buildMenuCard(
                          context, 'Stok Takibi', Icons.inventory, Colors.blue,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StockTrackingPage()),
                        );
                      }),
                      _buildMenuCard(context, 'Yeni Ürün Ekleme',
                          Icons.add_circle, Colors.purple, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductCreatePage()),
                        );
                      }),
                      _buildMenuCard(
                          context, 'Ciro Takibi', Icons.bar_chart, Colors.red,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenueTrackingPage()),
                        );
                      }),
                      _buildMenuCard(
                          context, 'Barkod Oluştur', Icons.qr_code_2, Colors.teal, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BarcodeCreationPage()),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 72.0,
                color: Colors.white,
              ),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
