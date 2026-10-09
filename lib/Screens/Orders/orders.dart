import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/OrderModel.dart';
import 'package:marketupdates/Services/portfolio.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    List<OrderModel> orders = [];
    for (OrderModel order in Portfolio.instance.orders) {
      if (filter == 'ALL' || order.side == filter) {
        orders.add(order);
      }
    }

    String emptyText = 'No orders yet';
    if (filter == 'BUY') emptyText = 'No buy orders';
    if (filter == 'SELL') emptyText = 'No sell orders';

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Column(
        children: [
          filterChips(),
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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
          ),
        ],
      ),
    );
  }

  Widget filterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          filterChip('All', 'ALL'),
          const SizedBox(width: 8),
          filterChip('Buy', 'BUY'),
          const SizedBox(width: 8),
          filterChip('Sell', 'SELL'),
        ],
      ),
    );
  }

  Widget filterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == value,
      onSelected: (selected) {
        setState(() {
          filter = value;
        });
      },
    );
  }
}
