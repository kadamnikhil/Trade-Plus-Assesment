import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketupdates/Constant/colors.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/WatchlistModel.dart';
import 'package:marketupdates/Screens/Ticket/ticket.dart';
import 'package:marketupdates/Screens/Watchlist/watchlist_bloc.dart';
import 'package:marketupdates/Services/market_feed.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final WatchlistBloc watchlistBloc = WatchlistBloc();
  List<WatchlistModel> watchlists = [];
  int selectedIndex = 0;
  bool loading = true;

  WatchlistModel? get selectedWatchlist {
    if (watchlists.isEmpty) return null;
    if (selectedIndex < 0 || selectedIndex >= watchlists.length) {
      return watchlists.first;
    }
    return watchlists[selectedIndex];
  }

  @override
  void initState() {
    super.initState();
    MarketFeed.instance.start();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    WatchlistModel? selected = selectedWatchlist;

    return BlocProvider(
      create: (context) => watchlistBloc..add(WatchlistLoadEvent()),
      child: BlocListener<WatchlistBloc, WatchlistState>(
        listener: (context, state) {
          if (state is WatchlistLoadingState) {
            setState(() {
              loading = true;
            });
          }

          if (state is WatchlistLoadedState) {
            setState(() {
              loading = false;
              watchlists = state.watchlists;
              selectedIndex = state.selectedIndex;
            });
          }

          if (state is WatchlistErrorState) {
            setState(() {
              loading = false;
            });
            showMessage(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            title: const Text('Watchlist'),
            actions: [
              IconButton(
                tooltip: 'New watchlist',
                onPressed: createWatchlist,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          floatingActionButton: selected == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => addStock(selected),
                  icon: const Icon(Icons.add),
                  label: const Text('Add stock'),
                ),
          body: pageBody(selected),
        ),
      ),
    );
  }

  Widget pageBody(WatchlistModel? selected) {
    if (loading || selected == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        watchlistChips(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${selected.name} (${selected.symbols.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') renameWatchlist(selected);
                  if (value == 'delete') deleteWatchlist(selected);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: selected.symbols.isEmpty ? emptyStocks() : stockList(selected),
        ),
      ],
    );
  }

  Widget watchlistChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: watchlists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          WatchlistModel item = watchlists[index];
          bool selected = index == selectedIndex;
          return ChoiceChip(
            label: Text(item.name),
            selected: selected,
            onSelected: (value) {
              watchlistBloc.add(WatchlistSelectEvent(index));
            },
          );
        },
      ),
    );
  }

  Widget stockList(WatchlistModel watchlist) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
      buildDefaultDragHandles: false,
      itemCount: watchlist.symbols.length,
      onReorder: (oldIndex, newIndex) {
        watchlistBloc.add(WatchlistReorderEvent(oldIndex, newIndex));
      },
      itemBuilder: (context, index) {
        String symbol = watchlist.symbols[index];
        return StockTile(
          key: ValueKey(symbol),
          symbol: symbol,
          index: index,
          onRemove: () {
            watchlistBloc.add(WatchlistRemoveStockEvent(symbol));
          },
        );
      },
    );
  }

  Widget emptyStocks() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 48, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'No stocks in this watchlist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Tap Add stock to pick one',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Future<void> createWatchlist() async {
    String? name = await askName('New watchlist', '');
    if (name == null) return;
    watchlistBloc.add(WatchlistCreateEvent(name));
  }

  Future<void> renameWatchlist(WatchlistModel watchlist) async {
    String? name = await askName('Rename watchlist', watchlist.name);
    if (name == null) return;
    watchlistBloc.add(WatchlistRenameEvent(watchlist.id, name));
  }

  Future<void> deleteWatchlist(WatchlistModel watchlist) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete watchlist'),
          content: Text('Delete ${watchlist.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      watchlistBloc.add(WatchlistDeleteEvent(watchlist.id));
    }
  }

  Future<void> addStock(WatchlistModel watchlist) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Add stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              for (final stock in kStocks)
                ListTile(
                  title: Text(stock.symbol),
                  subtitle: Text(stock.name),
                  enabled: !watchlist.symbols.contains(stock.symbol),
                  trailing: watchlist.symbols.contains(stock.symbol)
                      ? const Text('Added')
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    watchlistBloc.add(WatchlistAddStockEvent(stock.symbol));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> askName(String title, String initial) {
    return showDialog<String>(
      context: context,
      builder: (context) => NameDialog(title: title, initial: initial),
    );
  }
}

class NameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const NameDialog({
    super.key,
    required this.title,
    required this.initial,
  });

  @override
  State<NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  late final TextEditingController controller;
  String error = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Name',
          errorText: error.isEmpty ? null : error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String value = controller.text.trim();
            if (value.isEmpty) {
              setState(() {
                error = 'Enter a name';
              });
              return;
            }
            Navigator.pop(context, value);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class StockTile extends StatefulWidget {
  final String symbol;
  final int index;
  final VoidCallback onRemove;

  const StockTile({
    super.key,
    required this.symbol,
    required this.index,
    required this.onRemove,
  });

  @override
  State<StockTile> createState() => _StockTileState();
}

class _StockTileState extends State<StockTile> {
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

  @override
  void didUpdateWidget(covariant StockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol == widget.symbol) return;

    quoteNotifier.removeListener(onPriceChange);
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

  void openTicket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketPage(symbol: widget.symbol),
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.drag_handle, color: AppColors.muted),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: openTicket,
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
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
