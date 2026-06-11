/// Stores a pending invite token when deep-link delivery precedes navigation.
/// LoginPage reads this as a fallback if direct navigation fails.
class PendingInvite {
  static String? token;
}
