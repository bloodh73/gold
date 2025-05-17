import 'dart:convert';

Gold goldFromJson(String str) => Gold.fromJson(json.decode(str));

String goldToJson(Gold data) => json.encode(data.toJson());

class Gold {
  List<Currency> gold;
  List<Currency> currency;
  List<Cryptocurrency> cryptocurrency;

  Gold({
    required this.gold,
    required this.currency,
    required this.cryptocurrency,
  });

  factory Gold.fromJson(Map<String, dynamic> json) {
    try {
      return Gold(
        gold:
            json["gold"] != null
                ? List<Currency>.from(
                  json["gold"].map((x) => Currency.fromJson(x)),
                )
                : [],
        currency:
            json["currency"] != null
                ? List<Currency>.from(
                  json["currency"].map((x) => Currency.fromJson(x)),
                )
                : [],
        cryptocurrency:
            json["cryptocurrency"] != null
                ? List<Cryptocurrency>.from(
                  json["cryptocurrency"].map((x) => Cryptocurrency.fromJson(x)),
                )
                : [],
      );
    } catch (e) {
      print('Error in Gold.fromJson: $e');
      // Return empty lists as fallback
      return Gold(gold: [], currency: [], cryptocurrency: []);
    }
  }

  Map<String, dynamic> toJson() => {
    "gold": List<dynamic>.from(gold.map((x) => x.toJson())),
    "currency": List<dynamic>.from(currency.map((x) => x.toJson())),
    "cryptocurrency": List<dynamic>.from(cryptocurrency.map((x) => x.toJson())),
  };
}

class Currency {
  String? date;
  String time;
  int timeUnix;
  String symbol;
  String nameEn;
  String name;
  dynamic price; // Can be int or string
  int changeValue;
  double changePercent;
  String unit;

  Currency({
    this.date,
    required this.time,
    required this.timeUnix,
    required this.symbol,
    required this.nameEn,
    required this.name,
    required this.price,
    required this.changeValue,
    required this.changePercent,
    required this.unit,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    try {
      return Currency(
        date: json["date"]?.toString(),
        time: json["time"]?.toString() ?? "",
        timeUnix: json["time_unix"] ?? 0,
        symbol: json["symbol"] ?? "",
        nameEn: json["name_en"] ?? "",
        name: json["name"] ?? "",
        price: json["price"] ?? 0,
        changeValue: json["change_value"] ?? 0,
        changePercent: (json["change_percent"] ?? 0).toDouble(),
        unit: json["unit"] ?? "",
      );
    } catch (e) {
      print('Error in Currency.fromJson: $e');
      // Return default values as fallback
      return Currency(
        time: "",
        timeUnix: 0,
        symbol: "",
        nameEn: "",
        name: "",
        price: 0,
        changeValue: 0,
        changePercent: 0,
        unit: "",
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "date": date,
    "time": time,
    "time_unix": timeUnix,
    "symbol": symbol,
    "name_en": nameEn,
    "name": name,
    "price": price,
    "change_value": changeValue,
    "change_percent": changePercent,
    "unit": unit,
  };
}

class Cryptocurrency {
  String? date;
  String? time;
  int timeUnix;
  String symbol;
  String nameEn;
  String name;
  String price;
  double changePercent;
  int marketCap;
  String unit;
  String description;

  Cryptocurrency({
    this.date,
    this.time,
    required this.timeUnix,
    required this.symbol,
    required this.nameEn,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.marketCap,
    required this.unit,
    required this.description,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    try {
      return Cryptocurrency(
        date: json["date"]?.toString(),
        time: json["time"]?.toString(),
        timeUnix: json["time_unix"] ?? 0,
        symbol: json["symbol"] ?? "",
        nameEn: json["name_en"] ?? "",
        name: json["name"] ?? "",
        price: json["price"]?.toString() ?? "0",
        changePercent: (json["change_percent"] ?? 0).toDouble(),
        marketCap: json["market_cap"] ?? 0,
        unit: json["unit"] ?? "",
        description: json["description"] ?? "",
      );
    } catch (e) {
      print('Error in Cryptocurrency.fromJson: $e');
      // Return default values as fallback
      return Cryptocurrency(
        timeUnix: 0,
        symbol: "",
        nameEn: "",
        name: "",
        price: "0",
        changePercent: 0,
        marketCap: 0,
        unit: "",
        description: "",
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "date": date,
    "time": time,
    "time_unix": timeUnix,
    "symbol": symbol,
    "name_en": nameEn,
    "name": name,
    "price": price,
    "change_percent": changePercent,
    "market_cap": marketCap,
    "unit": unit,
    "description": description,
  };
}
