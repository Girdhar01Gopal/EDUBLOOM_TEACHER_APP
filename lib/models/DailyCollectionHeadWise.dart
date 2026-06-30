class PaymentDetails9 {
  final String? payDates;
  final Map<String, double> paymentModeAmounts;

  PaymentDetails9({
    this.payDates,
    required this.paymentModeAmounts,
  });

  factory PaymentDetails9.fromJson(Map<String, dynamic> json) {
    final rawModes = json["paymentModeAmounts"];
    final Map<String, double> modesMap = {};

    if (rawModes is Map) {
      for (final entry in rawModes.entries) {
        modesMap[entry.key.toString()] = _toDouble(entry.value);
      }
    }

    return PaymentDetails9(
      payDates:            json["payDates"]?.toString(),
      paymentModeAmounts:  modesMap,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double get rowTotal =>
      paymentModeAmounts.values.fold(0.0, (s, v) => s + v);
}