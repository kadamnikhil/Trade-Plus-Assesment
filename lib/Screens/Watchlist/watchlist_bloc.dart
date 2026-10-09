import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketupdates/Constant/stocks.dart';
import 'package:marketupdates/Model/WatchlistModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  List<WatchlistModel> watchlists = [];
  int selectedIndex = 0;

  WatchlistBloc() : super(WatchlistInitialState()) {
    on<WatchlistLoadEvent>((event, emit) async {
      emit(WatchlistLoadingState());

      try {
        watchlists = await readWatchlists();

        if (watchlists.isEmpty) {
          watchlists = defaultWatchlists();
          selectedIndex = 0;
          await saveWatchlists();
        } else {
          selectedIndex = await readSelectedIndex();
        }

        emit(WatchlistLoadedState(watchlists, selectedIndex));
      } catch (_) {
        watchlists = defaultWatchlists();
        selectedIndex = 0;
        emit(WatchlistLoadedState(watchlists, selectedIndex));
      }
    });

    on<WatchlistCreateEvent>((event, emit) async {
      String name = event.name.trim();
      if (name.isEmpty) {
        emit(WatchlistErrorState('Enter a watchlist name'));
        return;
      }

      List<WatchlistModel> list = List<WatchlistModel>.from(watchlists);
      list.add(
        WatchlistModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          symbols: [],
        ),
      );
      watchlists = list;
      selectedIndex = watchlists.length - 1;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    on<WatchlistRenameEvent>((event, emit) async {
      String name = event.name.trim();
      if (name.isEmpty) {
        emit(WatchlistErrorState('Enter a watchlist name'));
        return;
      }

      List<WatchlistModel> list = [];
      for (var item in watchlists) {
        if (item.id == event.id) {
          list.add(item.withName(name));
        } else {
          list.add(item);
        }
      }
      watchlists = list;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    on<WatchlistDeleteEvent>((event, emit) async {
      if (watchlists.length <= 1) {
        emit(WatchlistErrorState('Keep at least one watchlist'));
        return;
      }

      String selectedId = watchlists[selectedIndex].id;
      List<WatchlistModel> list = [];
      for (var item in watchlists) {
        if (item.id != event.id) {
          list.add(item);
        }
      }
      watchlists = list;

      selectedIndex = 0;
      for (int i = 0; i < watchlists.length; i++) {
        if (watchlists[i].id == selectedId) {
          selectedIndex = i;
          break;
        }
      }

      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    on<WatchlistSelectEvent>((event, emit) async {
      if (event.index < 0 || event.index >= watchlists.length) return;

      selectedIndex = event.index;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    on<WatchlistAddStockEvent>((event, emit) async {
      if (watchlists.isEmpty) return;
      if (findStock(event.symbol) == null) return;

      WatchlistModel selected = watchlists[selectedIndex];
      if (selected.symbols.contains(event.symbol)) return;

      List<String> symbols = List<String>.from(selected.symbols);
      symbols.add(event.symbol);

      List<WatchlistModel> list = List<WatchlistModel>.from(watchlists);
      list[selectedIndex] = selected.withSymbols(symbols);
      watchlists = list;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    on<WatchlistRemoveStockEvent>((event, emit) async {
      if (watchlists.isEmpty) return;

      WatchlistModel selected = watchlists[selectedIndex];
      List<String> symbols = [];
      for (var symbol in selected.symbols) {
        if (symbol != event.symbol) {
          symbols.add(symbol);
        }
      }

      List<WatchlistModel> list = List<WatchlistModel>.from(watchlists);
      list[selectedIndex] = selected.withSymbols(symbols);
      watchlists = list;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });

    // Dragging a row down makes Flutter send an index that is 1 too high.
    on<WatchlistReorderEvent>((event, emit) async {
      if (watchlists.isEmpty) return;

      WatchlistModel selected = watchlists[selectedIndex];
      int oldIndex = event.oldIndex;
      int newIndex = event.newIndex;
      if (newIndex > oldIndex) {
        newIndex = newIndex - 1;
      }
      if (oldIndex < 0 || oldIndex >= selected.symbols.length) return;
      if (newIndex < 0 || newIndex >= selected.symbols.length) return;

      List<String> symbols = List<String>.from(selected.symbols);
      String symbol = symbols.removeAt(oldIndex);
      symbols.insert(newIndex, symbol);

      List<WatchlistModel> list = List<WatchlistModel>.from(watchlists);
      list[selectedIndex] = selected.withSymbols(symbols);
      watchlists = list;
      await saveWatchlists();
      emit(WatchlistLoadedState(watchlists, selectedIndex));
    });
  }

  List<WatchlistModel> defaultWatchlists() {
    return [
      WatchlistModel(
        id: '1',
        name: 'My Stocks',
        symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK'],
      ),
    ];
  }

  Future<List<WatchlistModel>> readWatchlists() async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('watchlists') ?? '';
    if (raw.isEmpty) return [];

    var data = jsonDecode(raw);
    if (data is! List) return [];

    List<WatchlistModel> list = [];
    for (var item in data) {
      if (item is Map) {
        list.add(WatchlistModel.fromMap(Map<String, dynamic>.from(item)));
      }
    }
    return list;
  }

  Future<int> readSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    String selectedId = prefs.getString('selectedWatchlistId') ?? '';

    for (int i = 0; i < watchlists.length; i++) {
      if (watchlists[i].id == selectedId) return i;
    }
    return 0;
  }

  Future<void> saveWatchlists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> maps = [];
      for (var item in watchlists) {
        maps.add(item.toMap());
      }
      await prefs.setString('watchlists', jsonEncode(maps));
      await prefs.setString('selectedWatchlistId', watchlists[selectedIndex].id);
    } catch (_) {}
  }
}

// Event -----------------------------------------------------------------------

abstract class WatchlistEvent {}

class WatchlistLoadEvent extends WatchlistEvent {}

class WatchlistCreateEvent extends WatchlistEvent {
  final String name;
  WatchlistCreateEvent(this.name);
}

class WatchlistRenameEvent extends WatchlistEvent {
  final String id;
  final String name;
  WatchlistRenameEvent(this.id, this.name);
}

class WatchlistDeleteEvent extends WatchlistEvent {
  final String id;
  WatchlistDeleteEvent(this.id);
}

class WatchlistSelectEvent extends WatchlistEvent {
  final int index;
  WatchlistSelectEvent(this.index);
}

class WatchlistAddStockEvent extends WatchlistEvent {
  final String symbol;
  WatchlistAddStockEvent(this.symbol);
}

class WatchlistRemoveStockEvent extends WatchlistEvent {
  final String symbol;
  WatchlistRemoveStockEvent(this.symbol);
}

class WatchlistReorderEvent extends WatchlistEvent {
  final int oldIndex;
  final int newIndex;
  WatchlistReorderEvent(this.oldIndex, this.newIndex);
}

// State -----------------------------------------------------------------------

abstract class WatchlistState {}

class WatchlistInitialState extends WatchlistState {}

class WatchlistLoadingState extends WatchlistState {}

class WatchlistLoadedState extends WatchlistState {
  final List<WatchlistModel> watchlists;
  final int selectedIndex;
  WatchlistLoadedState(this.watchlists, this.selectedIndex);
}

class WatchlistErrorState extends WatchlistState {
  final String message;
  WatchlistErrorState(this.message);
}
