import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:avis_package/src/core/utils/constants/app_const/app_const.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentFlowCompleted = false;
  Timer? _loadingFallbackTimer;
  Timer? _terminalPollTimer;
  bool _terminalPollInFlight = false;

  static const Duration _loadingFallbackTimeout = Duration(seconds: 25);
  static const Duration _terminalPollInterval = Duration(milliseconds: 400);

  /// PayTabs/backend often loads [PaymentSuccess] / [PaymentFailed] in an iframe; the main-frame
  /// URL stays on the gateway, so [NavigationDelegate] never sees the terminal URL. This script
  /// reads `location.href` from the top window and same-origin iframes.
  static const String _collectTerminalUrlsJs = r'''
(function() {
  function collect() {
    var urls = [];
    try { urls.push(String(window.location.href || '')); } catch (e) {}
    try {
      for (var i = 0; i < window.frames.length; i++) {
        try {
          urls.push(String(window.frames[i].location.href || ''));
        } catch (e) {}
      }
    } catch (e) {}
    return urls;
  }
  var urls = collect();
  for (var j = 0; j < urls.length; j++) {
    var u = urls[j];
    if (!u) continue;
    var l = u.toLowerCase();
    if (l.indexOf('paymentfailed') >= 0) return u;
    if (l.indexOf('paymentsuccess') >= 0) return u;
  }
  return '';
})()
''';

  /// Terminal backend URLs after PayTabs ([PaymentSuccess] / [PaymentFailed] pages).
  bool? _evaluatePaymentRedirect(String url) {
    final trimmed = url.trim();
    final lowerUrl = trimmed.toLowerCase();

    // Match full URL — reliable even when [Uri.path] or callbacks differ by platform.
    if (lowerUrl.contains('/home/paymentsuccess')) {
      return true;
    }
    if (lowerUrl.contains('/home/paymentfailed')) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final path = _normalizePath(uri.path);
    if (_pathMatches(path, AppConst.paymentRedirectFailedPath)) {
      return false;
    }
    if (_pathMatches(path, AppConst.paymentRedirectSuccessPath)) {
      return true;
    }

    // After gateway; backend redirects — do not treat PayTabs bridge URL as finished.
    if (lowerUrl.contains('paytabspaymentresponse')) {
      return null;
    }

    if (lowerUrl.contains('arbpaymentresponse') || lowerUrl.contains('mytrips')) {
      return true;
    }

    if (lowerUrl.contains('paymentfailed')) {
      return false;
    }
    if (lowerUrl.contains('paymentsuccess')) {
      return true;
    }

    return null;
  }

  static String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static bool _pathMatches(String actual, String expected) {
    final a = actual.toLowerCase();
    final e = expected.toLowerCase();
    return a == e || a.endsWith(e);
  }

  void _completePaymentFlowIfNeeded(String url) {
    if (_paymentFlowCompleted || !mounted) return;
    final result = _evaluatePaymentRedirect(url);
    if (result == null) return;
    _paymentFlowCompleted = true;
    _loadingFallbackTimer?.cancel();
    _terminalPollTimer?.cancel();
    _terminalPollTimer = null;
    log('Payment flow completing with success=$result url=$url');
    Navigator.of(context).pop(result);
  }

  void _ensureTerminalUrlPolling() {
    if (_paymentFlowCompleted || !mounted) return;
    _terminalPollTimer ??= Timer.periodic(_terminalPollInterval, (_) {
      if (!mounted || _paymentFlowCompleted || _terminalPollInFlight) return;
      _terminalPollInFlight = true;
      unawaited(_pollTerminalUrlOnce());
    });
  }

  Future<void> _pollTerminalUrlOnce() async {
    try {
      final raw = await _controller.runJavaScriptReturningResult(
        _collectTerminalUrlsJs,
      );
      final found = raw?.toString() ?? '';
      if (found.isNotEmpty) {
        log('Payment terminal URL detected via JS poll: $found');
        _completePaymentFlowIfNeeded(found);
      }
    } catch (e, st) {
      log('terminal URL poll: $e', stackTrace: st);
    } finally {
      _terminalPollInFlight = false;
    }
  }

  /// [onPageFinished] sometimes reports a different URL than what the WebView shows.
  Future<void> _resolveUrlFromController(String callbackUrl) async {
    _completePaymentFlowIfNeeded(callbackUrl);
    try {
      final current = await _controller.currentUrl();
      log('WebView currentUrl(): $current');
      if (current != null && current.isNotEmpty) {
        _completePaymentFlowIfNeeded(current);
      }
    } catch (e, st) {
      log('currentUrl() failed: $e', stackTrace: st);
    }
  }

  void _scheduleTerminalCompletion(String url) {
    void attempt() {
      if (!mounted || _paymentFlowCompleted) return;
      _completePaymentFlowIfNeeded(url);
    }

    SchedulerBinding.instance.addPostFrameCallback((_) => attempt());
    Future.microtask(attempt);
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_paymentFlowCompleted) {
        unawaited(_resolveUrlFromController(url));
      }
    });
  }

  void _clearLoadingIndicator() {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _loadingFallbackTimer?.cancel();
  }

  void _scheduleLoadingFallback() {
    _loadingFallbackTimer?.cancel();
    _loadingFallbackTimer = Timer(_loadingFallbackTimeout, _clearLoadingIndicator);
  }

  @override
  void dispose() {
    _loadingFallbackTimer?.cancel();
    _terminalPollTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress >= 100) {
              _clearLoadingIndicator();
              _ensureTerminalUrlPolling();
              unawaited(_resolveUrlFromController(''));
            } else if (progress > 0 && mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
            log('WebView onPageStarted: $url');
            _completePaymentFlowIfNeeded(url);
          },
          onPageFinished: (String url) {
            _clearLoadingIndicator();
            log('WebView onPageFinished: $url');
            _ensureTerminalUrlPolling();
            unawaited(_resolveUrlFromController(url));
          },
          onUrlChange: (UrlChange change) {
            final url = change.url;
            if (url == null || url.isEmpty) return;
            log('WebView onUrlChange: $url');
            _ensureTerminalUrlPolling();
            _completePaymentFlowIfNeeded(url);
          },
          onWebResourceError: (WebResourceError error) {
            log(
              'WebView resource error: ${error.description} (${error.errorCode}) url=${error.url}',
            );
            _clearLoadingIndicator();
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            log('WebView Navigating to: $url');

            final decision = _evaluatePaymentRedirect(url);
            if (decision != null) {
              _scheduleTerminalCompletion(url);
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _scheduleLoadingFallback();
    _controller.loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
