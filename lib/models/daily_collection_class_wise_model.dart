class Payment {
  final String? payDates;
  final String? classValue;
  final Map<String, double> paymentModeAmounts;

  Payment({
    this.payDates,
    this.classValue,
    required this.paymentModeAmounts,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final rawModes = json["paymentModeAmounts"];
    final Map<String, double> modesMap = {};

    if (rawModes is Map) {
      for (final entry in rawModes.entries) {
        modesMap[entry.key.toString()] = _toDouble(entry.value);
      }
    }

    return Payment(
      payDates:           json["payDates"]?.toString(),
      classValue:         json["class"]?.toString(),
      paymentModeAmounts: modesMap,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // Row total = sum of all payment mode values (TotalAmount key exclude karo agar chahiye)
  double get rowTotal =>
      paymentModeAmounts.values.fold(0.0, (s, v) => s + v);
}