import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../provider/types/relayer_request.dart';
import '../../provider/types/relayer_response.dart';
import '../../provider/types/rpc_response.dart';
import '../../relayer/url_builder.dart';

part '../provider/types/inbound_message.dart';

class WebViewRelayer extends StatefulWidget {
  final Map<int, Completer> _messageHandlers = {};
  final List<RelayerRequest> _queue = [];

  bool _overlayReady = false;
  bool _isOverlayVisible = false;

  final WebViewController _webViewCtrl = WebViewController();

  void enqueue(
      {required RelayerRequest relayerRequest,
      required int id,
      required Completer completer}) {
    _queue.add(relayerRequest);
    _messageHandlers[id] = completer;
    _dequeue();
  }

  void _dequeue() {
    if (_queue.isNotEmpty && _overlayReady) {
      var message = _queue.removeAt(0);
      var messageMap = message.toJson((value) => value);
      //double encoding results in extra backslash. Remove them
      String jsonString =
          json.encode({"data": messageMap}).replaceAll("\\", "");
      // debugPrint("Send Message ===> \n $jsonString");

      _webViewCtrl.runJavaScript(
          "window.dispatchEvent(new MessageEvent('message', $jsonString));");

      // Recursively dequeue till queue is Empty
      _dequeue();
    }
  }

  void showOverlay() {
    _isOverlayVisible = true;
  }

  void hideOverlay() {
    _isOverlayVisible = false;
  }

  void handleResponse(JavaScriptMessage message) {
    try {
      var json = message.decode();

      // parse JSON into General RelayerResponse to fetch id first, result will handled in the function interface
      RelayerResponse relayerResponse =
          RelayerResponse<dynamic>.fromJson(json, (result) => result);
      MagicRPCResponse rpcResponse = relayerResponse.response;

      var result = rpcResponse.result;
      var id = rpcResponse.id;

      // get callbacks in the handlers map
      var completer = _messageHandlers[id];

      // Surface the Raw JavaScriptMessage back to the function call so it can converted back to Result type
      // Only decode when result is not null, so the result is not null
      if (result != null) {
        completer!.complete(message);
      }

      if (rpcResponse.error != null) {
        completer!.completeError(rpcResponse.error!.toJson());
      }
    } catch (err) {
      //Todo Add internal error collector
      debugPrint("parse Error ${err.toString()}");
    }
  }

  WebViewRelayer({Key? key}) : super(key: key);

  @override
  WebViewRelayerState createState() => WebViewRelayerState();
}

class WebViewRelayerState extends State<WebViewRelayer> {
  String? url;

  @override
  void initState() {
    super.initState();
    initializeURL();
  }

  Future<void> initializeURL() async {
    try {
      url = await URLBuilder.instance.url;
      if (url != null) {
        loadWebView();
      } else {
        setState(() {
          // Show an error message or handle the absence of URL
        });
      }
    } catch (error) {
      print('Error occurred: $error');
      setState(() {
        // Show an error message or handle the error
      });
    }
  }

  void loadWebView() {
    // enable inspector
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      final double? iosVersion = double.tryParse(Platform.operatingSystemVersion.split(' ')[1]);

      if (iosVersion != null && iosVersion >= 16.0) {  // setInspectable isn't avaliable in earlier iOS versions
        final WebKitWebViewController webKitController =
        widget._webViewCtrl.platform as WebKitWebViewController;
        webKitController.setInspectable(true);
      }
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      AndroidWebViewController.enableDebugging(true);
    }

    widget._webViewCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
    // Transparent so the always-rendered relayer does not paint an opaque
    // white surface over the host app while the overlay is idle.
    widget._webViewCtrl.setBackgroundColor(const Color(0x00000000));
    widget._webViewCtrl.removeJavaScriptChannel("magicFlutter");
    widget._webViewCtrl.addJavaScriptChannel('magicFlutter',
        onMessageReceived: (JavaScriptMessage message) {
      onMessageReceived(message);
    });
    widget._webViewCtrl.loadRequest(Uri.parse(url!));
  }

  void onMessageReceived(JavaScriptMessage message) {
    // debugPrint("Received message <=== \n ${message.message}");

    if (message.getMsgType() ==
        InboundMessageType.MAGIC_OVERLAY_READY.toShortString()) {
      widget._overlayReady = true;
      widget._dequeue();
    } else if (message.getMsgType() ==
        InboundMessageType.MAGIC_SHOW_OVERLAY.toShortString()) {
      setState(() {
        // setState can only be accessed in this context
        widget._isOverlayVisible = true;
      });
    } else if (message.getMsgType() ==
        InboundMessageType.MAGIC_HIDE_OVERLAY.toShortString()) {
      setState(() {
        widget._isOverlayVisible = false;
      });
    } else if (message.getMsgType() ==
        InboundMessageType.MAGIC_HANDLE_EVENT.toShortString()) {
      //Todo PromiseEvent
    } else if (message.getMsgType() ==
        InboundMessageType.MAGIC_HANDLE_RESPONSE.toShortString()) {
      widget.handleResponse(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webView = WebViewWidget(controller: widget._webViewCtrl);

    // When the Magic overlay is visible (e.g. the email-OTP modal) render it
    // full size so the user can interact with it.
    if (widget._isOverlayVisible) {
      return webView;
    }

    // When the overlay is hidden, the WKWebView must stay attached and PAINTED:
    // the original Visibility(visible:false) took it Offstage (zero-size, not
    // painted), and iOS then suspends its web content process so box.magic.link
    // never emits MAGIC_OVERLAY_READY and relayer RPCs (loginWithOAuth result
    // parsing, the first email-OTP) hang forever.
    //
    // But a full-size WebView on top of the app would block touches to the
    // content below it — IgnorePointer does NOT pass touches through a native
    // platform view to another platform view underneath (e.g. an in-app
    // WebView), so those screens become un-tappable. Shrink it to 1x1 instead:
    // still attached/painted (stays alive) yet effectively invisible and
    // non-blocking. It expands to full size only when the overlay is shown.
    return IgnorePointer(
      child: SizedBox(width: 1, height: 1, child: webView),
    );
  }
}

/// Extended utilities to help to decode JS Message
extension MessageType on JavaScriptMessage {
  Map<String, dynamic> decode() {
    return json.decode(message);
  }

  String getMsgType() {
    var json = decode();
    var msgType = json['msgType'].split('-').first;
    return msgType;
  }
}
