class UserAccessModule {
  final String moduleName;
  final List<UserAccessPermission> permissions;

  UserAccessModule({
    required this.moduleName,
    required this.permissions,
  });
}

class UserAccessPermission {
  final String name;
  bool isChecked;

  UserAccessPermission({
    required this.name,
    this.isChecked = false,
  });
}