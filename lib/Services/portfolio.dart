import 'dart:convert';

import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/HoldingModel.dart';
import 'package:marketupdates/Model/OrderModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved wallet, holdings, and orders. Prices stay in paise (₹1 = 100 paise).
class Portfolio {
  Portfolio._();

  static final Portfolio instance = Portfolio._();
  static const int startingBalancePaise = 50000000;

  int balancePaise = startingBalancePaise;
  List<HoldingModel> holdings = [];
  List<OrderModel> orders = [];

  int qtyOf(String symbol) {
    for (HoldingModel item in holdings) {
      if (item.symbol == symbol) return item.qty;
    }
    return 0;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('walletBalancePaise')) {
        balancePaise = startingBalancePaise;
        holdings = [];
        orders = [];
        await save();
        return;
      }

      balancePaise = prefs.getInt('walletBalancePaise') ?? startingBalancePaise;
      holdings = _readHoldings(prefs.getString('holdings') ?? '');
      orders = _readOrders(prefs.getString('orders') ?? '');
    } catch (_) {
      balancePaise = startingBalancePaise;
      holdings = [];
      orders = [];
    }
  }

  Future<String?> buy(String symbol, int qty, int pricePaise) async {
    if (findStock(symbol) == null) return 'Unknown stock';
    if (qty <= 0) return 'Enter a quantity greater than 0';

    int valuePaise = qty * pricePaise;
    if (valuePaise > balancePaise) {
      return 'Not enough balance';
    }

    List<HoldingModel> next = [];
    bool found = false;
    for (HoldingModel item in holdings) {
      if (item.symbol != symbol) {
        next.add(item);
        continue;
      }

      found = true;
      int newQty = item.qty + qty;
      int cost = (item.qty * item.avgPaise) + valuePaise;
      int avgPaise = cost ~/ newQty;
      next.add(HoldingModel(symbol: symbol, qty: newQty, avgPaise: avgPaise));
    }

    if (!found) {
      next.add(HoldingModel(symbol: symbol, qty: qty, avgPaise: pricePaise));
    }

    holdings = next;
    balancePaise = balancePaise - valuePaise;
    _addOrder('BUY', symbol, qty, pricePaise, valuePaise);
    await save();
    return null;
  }

  Future<String?> sell(String symbol, int qty, int pricePaise) async {
    if (findStock(symbol) == null) return 'Unknown stock';
    if (qty <= 0) return 'Enter a quantity greater than 0';

    int held = qtyOf(symbol);
    if (qty > held) {
      return 'You only hold $held shares';
    }

    List<HoldingModel> next = [];
    for (HoldingModel item in holdings) {
      if (item.symbol != symbol) {
        next.add(item);
      } else if (item.qty > qty) {
        next.add(
          HoldingModel(
            symbol: symbol,
            qty: item.qty - qty,
            avgPaise: item.avgPaise,
          ),
        );
      }
    }

    holdings = next;
    int valuePaise = qty * pricePaise;
    _addOrder('SELL', symbol, qty, pricePaise, valuePaise);
    await save();
    return null;
  }

  void _addOrder(String side, String symbol, int qty, int pricePaise, int valuePaise) {
    orders.insert(
      0,
      OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        side: side,
        qty: qty,
        pricePaise: pricePaise,
        valuePaise: valuePaise,
        timeMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> holdingMaps = [];
      for (HoldingModel item in holdings) {
        holdingMaps.add(item.toMap());
      }

      List<Map<String, dynamic>> orderMaps = [];
      for (OrderModel item in orders) {
        orderMaps.add(item.toMap());
      }

      await prefs.setInt('walletBalancePaise', balancePaise);
      await prefs.setString('holdings', jsonEncode(holdingMaps));
      await prefs.setString('orders', jsonEncode(orderMaps));
    } catch (_) {}
  }

  List<HoldingModel> _readHoldings(String raw) {
    if (raw.isEmpty) return [];
    var data = jsonDecode(raw);
    if (data is! List) return [];

    List<HoldingModel> list = [];
    for (var item in data) {
      if (item is! Map) continue;
      HoldingModel holding = HoldingModel.fromMap(Map<String, dynamic>.from(item));
      if (findStock(holding.symbol) == null) continue;
      if (holding.qty <= 0) continue;
      list.add(holding);
    }
    return list;
  }

  List<OrderModel> _readOrders(String raw) {
    if (raw.isEmpty) return [];
    var data = jsonDecode(raw);
    if (data is! List) return [];

    List<OrderModel> list = [];
    for (var item in data) {
      if (item is! Map) continue;
      OrderModel order = OrderModel.fromMap(Map<String, dynamic>.from(item));
      if (order.symbol.isEmpty || order.qty <= 0) continue;
      list.add(order);
    }
    return list;
  }
}
