import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(
            child: ListTile(
              leading: Text(
                'BUY',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              title: Text('RELIANCE'),
              subtitle: Text('10 shares\n06 Oct 2026, 10:15 AM'),
              trailing: Text('₹24,500.00\n@ ₹2,450.00'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text(
                'SELL',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              title: Text('ITC'),
              subtitle: Text('5 shares\n05 Oct 2026, 03:40 PM'),
              trailing: Text('₹2,250.00\n@ ₹450.00'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text(
                'BUY',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              title: Text('INFY'),
              subtitle: Text('10 shares\n04 Oct 2026, 11:05 AM'),
              trailing: Text('₹15,000.00\n@ ₹1,500.00'),
            ),
          ),
        ],
      ),
    );
  }
}
