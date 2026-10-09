class OrderModel {
  final String id;
  final String symbol;
  final String side;
  final int qty;
  final int pricePaise;
  final int valuePaise;
  final int timeMs;

  OrderModel({
    required this.id,
    required this.symbol,
    required this.side,
    required this.qty,
    required this.pricePaise,
    required this.valuePaise,
    required this.timeMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'qty': qty,
      'pricePaise': pricePaise,
      'valuePaise': valuePaise,
      'timeMs': timeMs,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: (map['id'] ?? '').toString(),
      symbol: (map['symbol'] ?? '').toString(),
      side: (map['side'] ?? 'BUY').toString(),
      qty: _readInt(map['qty']),
      pricePaise: _readInt(map['pricePaise']),
      valuePaise: _readInt(map['valuePaise']),
      timeMs: _readInt(map['timeMs']),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String formatOrderTime(int timeMs) {
  DateTime time = DateTime.fromMillisecondsSinceEpoch(timeMs);
  String two(int number) {
    return number.toString().padLeft(2, '0');
  }

  String day = two(time.day);
  String month = two(time.month);
  String hour = two(time.hour);
  String minute = two(time.minute);
  return '$day/$month/${time.year}  $hour:$minute';
}
