import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class FlutterFlowPdfViewer extends StatelessWidget {
  const FlutterFlowPdfViewer({
    super.key,
    this.networkPath,
    this.assetPath,
    this.fileBytes,
    this.width,
    this.height,
    this.horizontalScroll = false,
  }) : assert(
            (networkPath != null) ^ (assetPath != null) ^ (fileBytes != null));

  final String? networkPath;
  final String? assetPath;
  final Uint8List? fileBytes;
  final double? width;
  final double? height;
  final bool horizontalScroll;

  @override
  Widget build(BuildContext context) {
    final params = PdfViewerParams(
      layoutPages: horizontalScroll ? _horizontalLayout : null,
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
          const Center(child: CircularProgressIndicator()),
      errorBannerBuilder: (context, error, stackTrace, documentRef) => Container(),
    );

    final viewer = networkPath != null && networkPath!.isNotEmpty
        ? PdfViewer.uri(Uri.parse(networkPath!), params: params)
        : assetPath != null && assetPath!.isNotEmpty
            ? PdfViewer.asset(assetPath!, params: params)
            : fileBytes != null && fileBytes!.isNotEmpty
                ? PdfViewer.data(fileBytes!, sourceName: networkPath ?? assetPath ?? 'fileBytes', params: params)
                : null;

    return SizedBox(
      width: width,
      height: height,
      child: viewer ?? const SizedBox(),
    );
  }

  static PdfPageLayout _horizontalLayout(List<PdfPage> pages, PdfViewerParams params) {
    final height = pages.fold(0.0, (prev, page) => max(prev, page.height)) + params.margin * 2;
    final pageLayouts = <Rect>[];
    double x = params.margin;
    for (final page in pages) {
      pageLayouts.add(Rect.fromLTWH(x, (height - page.height) / 2, page.width, page.height));
      x += page.width + params.margin;
    }
    return PdfPageLayout(pageLayouts: pageLayouts, documentSize: Size(x, height));
  }
}
