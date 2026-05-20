# magic_ext_oauth (fork)

> **Fork notice:** this is a community fork of [magiclabs/magic-flutter](https://github.com/magiclabs/magic-flutter) `magic_ext_oauth 0.4.7`. The upstream is archived and depends on the abandoned `flutter_web_auth ^0.5.0` package, which is broken on iOS 13+ scene-based apps (OAuth callback never resolves). This fork swaps it for `flutter_web_auth_2 ^4.0.0` and ships a few small fixes (see CHANGELOG).
>
> Consume via git:
> ```yaml
> magic_ext_oauth:
>   git:
>     url: https://github.com/erykkruk/magic-flutter.git
>     ref: flutter_web_auth_2
>     path: packages/magic_ext/oauth
> ```

---

Magic empowers developers to protect their users via an innovative, passwordless authentication flow without the UX compromises that burden traditional OAuth implementations.

## Features

This is your entry-point to secure, passwordless authentication for your iOS or Android-based Flutter app.

## Installation

Add `magic_sdk` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  magic_sdk: ^4.0.0
  magic_ext_oauth: ^0.3.0
```

Run the following command to install dependencies

```text
$ dart pub get
```

## Create an SDK Instance

In `main.dart`, instantiate Magic with your publishable key

```dart

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
        home: Stack(children: [ // Use Stack here to make sure
          MaterialApp(
            title: 'Magic Demo',
            home: const LoginPage(),
          ),
          Magic.instance.relayer // Insert relayer here
        ]));
  }
}
```

Authenticate your first user via OAuth!

```dart
import 

var configuration = OAuthConfiguration(provider: OAuthProvider.GITHUB, redirectURI: 'YOUR_APP_SCHEME://');
var result = await magic.oauth.loginWithPopup(configuration);
```

## Additional information

For more detail, please check the [Magic Link Flutter doc](https://magic.link/docs/login-methods/email/integration/flutter)
