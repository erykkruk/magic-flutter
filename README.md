# magic-flutter

> Magic empowers developers to protect their users via an innovative, passwordless authentication flow without the UX compromises that burden traditional OAuth implementations.

## ⚠️ Device Registration Requirement  ⚠️
As of `v4.1.0`, users will be asked to go through a device registration flow to securely confirm any new device they use to login. If you run into [this issue](https://github.com/magiclabs/magic-flutter/issues/31), please consider upgrading to the latest version of the SDK.

## Get started

Install Flutter & Dart https://flutter.dev/docs/get-started/install

## Start the project

```bash
$ cd project_root/magic_demo
$ flutter run
```

Dependency installation is automatically done in the `flutter run` command

For detail integration please check our [official doc](https://magic.link/docs/auth/api-reference/client-side-sdks/flutter)
or README in each package directory 

| Package Name                                                    | Changelog                                             | Description                                                           |
|-----------------------------------------------------------------|-------------------------------------------------------|-----------------------------------------------------------------------|
| [`magic_sdk`](https://pub.dev/packages/magic_sdk)               | [CHANGELOG](./packages/magic_sdk/CHANGELOG.md)        | Flutter entry-point for Magic SDK.                                    |
| [`magic_ext_oauth`](https://pub.dev/packages/magic_ext_oauth)   | [CHANGELOG](./packages/magic_ext/oauth/CHANGELOG.md)  | An Extension to access OAuth providers                                |
| [`magic_ext_tezos`](https://pub.dev/packages/magic_ext_tezos)   | [CHANGELOG](./packages/magic_ext/tezos/CHANGELOG.md)  | Tezos blockchain extension that integrates with Tezart                |
| [`magic_ext_solana`](https://pub.dev/packages/magic_ext_solana) | [CHANGELOG](./packages/magic_ext/solana/CHANGELOG.md) | Solana blockchain extension that integrates with crypto-please/solana |
| [`magic_ext_oidc`](https://pub.dev/packages/magic_ext_oidc) | [CHANGELOG](./packages/magic_ext/oidc/CHANGELOG.md) | Magic Open Id Connect SDK extension for Flutter |

### Blockchain access

Make sure you have the third-party blockchain dependencies installed
* Tezos via Tezart
* Solana via Crypto-please/solana

You may remove these dependencies if you don't need to access these chains

## Relayer diagnostics

The relayer WebView is where logins actually happen. When it fails, it fails
quietly: a login call queues a message and waits for a reply that never
arrives, which surfaces to users as a spinner that never resolves.

Register a handler once at startup to see those failures:

```dart
MagicRelayerDiagnostics.onError = (error) {
  crashReporter.report(error.error ?? error.message, error.stackTrace);

  if (error.kind == MagicRelayerErrorKind.urlUnavailable) {
    // The relayer never loaded, so no login can succeed in this state.
    // Show a retry rather than a spinner.
    showLoginUnavailable();
  }
};
```

| Kind | Meaning |
|---|---|
| `urlUnavailable` | The relayer URL could not be built, so the WebView never loaded and every login queues forever |
| `responseUndecodable` | A message from the relayer could not be parsed |
| `orphanedResponse` | A reply arrived for a request nobody awaits any more (a late response after a timeout, or a disposed relayer) |

The handler must not throw and should return quickly; it is called on the
thread that hit the error. Leaving it unset keeps the previous behaviour:
failures go to the debug console only.

## Development Caveats

Files ending with `*.g.dart` are auto generated type files that are used to serialize / deserialize a class.
To generate a new sets of files to reflect your changes please run the command below at `your/path/to/magic_sdk`

```bash
$ dart run build_runner build --delete-conflicting-outputs
```

### Proguard rules 
Relates to [issue #43](https://github.com/magiclabs/magic-flutter/issues/43).

Add a `proguard-rules.pro` file under your `android/app` folder (or update your existing one), with the following rule:
```
# Preserve annotated Javascript interface methods.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
```
Example: [Magic Flutter Demo App](https://github.com/magiclabs/magic-flutter/blob/main/magic_demo/android/app/proguard-rules.pro)
