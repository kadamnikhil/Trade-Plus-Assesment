import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/OrderModel.dart';
import 'package:marketupdates/Services/market_feed.dart';
import 'package:marketupdates/Services/portfolio.dart';

class TicketPage extends StatefulWidget {
  final String symbol;

  const TicketPage({super.key, required this.symbol});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TextEditingController qtyController = TextEditingController();
  late ValueNotifier<StockQuote> quoteNotifier;
  String side = 'BUY';
  String error = '';
  bool placing = false;

  @override
  void initState() {
    super.initState();
    quoteNotifier = MarketFeed.instance.quoteOf(widget.symbol);
    quoteNotifier.addListener(onPriceChange);
    qtyController.addListener(onQtyChange);
  }

  void onPriceChange() {
    if (!mounted) return;
    setState(() {});
  }

  void onQtyChange() {
    if (!mounted) return;
    setState(() {
      error = '';
    });
  }

  @override
  void dispose() {
    quoteNotifier.removeListener(onPriceChange);
    qtyController.removeListener(onQtyChange);
    qtyController.dispose();
    super.dispose();
  }

  int typedQty() {
    String text = qtyController.text.trim();
    int? qty = int.tryParse(text);
    if (qty == null || qty <= 0) return 0;
    return qty;
  }

  String? checkForm(int pricePaise) {
    String text = qtyController.text.trim();
    if (text.isEmpty) return 'Enter a quantity';
    if (text.contains('.') || text.contains(',')) {
      return 'Enter a whole number of shares';
    }

    int? qty = int.tryParse(text);
    if (qty == null || qty <= 0) {
      return 'Enter a quantity greater than 0';
    }

    if (side == 'SELL') {
      int held = Portfolio.instance.qtyOf(widget.symbol);
      if (qty > held) return 'You only hold $held shares';
      return null;
    }

    int valuePaise = qty * pricePaise;
    if (valuePaise > Portfolio.instance.balancePaise) {
      return 'Order value is more than your balance';
    }
    return null;
  }

  Future<void> placeOrder() async {
    if (placing) return;

    int pricePaise = quoteNotifier.value.ltpPaise;
    String? problem = checkForm(pricePaise);
    if (problem != null) {
      String message = problem;
      setState(() {
        error = message;
      });
      return;
    }

    int qty = int.parse(qtyController.text.trim());
    setState(() {
      placing = true;
    });

    String? failed;
    if (side == 'BUY') {
      failed = await Portfolio.instance.buy(widget.symbol, qty, pricePaise);
    } else {
      failed = await Portfolio.instance.sell(widget.symbol, qty, pricePaise);
    }

    if (!mounted) return;
    if (failed != null) {
      String message = failed;
      setState(() {
        placing = false;
        error = message;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDonePage(
          side: side,
          symbol: widget.symbol,
          qty: qty,
          pricePaise: pricePaise,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppStock? stock = findStock(widget.symbol);
    StockQuote quote = quoteNotifier.value;
    int qty = typedQty();
    int orderValue = qty * quote.ltpPaise;
    int held = Portfolio.instance.qtyOf(widget.symbol);

    String stockName = '';
    if (stock != null) stockName = stock.name;

    Color priceColor = const Color(0xFFDC2626);
    if (quote.isUp) priceColor = const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(widget.symbol),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            stockName,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          const Text('Last price'),
          Text(
            formatInrPaise(quote.ltpPaise),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: priceColor),
          ),
          const SizedBox(height: 12),
          Text('Balance ${formatInrPaise(Portfolio.instance.balancePaise)}'),
          Text('You hold $held shares'),
          const SizedBox(height: 20),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Buy'),
                selected: side == 'BUY',
                onSelected: (value) {
                  setState(() {
                    side = 'BUY';
                    error = '';
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Sell'),
                selected: side == 'SELL',
                onSelected: (value) {
                  setState(() {
                    side = 'SELL';
                    error = '';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: qtyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              labelText: 'Quantity',
              errorText: error.isEmpty ? null : error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order value ${formatInrPaise(orderValue)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: placing ? null : placeOrder,
            child: Text(placing ? 'Placing...' : (side == 'BUY' ? 'Buy' : 'Sell')),
          ),
        ],
      ),
    );
  }
}

class OrderDonePage extends StatelessWidget {
  final String side;
  final String symbol;
  final int qty;
  final int pricePaise;

  const OrderDonePage({
    super.key,
    required this.side,
    required this.symbol,
    required this.qty,
    required this.pricePaise,
  });

  @override
  Widget build(BuildContext context) {
    int valuePaise = qty * pricePaise;
    String title = 'Buy order placed';
    if (side == 'SELL') title = 'Sell order placed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('$symbol  •  $qty shares'),
            const SizedBox(height: 8),
            Text('Price ${formatInrPaise(pricePaise)}'),
            Text('Value ${formatInrPaise(valuePaise)}'),
            Text(formatOrderTime(DateTime.now().millisecondsSinceEpoch)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
