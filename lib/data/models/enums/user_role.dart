/// Enum representing user roles in the application
///
/// Roles stored in database as uppercase with underscores (e.g., "GROUP_MANAGER")
enum UserRole {
  /// System administrator with full permissions
  admin('ADMIN'),

  /// Group manager with elevated permissions for group management
  groupManager('GROUP_MANAGER'),

  /// Regular member with standard permissions
  member('MEMBER');

  /// The database value for this role
  final String value;

  const UserRole(this.value);

  /// Creates a UserRole from a string value
  ///
  /// Handles multiple formats:
  /// - "ADMIN", "admin", "Admin"
  /// - "GROUP_MANAGER", "group_manager", "Group Manager", "groupmanager"
  /// - "MEMBER", "member", "Member"
  ///
  /// Returns null if the value doesn't match any known role
  static UserRole? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    // Normalize: uppercase and replace spaces with underscores
    final normalized = value.toUpperCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'ADMIN':
        return UserRole.admin;
      case 'GROUP_MANAGER':
      case 'GROUPMANAGER':
      case 'MANAGER': // Handle legacy 'Manager' role
        return UserRole.groupManager;
      case 'MEMBER':
        return UserRole.member;
      default:
        return null;
    }
  }

  /// Checks if a list of role strings contains this role
  static bool hasRole(List<String>? roles, UserRole role) {
    if (roles == null || roles.isEmpty) return false;
    return roles.any((r) => fromString(r) == role);
  }

  /// Checks if a list of role strings contains admin role
  static bool isAdmin(List<String>? roles) {
    return hasRole(roles, UserRole.admin);
  }

  /// Checks if a list of role strings contains group manager role
  static bool isGroupManager(List<String>? roles) {
    return hasRole(roles, UserRole.groupManager);
  }

  /// Checks if a list of role strings contains member role
  static bool isMember(List<String>? roles) {
    return hasRole(roles, UserRole.member);
  }

  /// Checks if a list of role strings contains admin OR group manager
  static bool isAdminOrGroupManager(List<String>? roles) {
    return isAdmin(roles) || isGroupManager(roles);
  }

  /// Returns a user-friendly display name for the role
  ///
  /// Examples:
  /// - ADMIN -> "ADMIN"
  /// - GROUP_MANAGER -> "GROUP MANAGER"
  /// - MEMBER -> "MEMBER"
  String get displayName {
    return value.replaceAll('_', ' ');
  }

  /// Returns the role value in title case
  ///
  /// Examples:
  /// - ADMIN -> "Admin"
  /// - GROUP_MANAGER -> "Group Manager"
  /// - MEMBER -> "Member"
  String get titleCase {
    final words = value.toLowerCase().split('_');
    return words
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  String toString() => value;
}

/// Extension methods for List<String> to work with roles
extension RoleListExtension on List<String> {
  /// Checks if this list contains the given role
  bool containsRole(UserRole role) {
    return UserRole.hasRole(this, role);
  }

  /// Checks if this list contains admin role
  bool get hasAdmin => UserRole.isAdmin(this);

  /// Checks if this list contains group manager role
  bool get hasGroupManager => UserRole.isGroupManager(this);

  /// Checks if this list contains admin or group manager role
  bool get hasAdminOrGroupManager => UserRole.isAdminOrGroupManager(this);

  /// Converts string roles to UserRole enum values (filters out unknown roles)
  List<UserRole> get asUserRoles {
    return map((r) => UserRole.fromString(r)).whereType<UserRole>().toList();
  }
}
