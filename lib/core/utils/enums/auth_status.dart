/// Authentication state representation
enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated;

  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isAuthenticating => this == AuthStatus.authenticating;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
}
