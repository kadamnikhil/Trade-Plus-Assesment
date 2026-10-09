class HoldingModel {
  final String symbol;
  final int qty;
  final int avgPaise;

  HoldingModel({
    required this.symbol,
    required this.qty,
    required this.avgPaise,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'qty': qty,
      'avgPaise': avgPaise,
    };
  }

  factory HoldingModel.fromMap(Map<String, dynamic> map) {
    return HoldingModel(
      symbol: (map['symbol'] ?? '').toString(),
      qty: _readInt(map['qty']),
      avgPaise: _readInt(map['avgPaise']),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
