import 'package:flutter/material.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holdings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Total Net Worth',
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            '₹5,59,000',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Invested: ₹58,500'),
          Text('Current Value: ₹59,000'),
          Text(
            'Total P&L: +₹500 (+0.85%)',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          Text('Available Cash: ₹5,00,000'),
          SizedBox(height: 20),
          Text(
            'Holdings (3)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text('RELIANCE  •  10 Qty'),
              subtitle: Text('Avg ₹2,450.00\nValue ₹25,000.00'),
              trailing: Text(
                '+₹500.00\n+2.04%',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('TCS  •  5 Qty'),
              subtitle: Text('Avg ₹3,800.00\nValue ₹18,500.00'),
              trailing: Text(
                '-₹500.00\n-2.63%',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('INFY  •  10 Qty'),
              subtitle: Text('Avg ₹1,500.00\nValue ₹15,500.00'),
              trailing: Text(
                '+₹500.00\n+3.33%',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
