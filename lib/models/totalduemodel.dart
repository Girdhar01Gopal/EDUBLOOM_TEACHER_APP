class TotalDue {
  final double totalDueFeeAmount;

  TotalDue({required this.totalDueFeeAmount});

  factory TotalDue.fromJson(Map<String, dynamic> json) {
    final raw = json['totalDueFeeAmount']; // <-- match API key exactly

    if (raw is num) {
      return TotalDue(totalDueFeeAmount: raw.toDouble());
    }

    return TotalDue(
      totalDueFeeAmount: double.tryParse(raw?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDueFeeAmount': totalDueFeeAmount,
    };
  }
}
