class UserModel {
  final int userId;
  final String userId2;
  final String userRole;
  final String name;
  final String userName;
  final String email;
  final String password;
  final String role;

  UserModel({
    required this.userId,
    required this.userId2,
    required this.userRole,
    required this.name,
    required this.userName,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      userId2: json['userId2'] ?? json['UserId2'] ?? '',
      userRole: json['userRole'] ?? json['UserRole'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      userName: json['userName'] ?? json['UserName'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      password: json['password'] ?? json['Password'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
    );
  }
}