import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:marketupdates/Constant/stocks.dart';

class StockQuote {
  final String symbol;
  final int ltpPaise;
  final int prevClosePaise;

  const StockQuote({
    required this.symbol,
    required this.ltpPaise,
    required this.prevClosePaise,
  });

  bool get isUp => ltpPaise >= prevClosePaise;

  StockQuote copyWith({int? ltpPaise}) {
    return StockQuote(
      symbol: symbol,
      ltpPaise: ltpPaise ?? this.ltpPaise,
      prevClosePaise: prevClosePaise,
    );
  }
}

/// One price source for the whole app.
/// Change [tickInterval] to make prices move faster or slower.
class MarketFeed {
  MarketFeed._();

  static final MarketFeed instance = MarketFeed._();
  static const Duration tickInterval = Duration(milliseconds: 500);

  final Map<String, ValueNotifier<StockQuote>> _quotes = {};
  final Random _random = Random();
  Timer? _timer;

  void start() {
    if (_timer != null) return;

    for (final stock in kStocks) {
      _quotes[stock.symbol] = ValueNotifier(
        StockQuote(
          symbol: stock.symbol,
          ltpPaise: stock.startPaise,
          prevClosePaise: stock.startPaise,
        ),
      );
    }

    _timer = Timer.periodic(tickInterval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  ValueNotifier<StockQuote> quoteOf(String symbol) {
    start();
    return _quotes[symbol]!;
  }

  void _tick() {
    final stock = kStocks[_random.nextInt(kStocks.length)];
    final notifier = _quotes[stock.symbol];
    if (notifier == null) return;

    final current = notifier.value;
    final step = _random.nextInt(40) + 5;
    final up = _random.nextBool();
    var next = up ? current.ltpPaise + step : current.ltpPaise - step;
    final minPrice = stock.startPaise ~/ 2;
    final maxPrice = stock.startPaise * 2;
    if (next < minPrice) next = minPrice;
    if (next > maxPrice) next = maxPrice;

    notifier.value = current.copyWith(ltpPaise: next);
  }
}
