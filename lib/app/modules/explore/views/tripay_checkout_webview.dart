import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TriPayCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  const TriPayCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    this.title = 'TriPay Checkout',
  });

  @override
  State<TriPayCheckoutWebView> createState() => _TriPayCheckoutWebViewState();
}

class _TriPayCheckoutWebViewState extends State<TriPayCheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            if (_looksLikePaymentCompleted(url)) {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _looksLikePaymentCompleted(String url) {
    return url.contains('success') ||
        url.contains('completed') ||
        url.contains('finish') ||
        url.contains('paid') ||
        url.contains('return');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}