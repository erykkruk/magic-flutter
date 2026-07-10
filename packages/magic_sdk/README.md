# magic_flutter_v2

A maintained fork of [`magic_sdk`](https://pub.dev/packages/magic_sdk) (from
[magiclabs/magic-flutter](https://github.com/magiclabs/magic-flutter)) based on `6.0.1`.

Magic empowers developers to protect their users via an innovative, passwordless authentication flow without the UX compromises that burden traditional OAuth implementations.

## Why this fork

Upstream `magic_sdk` renders the relayer WebView with `Visibility(visible: false)` while the
overlay is idle, which takes the `WKWebView` offstage. On iOS the system then suspends its web
content process, so `box.magic.link` never emits `MAGIC_OVERLAY_READY` and queued relayer RPCs
(the `loginWithOAuth` result parsing, the first `loginWithEmailOTP`) hang forever.

This fork keeps the relayer WebView attached and painted at all times so it stays alive, but shrinks
it to a `1x1`, pointer-ignoring box while the overlay is hidden — so it neither covers the host app
nor blocks touches to content below it. It expands to full size only while the overlay is visible.

The public API is unchanged from upstream `6.0.1`; only the package name differs.

## ⚠️ Removal of `loginWithMagicLink()`  ⚠️
As of `v4.0.0`, passcodes (ie. `loginWithSMS()`, `loginWithEmailOTP()`) are replacing Magic Links (ie. `loginWithMagicLink()`) for all of our Mobile SDKs⁠. [Learn more](https://magic.link/docs/auth/login-methods/email/email-link-update-march-2023)

## Features

This is your entry-point to secure, passwordless authentication for your iOS or Android-based Flutter app.

## Installation

Add `magic_flutter_v2` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  magic_flutter_v2: ^6.0.1
```

Run the following command to install dependencies

```text
$ flutter pub get
```

## Create an SDK Instance

In `main.dart`, instantiate Magic with your publishable key

```dart
import 'package:magic_flutter_v2/magic_flutter_v2.dart';

void main() {
  runApp(const MyApp());

  Magic.instance = Magic("YOUR_PUBLISHABLE_KEY");
}
```

Use `Stack` in the top level and add `Magic.instance.relayer` to the children of Stack to ensure the best performance

Note: Relayer is required to establish communication between apps and Magic service. Make sure to have it in a stack whenever you need to authenticate or interact with blockchain

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Magic Demo',
        home: Stack(children: [
          const LoginPage(),
          Magic.instance.relayer
        ]));
  }
}
```

Authenticate your first user!

```dart
var token = await magic.auth.loginWithEmailOTP(email: textController.text);
```

## Additional information

For more detail, please check the [Magic Link Flutter doc](https://magic.link/docs/login-methods/email/integration/flutter).

## License & credits

This package is a fork of [magiclabs/magic-flutter](https://github.com/magiclabs/magic-flutter),
distributed under the Apache License 2.0. The original copyright remains with Magic Labs, Inc.
See [LICENSE](LICENSE). This fork adds the iOS relayer WebView fix described above.
