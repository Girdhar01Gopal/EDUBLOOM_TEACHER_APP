class ViewExpensesModel {
  final List<ViewExpensesItem> listData;

  ViewExpensesModel({required this.listData});

  factory ViewExpensesModel.fromJson(Map<String, dynamic> json) {
    final raw = json['listData'];
    if (raw == null || raw is! List) {
      return ViewExpensesModel(listData: []);
    }
    return ViewExpensesModel(
      listData: raw
          .whereType<Map>()
          .map((e) => ViewExpensesItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ViewExpensesItem {
  final int addExpensesId;
  final String session;
  final int addEcategoryId;
  final String addECategory;
  final int paymentModeId;
  final String paymentName;
  final String selectdate;
  final double amount;
  final String description;
  final String action;
  final String createDate;
  final String? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  ViewExpensesItem({
    required this.addExpensesId,
    required this.session,
    required this.addEcategoryId,
    required this.addECategory,
    required this.paymentModeId,
    required this.paymentName,
    required this.selectdate,
    required this.amount,
    required this.description,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory ViewExpensesItem.fromJson(Map<String, dynamic> json) {
    return ViewExpensesItem(
      addExpensesId: _parseInt(json['addExpensesId']),
      session:       _str(json['session']),
      addEcategoryId: _parseInt(json['addEcategoryId']),
      addECategory:  _str(json['addECategory']),
      paymentModeId: _parseInt(json['paymentModeId']),
      paymentName:   _str(json['paymentName']),
      selectdate:    _str(json['selectdate']),
      amount:        _parseDouble(json['amount']),
      description:   _str(json['description']),
      action:        _str(json['action']),
      createDate:    _str(json['createDate']),
      updateDate:    json['updateDate']?.toString(),
      createBy:      _str(json['createBy']),
      updateBy:      json['updateBy']?.toString(),
      schoolId:      _str(json['schoolId']),
    );
  }

  /// "2026-04-16T00:00:00" → "16-04-2026"
  String get formattedDate {
    try {
      final dt = DateTime.parse(selectdate);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    } catch (_) {
      return selectdate;
    }
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _str(dynamic v) => v?.toString().trim() ?? '';
}