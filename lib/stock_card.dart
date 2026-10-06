import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final String company;
  final String price;
  final String change;
  final bool isUp;

  const StockCard({
    super.key,
    required this.symbol,
    required this.company,
    required this.price,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.red;
    IconData arrow = Icons.arrow_drop_down;

    if (isUp) {
      textColor = Colors.green;
      arrow = Icons.arrow_drop_up;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    company,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(arrow, color: textColor, size: 18),
                    Text(
                      change,
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
