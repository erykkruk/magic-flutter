## 6.1.0

* Add `MagicRelayerDiagnostics`, an observability hook for the relayer
  WebView. The relayer is where logins actually happen, and when it fails it
  fails quietly: a login call queues a message and waits for a reply that
  never comes. Register `MagicRelayerDiagnostics.onError` to see those
  failures instead of losing them to the console.
* Report `MagicRelayerErrorKind.urlUnavailable` when the relayer URL cannot
  be built or resolves to null. This is the state that looks like "OAuth
  hangs": the WebView never loads, so every login queues forever. It
  previously only reached `print`.
* Report `MagicRelayerErrorKind.responseUndecodable` for unparseable relayer
  messages, with the original error and stack trace attached.
* Fix a latent crash in `handleResponse`: a response whose id had no pending
  request dereferenced a null completer. It is now reported as
  `MagicRelayerErrorKind.orphanedResponse` and ignored.
* Remove the `print` call from the relayer; all reporting goes through the
  diagnostics hook, which falls back to `debugPrint` when no handler is set.
* Add the first tests to the package (10, covering the diagnostics
  contract).

Behaviour of the login flow itself is unchanged: this release only adds
reporting and removes a null dereference.

## 6.0.1
First release of `magic_flutter_v2`, a maintained fork of `magic_sdk` 6.0.1
(magiclabs/magic-flutter).

* Fix: keep the relayer WebView alive on iOS without blocking the host app.
  Upstream renders the relayer with `Visibility(visible: false)` while idle,
  which iOS treats as offstage and suspends its web content process, so
  `box.magic.link` never emits `MAGIC_OVERLAY_READY` and `loginWithOAuth` /
  the first `loginWithEmailOTP` hang forever. The WebView now stays attached
  and painted, shrunk to a 1x1 pointer-ignoring box while hidden, and expands
  to full size only while the overlay is visible.
* Public API is unchanged from upstream 6.0.1.

## 4.1.0
Prevents "Device requesting login is not supported" for Flutter SDKs 

## 2.0.1
Add missing signToEcSignature to MagicCredential

## 2.0.0
Deprecation of Rinkeby, Kovan, Ropsten
Add Goerli

## 1.2.2
Fix unable to access testnet 

## 1.2.1
Fix url for local development

## 1.2.0 
(Retracted)
Make rpcUrl accessible in providers
Add new RPCRequest params type

## 1.1.1

Fix Relayer Request has wrong encodedParams 

## 1.1.0

Enable Bundle Id whitelisting 

## 1.0.0

Major version bump for stable release 🚀

## 0.6.0

Supports multi-blockchain
* Tezos (via Tezart)

## 0.5.0

Supports LoginWithEmailOTP

## 0.4.0

Supports LoginWithSMS

## 0.3.2

Fix build fail, due to web3dart signToSignature api breaking change

## 0.3.0

* Add support for Social Login

## 0.2.0

* Magic SDK supports web3dart
    * sendTransaction
    * getAccount
    * Contract

## 0.1.0

* Magic SDK Core release
