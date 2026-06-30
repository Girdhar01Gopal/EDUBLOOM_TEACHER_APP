class AddExpensesOnly {
  final int addExpensesId;
  final String session;
  final int addEcategoryId;
  final String addECategory;
  final int paymentModeId;
  final String paymentName;
  final DateTime selectDate;
  final double amount;
  final String description;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  AddExpensesOnly({
    required this.addExpensesId,
    required this.session,
    required this.addEcategoryId,
    required this.addECategory,
    required this.paymentModeId,
    required this.paymentName,
    required this.selectDate,
    required this.amount,
    required this.description,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory AddExpensesOnly.fromJson(Map<String, dynamic> json) {
    return AddExpensesOnly(
      addExpensesId: json['addExpensesId'] ?? 0,
      session: json['session'] ?? '',
      addEcategoryId: json['addEcategoryId'] ?? 0,
      addECategory: json['addECategory'] ?? '',
      paymentModeId: json['paymentModeId'] ?? 0,
      paymentName: json['paymentName'] ?? '',
      selectDate: DateTime.parse(json['selectdate']),
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      action: json['action'] ?? '1',
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      createBy: json['createBy'] ?? '',
      updateBy: json['updateBy'],
      schoolId: json['schoolId'] ?? '',
    );
  }
}

// Category dropdown ke liye - id POST mein jaayegi
class CategoryDropdownItem {
  final int id;
  final String name;
  CategoryDropdownItem({required this.id, required this.name});
}

// PaymentMode dropdown ke liye - id POST mein jaayegi
class PaymentModeDropdownItem {
  final int id;
  final String name;
  PaymentModeDropdownItem({required this.id, required this.name});
}