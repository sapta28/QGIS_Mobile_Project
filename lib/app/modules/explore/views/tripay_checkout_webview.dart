import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

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
      ..setUserAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('TriPayCheckoutWebView started loading: $url');
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (url) {
            debugPrint('TriPayCheckoutWebView finished loading: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('TriPayCheckoutWebView resource error: ${error.description}, code: ${error.errorCode}, type: ${error.errorType}');
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            debugPrint('TriPayCheckoutWebView navigation request to: $url');
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
      ..loadRequest(Uri.parse(_normalizeUrl(widget.checkoutUrl)));
  }

  String _normalizeUrl(String url) {
    return url;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Buka di Browser',
            onPressed: () async {
              final uri = Uri.tryParse(_normalizeUrl(widget.checkoutUrl));
              if (uri != null) {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar('Payment', 'Tidak dapat membuka browser.');
                }
              } else {
                Get.snackbar('Payment', 'Link pembayaran tidak valid.');
              }
            },
          ),
        ],
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