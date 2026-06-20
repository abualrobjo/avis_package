import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:avis_package/src/core/utils/terms_pdf_helper.dart';

class TermsAndConditionsPdfPage extends StatefulWidget {
  const TermsAndConditionsPdfPage({super.key, required this.pdfUrl});

  final String pdfUrl;

  @override
  State<TermsAndConditionsPdfPage> createState() =>
      _TermsAndConditionsPdfPageState();
}

class _TermsAndConditionsPdfPageState extends State<TermsAndConditionsPdfPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == false) return;
            if (!mounted || _errorMessage != null) return;
            setState(() {
              _isLoading = false;
              _errorMessage = 'Could not load Terms & Conditions PDF.';
            });
          },
        ),
      );
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await TermsPdfHelper.loadPdfInWebView(_controller, widget.pdfUrl);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load Terms & Conditions PDF.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadPdf,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
