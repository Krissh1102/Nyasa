enum AdminRole { admin, superAdmin, staff }

extension AdminRoleX on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.staff:
        return 'Staff';
    }
  }
}

class AdminUser {
  final String name;
  final String email;
  final AdminRole role;

  const AdminUser({required this.name, required this.email, required this.role});
}
