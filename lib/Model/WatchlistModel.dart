import 'package:marketupdates/Constant/stocks.dart';

class WatchlistModel {
  final String id;
  final String name;
  final List<String> symbols;

  WatchlistModel({
    required this.id,
    required this.name,
    required this.symbols,
  });

  WatchlistModel withName(String name) {
    return WatchlistModel(
      id: id,
      name: name,
      symbols: symbols,
    );
  }

  WatchlistModel withSymbols(List<String> symbols) {
    return WatchlistModel(
      id: id,
      name: name,
      symbols: symbols,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbols': symbols,
    };
  }

  factory WatchlistModel.fromMap(Map<String, dynamic> map) {
    List<String> symbols = [];
    var rawSymbols = map['symbols'];

    if (rawSymbols is List) {
      for (var symbol in rawSymbols) {
        String value = symbol.toString();
        bool alreadyAdded = symbols.contains(value);
        bool isRealStock = findStock(value) != null;
        if (isRealStock && !alreadyAdded) {
          symbols.add(value);
        }
      }
    }

    String name = (map['name'] ?? 'Watchlist').toString();
    if (name.trim().isEmpty) name = 'Watchlist';

    return WatchlistModel(
      id: (map['id'] ?? '').toString(),
      name: name,
      symbols: symbols,
    );
  }
}
