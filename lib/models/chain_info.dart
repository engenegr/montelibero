class ChainInfo {
  ChainInfo({required this.date, required this.height});

  String date;
  int height;

  get formatDate {
    var today = DateTime.parse(date);
    String dateSlug =
        "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return dateSlug;
  }

  factory ChainInfo.fromJson(Map<String, dynamic> json) => ChainInfo(
        date: DateTime.now().toString(),
        height: json["blocks"] == null ? null : json["blocks"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "height": height,
      };
}
