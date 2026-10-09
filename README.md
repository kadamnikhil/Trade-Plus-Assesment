# TradePlus

A Flutter trading app with a watchlist, live prices, buy/sell orders, and holdings. Prices come from a mock feed. Nothing needs a backend.

## Run

Needs Flutter stable.

```bash
flutter pub get
flutter run
```

You start with ₹5,00,000 cash. Watchlists, cash, holdings, and orders are saved on the device.

To make prices move faster, change `tickInterval` in `lib/Services/market_feed.dart`. It is `500` ms now. `20` ms is about 50 ticks per second.

## Folder structure

```text
lib/
  main.dart                  starts the app and the price feed
  Constant/stocks.dart       the 10 stocks and rupee formatting
  Model/                     watchlist, holding, and order data
  Services/
    market_feed.dart         one live price source for the whole app
    portfolio.dart           saved cash, holdings, and orders
  Screens/
    Watchlist/               create lists, add, remove, and reorder stocks
    Market/                  live prices for all 10 stocks
    Ticket/                  buy/sell form and confirmation
    Holdings/                holdings with live P&L and sorting
    Orders/                  saved order history
  Designs/                   static sample screens only
```
