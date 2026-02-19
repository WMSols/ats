import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/widgets/app_widgets.dart';

// Direct imports - no stubs needed, conditional imports handle it
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.ui_web) 'dart:ui_web';

class AppDocumentViewer extends StatefulWidget {
  final String documentUrl;
  final String? documentName;

  const AppDocumentViewer({
    super.key,
    required this.documentUrl,
    this.documentName,
  });

  /// Shows the document viewer in a dialog
  static void show({required String documentUrl, String? documentName}) {
    Get.dialog(
      AppDocumentViewer(documentUrl: documentUrl, documentName: documentName),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  @override
  State<AppDocumentViewer> createState() => _AppDocumentViewerState();
}

/// File extensions that can be viewed in an iframe (PDF, images).
const Set<String> _viewableInIframeExtensions = {
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
};

class _AppDocumentViewerState extends State<AppDocumentViewer> {
  String? _iframeViewId;
  bool _uiWebAvailable = false;

  static bool _isViewableInIframe(String? documentName) {
    if (documentName == null || documentName.isEmpty) return true;
    final ext = documentName.split('.').last.toLowerCase();
    return _viewableInIframeExtensions.contains(ext);
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb && _isViewableInIframe(widget.documentName)) {
      _createIframe();
    }
  }

  void _createIframe() {
    if (!kIsWeb) return;

    _iframeViewId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';

    try {
      ui_web.platformViewRegistry.registerViewFactory(_iframeViewId!, (
        int viewId,
      ) {
        final iframe = html.IFrameElement()
          ..src = widget.documentUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      });
      _uiWebAvailable = true;
    } catch (e) {
      _uiWebAvailable = false;
      _iframeViewId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 1.5),
        ),
      ),
      child: Container(
        width: AppResponsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.95
            : MediaQuery.of(context).size.width * 0.85,
        height: AppResponsive.isMobile(context)
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.9,
        padding: AppSpacing.all(context, factor: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.documentName ?? AppTexts.documentFile,
                    style: AppTextStyles.bodyText(context).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.horizontal(context, 0.02),
                IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.white,
                    size: AppResponsive.iconSize(context) * 1.2,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            AppSpacing.vertical(context, 0.02),
            // Document content (iframe for PDF/images; open/download for DOCX etc.)
            Expanded(child: _buildContentView(context)),
            AppSpacing.vertical(context, 0.02),
            // Footer actions
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                TextButton.icon(
                  onPressed: () => _openInNewTab(widget.documentUrl),
                  icon: Icon(
                    Iconsax.export,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.openInNewTab,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _downloadDocument(
                    widget.documentUrl,
                    widget.documentName,
                  ),
                  icon: Icon(
                    Iconsax.document_download,
                    color: AppColors.primary,
                    size: AppResponsive.iconSize(context),
                  ),
                  label: Text(
                    AppTexts.download,
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(BuildContext context) {
    // DOCX and other non-iframe types: show open/download options
    if (kIsWeb && !_isViewableInIframe(widget.documentName)) {
      return _buildOpenDownloadPlaceholder(context);
    }

    if (!kIsWeb) {
      return _buildMobilePlaceholder(context);
    }

    // Web: show PDF/image in iframe if ui_web is available
    if (_uiWebAvailable && _iframeViewId != null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
          child: HtmlElementView(viewType: _iframeViewId!),
        ),
      );
    }

    // WebAssembly or ui_web not available - auto-open in new tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInNewTab(widget.documentUrl);
    });

    return _buildOpeningPlaceholder(context);
  }

  Widget _buildOpenDownloadPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Padding(
          padding: AppSpacing.all(context, factor: 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_text,
                size: AppResponsive.iconSize(context) * 3,
                color: AppColors.primary,
              ),
              AppSpacing.vertical(context, 0.02),
              Text(
                AppTexts.documentTypeNotSupported,
                style: AppTextStyles.bodyText(
                  context,
                ).copyWith(color: AppColors.black, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vertical(context, 0.03),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _openInNewTab(widget.documentUrl),
                    icon: Icon(
                      Iconsax.export,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.primary,
                    ),
                    label: Text(
                      AppTexts.openInNewTab,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _downloadDocument(
                      widget.documentUrl,
                      widget.documentName,
                    ),
                    icon: Icon(
                      Iconsax.document_download,
                      size: AppResponsive.iconSize(context),
                      color: AppColors.primary,
                    ),
                    label: Text(
                      AppTexts.download,
                      style: AppTextStyles.bodyText(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_text,
            size: AppResponsive.iconSize(context) * 3,
            color: AppColors.primary,
          ),
          AppSpacing.vertical(context, 0.02),
          Text(
            AppTexts.pdfViewerNotAvailable,
            style: AppTextStyles.bodyText(
              context,
            ).copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vertical(context, 0.02),
          ElevatedButton.icon(
            onPressed: () => _openInNewTab(widget.documentUrl),
            icon: Icon(Iconsax.export, size: AppResponsive.iconSize(context)),
            label: Text(
              AppTexts.openInBrowser,
              style: AppTextStyles.bodyText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.radius(context)),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              size: AppResponsive.iconSize(context) * 2,
              color: AppColors.primary,
            ),
            AppSpacing.vertical(context, 0.02),
            Text(
              AppTexts.openingInNewTab,
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openInNewTab(String url) {
    if (kIsWeb) {
      try {
        html.window.open(url, '_blank');
      } catch (e) {
        AppSnackbar.info('Please open the URL manually: $url');
      }
    } else {
      AppSnackbar.info('Please open the URL manually: $url');
    }
  }

  void _downloadDocument(String url, String? fileName) {
    if (kIsWeb) {
      try {
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName ?? 'document.pdf';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
      } catch (e) {
        _openInNewTab(url);
      }
    } else {
      AppSnackbar.info(
        'Download functionality not available on mobile. Please use the browser.',
      );
    }
  }
}
