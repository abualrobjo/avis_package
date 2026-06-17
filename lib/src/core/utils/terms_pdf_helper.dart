import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

enum TermsPdfOpenOutcome {
  openedLocally,
  openedInBrowser,
  failed,
}

class TermsPdfHelper {
  TermsPdfHelper._();

  static Future<String?> downloadToTempFile(String pdfUrl) async {
    final savePath =
        '${Directory.systemTemp.path}/terms_and_conditions_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final downloaded = await _downloadPdf(pdfUrl, savePath);
    return downloaded ? savePath : null;
  }

  static Future<TermsPdfOpenOutcome> downloadAndOpen(String pdfUrl) async {
    final savePath =
        '${Directory.systemTemp.path}/terms_and_conditions_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final downloaded = await _downloadPdf(pdfUrl, savePath);
    if (!downloaded) {
      final launched = await _openInBrowser(pdfUrl);
      return launched ? TermsPdfOpenOutcome.openedInBrowser : TermsPdfOpenOutcome.failed;
    }

    final openResult = await OpenFile.open(savePath);
    if (openResult.type == ResultType.done) {
      return TermsPdfOpenOutcome.openedLocally;
    }

    if (kDebugMode) {
      debugPrint(
        'Terms PDF local open failed (${openResult.type}): ${openResult.message}',
      );
    }

    final launched = await _openInBrowser(pdfUrl);
    return launched ? TermsPdfOpenOutcome.openedInBrowser : TermsPdfOpenOutcome.failed;
  }

  static Future<bool> _downloadPdf(String url, String savePath) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: const {'Accept': '*/*'},
        ),
      );
      await dio.download(url, savePath);
      final file = File(savePath);
      return file.existsSync() && await file.length() > 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Terms PDF download failed: $e');
      }
      return false;
    }
  }

  static Future<bool> _openInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
