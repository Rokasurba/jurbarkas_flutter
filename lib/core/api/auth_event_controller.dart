import 'dart:async';

/// Controller for authentication events that can be listened to
/// throughout the app.
class AuthEventController {
  AuthEventController._();

  static final AuthEventController instance = AuthEventController._();

  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of authentication events.
  Stream<AuthEvent> get stream => _controller.stream;

  /// Emit an authentication failure event.
  void emitAuthenticationFailed() {
    _controller.add(AuthEvent.authenticationFailed);
  }

  /// Dispose the controller.
  Future<void> dispose() async {
    await _controller.close();
  }
}

/// Authentication events that can be emitted.
enum AuthEvent {
  /// Token refresh failed, user needs to be logged out.
  authenticationFailed,
}
