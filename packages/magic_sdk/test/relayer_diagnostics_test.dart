import 'package:flutter_test/flutter_test.dart';
import 'package:magic_flutter_v2/relayer/relayer_diagnostics.dart';

void main() {
  tearDown(() {
    MagicRelayerDiagnostics.onError = null;
  });

  group('MagicRelayerError', () {
    test('carries the kind, message and cause', () {
      final cause = StateError('boom');
      final trace = StackTrace.current;

      final error = MagicRelayerError(
        kind: MagicRelayerErrorKind.urlUnavailable,
        message: 'Relayer URL could not be built',
        error: cause,
        stackTrace: trace,
      );

      expect(error.kind, MagicRelayerErrorKind.urlUnavailable);
      expect(error.message, 'Relayer URL could not be built');
      expect(error.error, same(cause));
      expect(error.stackTrace, same(trace));
    });

    test('cause and stack trace are optional', () {
      const error = MagicRelayerError(
        kind: MagicRelayerErrorKind.orphanedResponse,
        message: 'No pending request',
      );

      expect(error.error, isNull);
      expect(error.stackTrace, isNull);
    });

    test('kindName strips the enum prefix', () {
      const error = MagicRelayerError(
        kind: MagicRelayerErrorKind.responseUndecodable,
        message: 'x',
      );

      expect(error.kindName, 'responseUndecodable');
    });

    test('toString names the kind and the message', () {
      const error = MagicRelayerError(
        kind: MagicRelayerErrorKind.urlUnavailable,
        message: 'no url',
      );

      expect(error.toString(), contains('urlUnavailable'));
      expect(error.toString(), contains('no url'));
    });
  });

  group('MagicRelayerDiagnostics', () {
    test('no handler is registered by default', () {
      expect(MagicRelayerDiagnostics.onError, isNull);
    });

    test('reports to a registered handler', () {
      final seen = <MagicRelayerError>[];
      MagicRelayerDiagnostics.onError = seen.add;

      MagicRelayerDiagnostics.report(
        const MagicRelayerError(
          kind: MagicRelayerErrorKind.urlUnavailable,
          message: 'no url',
        ),
      );

      expect(seen, hasLength(1));
      expect(seen.single.kind, MagicRelayerErrorKind.urlUnavailable);
    });

    test('reporting without a handler does not throw', () {
      expect(
        () => MagicRelayerDiagnostics.report(
          const MagicRelayerError(
            kind: MagicRelayerErrorKind.responseUndecodable,
            message: 'unparseable',
          ),
        ),
        returnsNormally,
      );
    });

    test('a throwing handler does not escape into the auth path', () {
      // Diagnostics must never become a new failure mode inside login.
      MagicRelayerDiagnostics.onError = (_) => throw StateError('handler bug');

      expect(
        () => MagicRelayerDiagnostics.report(
          const MagicRelayerError(
            kind: MagicRelayerErrorKind.urlUnavailable,
            message: 'no url',
          ),
        ),
        returnsNormally,
      );
    });

    test('every reported error reaches the handler', () {
      final kinds = <MagicRelayerErrorKind>[];
      MagicRelayerDiagnostics.onError = (error) => kinds.add(error.kind);

      for (final kind in MagicRelayerErrorKind.values) {
        MagicRelayerDiagnostics.report(
          MagicRelayerError(kind: kind, message: 'x'),
        );
      }

      expect(kinds, MagicRelayerErrorKind.values);
    });

    test('clearing the handler restores the console fallback', () {
      final seen = <MagicRelayerError>[];
      MagicRelayerDiagnostics.onError = seen.add;
      MagicRelayerDiagnostics.onError = null;

      MagicRelayerDiagnostics.report(
        const MagicRelayerError(
          kind: MagicRelayerErrorKind.orphanedResponse,
          message: 'late reply',
        ),
      );

      expect(seen, isEmpty);
    });
  });
}
