import 'package:flutter/material.dart';
import 'stock_card.dart';

class MarketOverviewScreen extends StatelessWidget {
  const MarketOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Market'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Text(
            'Live Stream Active',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('Total ticks: 128'),
          SizedBox(height: 12),
          Text(
            'Top Gainer: INFY  +1.72%',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          Text(
            'Top Loser: TCS  -1.05%',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
          StockCard(
            symbol: 'ICICIBANK',
            company: 'ICICI Bank Ltd.',
            price: '₹1,012.40',
            change: '+₹12.40 (+1.24%)',
            isUp: true,
          ),
          StockCard(
            symbol: 'SBIN',
            company: 'State Bank of India',
            price: '₹742.10',
            change: '-₹7.90 (-1.05%)',
            isUp: false,
          ),
          StockCard(
            symbol: 'ITC',
            company: 'ITC Ltd.',
            price: '₹456.30',
            change: '+₹6.30 (+1.40%)',
            isUp: true,
          ),
          StockCard(
            symbol: 'LT',
            company: 'Larsen & Toubro Ltd.',
            price: '₹3,470.00',
            change: '-₹30.00 (-0.86%)',
            isUp: false,
          ),
          StockCard(
            symbol: 'BHARTIARTL',
            company: 'Bharti Airtel Ltd.',
            price: '₹1,218.00',
            change: '+₹18.00 (+1.50%)',
            isUp: true,
          ),
          StockCard(
            symbol: 'AXISBANK',
            company: 'Axis Bank Ltd.',
            price: '₹1,088.50',
            change: '-₹11.50 (-1.05%)',
            isUp: false,
          ),
        ],
      ),
    );
  }
}
