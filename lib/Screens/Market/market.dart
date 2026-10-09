import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Services/market_feed.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Live Market'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: kStocks.length,
        itemBuilder: (context, index) {
          return MarketRow(symbol: kStocks[index].symbol);
        },
      ),
    );
  }
}

class MarketRow extends StatefulWidget {
  final String symbol;

  const MarketRow({super.key, required this.symbol});

  @override
  State<MarketRow> createState() => _MarketRowState();
}

class _MarketRowState extends State<MarketRow> {
  Color flash = Colors.transparent;
  int flashToken = 0;
  int lastPrice = 0;
  late ValueNotifier<StockQuote> quoteNotifier;

  @override
  void initState() {
    super.initState();
    quoteNotifier = MarketFeed.instance.quoteOf(widget.symbol);
    lastPrice = quoteNotifier.value.ltpPaise;
    quoteNotifier.addListener(onPriceChange);
  }

  // Green flash when the price goes up, red when it goes down.
  void onPriceChange() {
    StockQuote quote = quoteNotifier.value;
    bool movedUp = quote.ltpPaise >= lastPrice;
    lastPrice = quote.ltpPaise;

    int token = ++flashToken;
    setState(() {
      if (movedUp) {
        flash = const Color(0x3316A34A);
      } else {
        flash = const Color(0x33DC2626);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || token != flashToken) return;
      setState(() {
        flash = Colors.transparent;
      });
    });
  }

  @override
  void dispose() {
    quoteNotifier.removeListener(onPriceChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStock? stock = findStock(widget.symbol);
    StockQuote quote = quoteNotifier.value;
    Color color = const Color(0xFFDC2626);
    if (quote.isUp) {
      color = const Color(0xFF16A34A);
    }

    String stockName = '';
    if (stock != null) stockName = stock.name;

    return Card(
      color: Color.alphaBlend(flash, AppColors.card),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.symbol,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    stockName,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatInrPaise(quote.ltpPaise),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      quote.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: color,
                      size: 18,
                    ),
                    Text(
                      formatChangeLine(quote.ltpPaise, quote.prevClosePaise),
                      style: TextStyle(fontSize: 12, color: color),
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
