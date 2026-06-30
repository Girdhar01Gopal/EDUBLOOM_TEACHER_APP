class FeeDailyCollectionItem {
  final String? payDates;
  final double totalPayAmount;
  final Map<String, double> paymentModeAmounts; // ✅ Dynamic map

  FeeDailyCollectionItem({
    this.payDates,
    required this.totalPayAmount,
    required this.paymentModeAmounts,
  });

  factory FeeDailyCollectionItem.fromJson(Map<String, dynamic> json) {
    final rawModes = json["paymentModeAmounts"];
    final Map<String, double> modesMap = {};

    if (rawModes is Map) {
      for (final entry in rawModes.entries) {
        modesMap[entry.key] = _toDouble(entry.value);
      }
    }

    return FeeDailyCollectionItem(
      payDates:           json["payDates"]?.toString(),
      totalPayAmount:     _toDouble(json["totalPayAmount"]),
      paymentModeAmounts: modesMap,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // Row total = sum of all payment mode values
  double get rowTotal =>
      paymentModeAmounts.values.fold(0.0, (s, v) => s + v);
}