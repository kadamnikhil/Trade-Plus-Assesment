# TradePlus

A Flutter trading app featuring watchlists, simulated live stock prices, buy/sell orders, and portfolio holdings. Stock prices are generated using a mock market feed. No backend is required.

## Run

Prerequisites: Flutter SDK (stable channel).

```bash
flutter pub get
flutter run
```

The app starts with ₹5,00,000 in virtual cash. Watchlists, cash balance, holdings, and order history are saved locally on the device.

To change how frequently stock prices update, modify the `tickInterval` value in `lib/Services/market_feed.dart`.

- Default: `500` milliseconds
- `20` milliseconds: approximately 50 updates per second

## Features

- Create and manage watchlists.
- Add, remove, and reorder stocks.
- View simulated live prices for 10 stocks.
- Place virtual buy and sell orders.
- View portfolio holdings and live profit/loss (P&L).
- Sort holdings.
- View saved order history.
- Persist cash balance, watchlists, holdings, and orders locally.
- Configure the simulated market price update interval.

## Folder Structure

```text
lib/
├── main.dart
├── Constant/
│   └── stocks.dart
├── Model/
├── Services/
│   ├── market_feed.dart
│   └── portfolio.dart
├── Screens/
│   ├── Watchlist/
│   ├── Market/
│   ├── Ticket/
│   ├── Holdings/
│   └── Orders/
└── Designs/
```

## Folder Description

- `main.dart` — Starts the application and initializes the market feed.
- `Constant/stocks.dart` — Contains stock data and rupee formatting.
- `Model/` — Contains watchlist, holding, and order models.
- `Services/market_feed.dart` — Provides a shared simulated stock price feed.
- `Services/portfolio.dart` — Manages local cash, holdings, and order persistence.
- `Screens/Watchlist/` — Watchlist creation and management.
- `Screens/Market/` — Displays stock prices for all 10 stocks.
- `Screens/Ticket/` — Buy/sell form and order confirmation.
- `Screens/Holdings/` — Displays holdings, live P&L, and sorting.
- `Screens/Orders/` — Displays saved order history.
- `Designs/` — Contains static sample screens for reference.

## Notes

- No backend integration is required.
- Stock prices are simulated and do not represent actual market prices.
- All orders are virtual; no real trades are executed.
- Application data is stored locally on the device.