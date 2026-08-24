import 'package:flutter/foundation.dart';

/// What went wrong inside the relayer.
enum MagicRelayerErrorKind {
  /// The relayer URL could not be built, so the WebView never loaded.
  ///
  /// Nothing can be sent to Magic in this state: every login call queues
  /// and waits forever. This is the failure that looks like "OAuth hangs".
  urlUnavailable,

  /// A message from the relayer could not be parsed.
  responseUndecodable,

  /// A response arrived for a request nobody is waiting on any more.
  ///
  /// Usually a late reply after a timeout or a disposed relayer; harmless
  /// on its own, but a burst of them points at a mismatch in request ids.
  orphanedResponse,
}

/// A relayer failure, reported to [MagicRelayerDiagnostics.onError].
@immutable
class MagicRelayerError {
  /// Creates a relayer error report.
  const MagicRelayerError({
    required this.kind,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// What kind of failure this is.
  final MagicRelayerErrorKind kind;

  /// Human-readable description, safe to log.
  final String message;

  /// The underlying error object, when there was one.
  final Object? error;

  /// Stack trace of [error], when available.
  final StackTrace? stackTrace;

  /// Name of [kind] without its enum prefix.
  String get kindName => kind.toString().split('.').last;

  @override
  String toString() => 'MagicRelayerError($kindName: $message)';
}

/// Observability hook for the relayer WebView.
///
/// The relayer is where logins actually happen, and when it fails it fails
/// quietly: a login call queues a message and waits for a reply that never
/// comes. Before this, those failures only reached the console, so a host
/// app had no way to notice, report or time out.
///
/// Register a handler once at startup:
///
/// ```dart
/// MagicRelayerDiagnostics.onError = (error) {
///   crashReporter.report(error.error ?? error.message, error.stackTrace);
///   if (error.kind == MagicRelayerErrorKind.urlUnavailable) {
///     // Logins cannot succeed in this state: show a retry instead of a
///     // spinner that never resolves.
///     showLoginUnavailable();
///   }
/// };
/// ```
///
/// The handler is called on the platform thread that hit the error, must not
/// throw, and should return quickly. Leaving it null keeps the previous
/// behaviour: failures go to the debug console only.
/// The package still declares `sdk: '>=2.12.0'`, so this is a plain class
/// with a private constructor rather than `abstract final`, and error kinds
/// are stringified the way the rest of the SDK does it. Keeping the
/// constraint intact means the fork stays a drop-in replacement for
/// `magic_sdk` on the same SDK range.
class MagicRelayerDiagnostics {
  MagicRelayerDiagnostics._();

  /// Called whenever the relayer hits a failure. Null by default.
  static void Function(MagicRelayerError error)? onError;

  /// Reports [error] to [onError], and to the debug console as a fallback.
  ///
  /// Never rethrows: diagnostics must not become a new failure mode inside
  /// the auth path.
  static void report(MagicRelayerError error) {
    final handler = onError;
    if (handler == null) {
      debugPrint('[magic_flutter_v2] $error');
      return;
    }
    try {
      handler(error);
    } catch (handlerError) {
      debugPrint(
        '[magic_flutter_v2] diagnostics handler threw: $handlerError',
      );
    }
  }
}
