import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/OrderModel.dart';
import 'package:marketupdates/Services/portfolio.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<OrderModel> orders = Portfolio.instance.orders;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                OrderModel order = orders[index];
                Color sideColor = const Color(0xFFDC2626);
                if (order.side == 'BUY') sideColor = const Color(0xFF16A34A);

                return Card(
                  child: ListTile(
                    leading: Text(
                      order.side,
                      style: TextStyle(color: sideColor, fontWeight: FontWeight.bold),
                    ),
                    title: Text(order.symbol),
                    subtitle: Text('${order.qty} shares\n${formatOrderTime(order.timeMs)}'),
                    trailing: Text(
                      '${formatInrPaise(order.valuePaise)}\n@ ${formatInrPaise(order.pricePaise)}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
