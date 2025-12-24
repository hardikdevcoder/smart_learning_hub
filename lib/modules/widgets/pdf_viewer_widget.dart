import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/values/app_colors.dart';

class PDFViewerWidget extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerWidget({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_totalPages > 0) _buildPageIndicator(),
        Expanded(
          child: Stack(
            children: [
              SfPdfViewer.network(
                widget.url,
                controller: _pdfViewerController,
                onDocumentLoaded: (details) {
                  setState(() {
                    _isLoading = false;
                    _totalPages = details.document.pages.count;
                  });
                },
                onDocumentLoadFailed: (details) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                  });
                  print('PDF load failed: ${details.error}');
                },
                onPageChanged: (details) {
                  setState(() {
                    _currentPage = details.newPageNumber;
                  });
                },
              ),
              if (_isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading PDF...'),
                      ],
                    ),
                  ),
                ),
              if (_hasError) _buildErrorState(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please make sure the URL is a direct link to a PDF file',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
