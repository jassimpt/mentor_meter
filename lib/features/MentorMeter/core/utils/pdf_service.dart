import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:web_scoket/features/MentorMeter/modules/reviewForm/models/review_model.dart';

class PdfService {
  /// Generate and save review report PDF
  static Future<File> generateReviewReport({
    required List<ReviewModel> reviews,
    required double paymentPerReview,
  }) async {
    final pdf = pw.Document();

    // Calculate statistics
    final totalReviews = reviews.length;
    final totalPayment = totalReviews * paymentPerReview;

    // Load font for Unicode support
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final font = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // Header Section
            _buildHeader(boldFont, font),
            pw.SizedBox(height: 30),

            // Dashboard Statistics
            _buildDashboard(totalReviews, totalPayment, boldFont, font),
            pw.SizedBox(height: 30),

            // Table Section
            _buildTableHeader(boldFont),
            pw.SizedBox(height: 10),
            _buildTable(reviews, boldFont, font),

            // Footer
            pw.SizedBox(height: 20),
            _buildFooter(font),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                font: font,
              ),
            ),
          );
        },
      ),
    );

    // Save the PDF
    return await _savePdf(pdf);
  }

  /// Build PDF Header
  static pw.Widget _buildHeader(pw.Font boldFont, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [
            PdfColor.fromInt(0xFF4F46E5), // Indigo-600
            PdfColor.fromInt(0xFF6366F1), // Indigo-500
          ],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Review Reports',
            style: pw.TextStyle(
              fontSize: 28,
              font: boldFont,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: const PdfColor.fromInt(0xFFE6E6E6),
              font: font,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Dashboard Statistics
  static pw.Widget _buildDashboard(
    int totalReviews,
    double totalPayment,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildStatCard(
            title: 'Total Reviews',
            value: totalReviews.toString(),
            label: 'Reviews',
            color: const PdfColor.fromInt(0xFF10B981), // Green-500
            boldFont: boldFont,
            font: font,
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: _buildStatCard(
            title: 'Total Payment',
            value: 'Rs ${totalPayment.toStringAsFixed(0)}',
            label: 'Payment',
            color: const PdfColor.fromInt(0xFF8B5CF6), // Purple-500
            boldFont: boldFont,
            font: font,
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  static pw.Widget _buildStatCard({
    required String title,
    required String value,
    required String label,
    required PdfColor color,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          pw.BoxShadow(
            color: _getColorWithOpacity(PdfColors.black, 0.05),
            offset: const PdfPoint(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: const PdfColor.fromInt(0xFF6B7280),
                    font: font,
                  ),
                ),
              ),
              pw.Container(
                width: 36,
                height: 36,
                decoration: pw.BoxDecoration(
                  color: _getColorWithOpacity(color, 0.1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    label[0].toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: color,
                      font: boldFont,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 32,
              font: boldFont,
              color: const PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            height: 3,
            width: 40,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to create PdfColor with opacity
  static PdfColor _getColorWithOpacity(PdfColor color, double opacity) {
    final alpha = (opacity * 255).round();
    final red = color.red;
    final green = color.green;
    final blue = color.blue;
    
    return PdfColor(red, green, blue, alpha / 255.0);
  }

  /// Build table header
  static pw.Widget _buildTableHeader(pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0xFF4F46E5),
            width: 2,
          ),
        ),
      ),
      child: pw.Text(
        'Review Details',
        style: pw.TextStyle(
          fontSize: 18,
          font: boldFont,
          color: const PdfColor.fromInt(0xFF1F2937),
        ),
      ),
    );
  }

  /// Build reviews table
  static pw.Widget _buildTable(
    List<ReviewModel> reviews,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: const PdfColor.fromInt(0xFFE5E7EB),
        width: 1,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2.5),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF4F46E5),
          ),
          children: [
            _buildTableCell('Date', isHeader: true, boldFont: boldFont, font: font),
            _buildTableCell('Mentor Name', isHeader: true, boldFont: boldFont, font: font),
            _buildTableCell('Intern Name', isHeader: true, boldFont: boldFont, font: font),
            _buildTableCell('Review Topic', isHeader: true, boldFont: boldFont, font: font),
          ],
        ),
        // Table Rows
        ...reviews.asMap().entries.map((entry) {
          final index = entry.key;
          final review = entry.value;
          final isEven = index % 2 == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven
                  ? const PdfColor.fromInt(0xFFF9FAFB)
                  : PdfColors.white,
            ),
            children: [
              _buildTableCell(
                DateFormat('dd/MM/yyyy').format(review.reviewDate),
                boldFont: boldFont,
                font: font,
              ),
              _buildTableCell(review.mentorName, boldFont: boldFont, font: font),
              _buildTableCell(review.internName, boldFont: boldFont, font: font),
              _buildTableCell(review.reviewTopic, boldFont: boldFont, font: font),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    required pw.Font boldFont,
    required pw.Font font,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          font: isHeader ? boldFont : font,
          color: isHeader
              ? PdfColors.white
              : const PdfColor.fromInt(0xFF374151),
        ),
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFE5E7EB),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '© ${DateTime.now().year} MentorMeter',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              font: font,
            ),
          ),
          pw.Text(
            'Confidential Document',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              font: font,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Save PDF to device
  static Future<File> _savePdf(pw.Document pdf) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/review_report_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Generate and open PDF
  static Future<void> generateAndOpenReport({
    required List<ReviewModel> reviews,
    required double paymentPerReview,
  }) async {
    try {
      final file = await generateReviewReport(
        reviews: reviews,
        paymentPerReview: paymentPerReview,
      );
      
      // Open the PDF file
      await OpenFilex.open(file.path);
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }
}