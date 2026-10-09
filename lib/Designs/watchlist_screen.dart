import 'package:flutter/material.dart';
import 'stock_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TradePlus'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Text(
            'My Stocks (4)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          StockCard(
            symbol: 'RELIANCE',
            company: 'Reliance Industries Ltd.',
            price: '₹2,480.50',
            change: '+₹30.50 (+1.25%)',
            isUp: true,
          ),
          StockCard(
            symbol: 'TCS',
            company: 'Tata Consultancy Services Ltd.',
            price: '₹3,760.00',
            change: '-₹40.00 (-1.05%)',
            isUp: false,
          ),
          StockCard(
            symbol: 'INFY',
            company: 'Infosys Ltd.',
            price: '₹1,525.75',
            change: '+₹25.75 (+1.72%)',
            isUp: true,
          ),
          StockCard(
            symbol: 'HDFCBANK',
            company: 'HDFC Bank Ltd.',
            price: '₹1,610.20',
            change: '+₹10.20 (+0.64%)',
            isUp: true,
          ),
        ],
      ),
    );
  }
}
