class AppStock {
  final String symbol;
  final String name;
  final int startPaise;

  const AppStock(this.symbol, this.name, this.startPaise);
}

const List<AppStock> kStocks = [
  AppStock('RELIANCE', 'Reliance Industries Ltd.', 248050),
  AppStock('TCS', 'Tata Consultancy Services Ltd.', 376000),
  AppStock('INFY', 'Infosys Ltd.', 152575),
  AppStock('HDFCBANK', 'HDFC Bank Ltd.', 161020),
  AppStock('ICICIBANK', 'ICICI Bank Ltd.', 124530),
  AppStock('SBIN', 'State Bank of India', 82040),
  AppStock('ITC', 'ITC Ltd.', 46515),
  AppStock('LT', 'Larsen & Toubro Ltd.', 352080),
  AppStock('BHARTIARTL', 'Bharti Airtel Ltd.', 168025),
  AppStock('AXISBANK', 'Axis Bank Ltd.', 112560),
];

AppStock? findStock(String symbol) {
  for (final stock in kStocks) {
    if (stock.symbol == symbol) return stock;
  }
  return null;
}

String formatInrPaise(int paise) {
  final negative = paise < 0;
  final value = paise.abs();
  final rupees = _groupIndian(value ~/ 100);
  final frac = (value % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}₹$rupees.$frac';
}

String formatChangeLine(int ltpPaise, int prevClosePaise) {
  final change = ltpPaise - prevClosePaise;
  final sign = change >= 0 ? '+' : '-';
  final amount = formatInrPaise(change.abs());
  final percent = _percentText(change.abs(), prevClosePaise);
  return '$sign$amount ($sign$percent%)';
}

String formatPnlLine(int pnlPaise, int investedPaise) {
  final sign = pnlPaise >= 0 ? '+' : '-';
  final amount = formatInrPaise(pnlPaise.abs());
  final percent = _percentText(pnlPaise.abs(), investedPaise);
  return '$sign$amount ($sign$percent%)';
}

String _groupIndian(int number) {
  final text = number.toString();
  if (text.length <= 3) return text;
  final last3 = text.substring(text.length - 3);
  var rest = text.substring(0, text.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

String _percentText(int changePaise, int prevClosePaise) {
  if (prevClosePaise == 0) return '0.00';
  final scaled = (changePaise * 10000 + (prevClosePaise ~/ 2)) ~/ prevClosePaise;
  final whole = scaled ~/ 100;
  final frac = (scaled % 100).toString().padLeft(2, '0');
  return '$whole.$frac';
}
