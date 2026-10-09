import 'package:flutter/material.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/HoldingModel.dart';
import 'package:marketupdates/Screens/Ticket/ticket.dart';
import 'package:marketupdates/Services/market_feed.dart';
import 'package:marketupdates/Services/portfolio.dart';

class HoldingsPage extends StatefulWidget {
  const HoldingsPage({super.key});

  @override
  State<HoldingsPage> createState() => _HoldingsPageState();
}

class _HoldingsPageState extends State<HoldingsPage> {
  String sort = 'pnl';

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<HoldingModel> holdings = Portfolio.instance.holdings;
    String holdingsKey = holdingsSignature();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Holdings')),
      body: Column(
        children: [
          HoldingsSummary(holdingsKey: holdingsKey),
          if (holdings.isNotEmpty) sortChips(),
          Expanded(
            child: holdings.isEmpty
                ? const Center(
                    child: Text(
                      'No holdings yet',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : HoldingsList(
                    key: ValueKey(holdingsKey),
                    sort: sort,
                    onChanged: refresh,
                  ),
          ),
        ],
      ),
    );
  }

  Widget sortChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('P&L'),
            selected: sort == 'pnl',
            onSelected: (value) {
              setState(() {
                sort = 'pnl';
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Symbol'),
            selected: sort == 'symbol',
            onSelected: (value) {
              setState(() {
                sort = 'symbol';
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Value'),
            selected: sort == 'value',
            onSelected: (value) {
              setState(() {
                sort = 'value';
              });
            },
          ),
        ],
      ),
    );
  }
}

class HoldingsSummary extends StatefulWidget {
  final String holdingsKey;

  const HoldingsSummary({super.key, required this.holdingsKey});

  @override
  State<HoldingsSummary> createState() => _HoldingsSummaryState();
}

class _HoldingsSummaryState extends State<HoldingsSummary> {
  List<ValueNotifier<StockQuote>> notifiers = [];

  @override
  void initState() {
    super.initState();
    listen();
  }

  @override
  void didUpdateWidget(covariant HoldingsSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdingsKey == widget.holdingsKey) return;
    unlisten();
    listen();
  }

  void listen() {
    for (HoldingModel item in Portfolio.instance.holdings) {
      ValueNotifier<StockQuote> notifier = MarketFeed.instance.quoteOf(
        item.symbol,
      );
      notifier.addListener(onTick);
      notifiers.add(notifier);
    }
  }

  void unlisten() {
    for (ValueNotifier<StockQuote> notifier in notifiers) {
      notifier.removeListener(onTick);
    }
    notifiers.clear();
  }

  void onTick() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    unlisten();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int invested = 0;
    int current = 0;

    for (HoldingModel item in Portfolio.instance.holdings) {
      int ltp = MarketFeed.instance.quoteOf(item.symbol).value.ltpPaise;
      invested = invested + (item.qty * item.avgPaise);
      current = current + (item.qty * ltp);
    }

    int pnl = current - invested;
    Color color = const Color(0xFFDC2626);
    if (pnl >= 0) color = const Color(0xFF16A34A);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldDim),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total P&L',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatPnlLine(pnl, invested),
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.line),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: summaryItem('Invested', formatInrPaise(invested)),
                ),
                Expanded(
                  child: summaryItem('Current value', formatInrPaise(current)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class HoldingsList extends StatefulWidget {
  final String sort;
  final VoidCallback onChanged;

  const HoldingsList({super.key, required this.sort, required this.onChanged});

  @override
  State<HoldingsList> createState() => _HoldingsListState();
}

class _HoldingsListState extends State<HoldingsList> {
  List<ValueNotifier<StockQuote>> notifiers = [];
  List<String> order = [];

  @override
  void initState() {
    super.initState();
    listen();
  }

  @override
  void didUpdateWidget(covariant HoldingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sort == widget.sort) return;
    order = sortedSymbols();
  }

  void listen() {
    for (HoldingModel item in Portfolio.instance.holdings) {
      ValueNotifier<StockQuote> notifier = MarketFeed.instance.quoteOf(
        item.symbol,
      );
      notifier.addListener(onTick);
      notifiers.add(notifier);
    }
    order = sortedSymbols();
  }

  void unlisten() {
    for (ValueNotifier<StockQuote> notifier in notifiers) {
      notifier.removeListener(onTick);
    }
    notifiers.clear();
  }

  // Move rows only when one stock passes another. The row itself updates its price.
  void onTick() {
    List<String> next = sortedSymbols();
    if (sameSymbols(order, next)) return;
    if (!mounted) return;
    setState(() {
      order = next;
    });
  }

  List<String> sortedSymbols() {
    List<HoldingModel> list = [];
    for (HoldingModel item in Portfolio.instance.holdings) {
      list.add(item);
    }

    list.sort((a, b) {
      int result = 0;
      if (widget.sort == 'symbol') {
        result = a.symbol.compareTo(b.symbol);
      } else if (widget.sort == 'value') {
        result = valueOf(b).compareTo(valueOf(a));
      } else {
        result = pnlOf(b).compareTo(pnlOf(a));
      }
      if (result != 0) return result;
      return a.symbol.compareTo(b.symbol);
    });

    List<String> symbols = [];
    for (HoldingModel item in list) {
      symbols.add(item.symbol);
    }
    return symbols;
  }

  @override
  void dispose() {
    unlisten();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: order.length,
      itemBuilder: (context, index) {
        String symbol = order[index];
        return HoldingRow(
          key: ValueKey(symbol),
          symbol: symbol,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

class HoldingRow extends StatefulWidget {
  final String symbol;
  final VoidCallback onChanged;

  const HoldingRow({super.key, required this.symbol, required this.onChanged});

  @override
  State<HoldingRow> createState() => _HoldingRowState();
}

class _HoldingRowState extends State<HoldingRow> {
  late ValueNotifier<StockQuote> quoteNotifier;

  @override
  void initState() {
    super.initState();
    quoteNotifier = MarketFeed.instance.quoteOf(widget.symbol);
    quoteNotifier.addListener(onTick);
  }

  void onTick() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    quoteNotifier.removeListener(onTick);
    super.dispose();
  }

  Future<void> openTicket() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketPage(symbol: widget.symbol),
      ),
    );
    if (!mounted) return;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    HoldingModel? holding = findHolding(widget.symbol);
    if (holding == null) return const SizedBox.shrink();

    StockQuote quote = quoteNotifier.value;
    int invested = holding.qty * holding.avgPaise;
    int current = holding.qty * quote.ltpPaise;
    int pnl = current - invested;
    Color color = const Color(0xFFDC2626);
    if (pnl >= 0) color = const Color(0xFF16A34A);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: openTicket,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      holding.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    formatPnlLine(pnl, invested),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${holding.qty} shares    Avg ${formatInrPaise(holding.avgPaise)}',
              ),
              Text(
                'LTP ${formatInrPaise(quote.ltpPaise)}    Value ${formatInrPaise(current)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String holdingsSignature() {
  List<String> parts = [];
  for (HoldingModel item in Portfolio.instance.holdings) {
    parts.add('${item.symbol}:${item.qty}:${item.avgPaise}');
  }
  return parts.join('|');
}

HoldingModel? findHolding(String symbol) {
  for (HoldingModel item in Portfolio.instance.holdings) {
    if (item.symbol == symbol) return item;
  }
  return null;
}

int pnlOf(HoldingModel holding) {
  int ltp = MarketFeed.instance.quoteOf(holding.symbol).value.ltpPaise;
  return (holding.qty * ltp) - (holding.qty * holding.avgPaise);
}

int valueOf(HoldingModel holding) {
  int ltp = MarketFeed.instance.quoteOf(holding.symbol).value.ltpPaise;
  return holding.qty * ltp;
}

bool sameSymbols(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
