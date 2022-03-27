class PriceListBitcoinDates {
  PriceListBitcoinDates({required this.date, required this.price});

  String date;
  double price;

  get formatDate {
    var today = DateTime.parse(date);
    String dateSlug =
        "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return dateSlug;
  }

  factory PriceListBitcoinDates.fromJson(Map<String, dynamic> json) =>
      PriceListBitcoinDates(
        date: json["date"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "price": price,
      };
}
