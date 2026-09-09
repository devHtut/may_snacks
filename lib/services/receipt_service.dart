import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/models/customer.dart';

enum ReceiptPaperSize {
  mm58, // 58mm (2-inch pocket printer)
  mm80, // 80mm (3-inch standard POS printer)
}

class ReceiptService {
  static const String storeName = 'MAY SNACKS';
  static const String storeTagline = 'Wholesale & Retail Snack Distribution';
  static const String storePhone = '09-777888999, 09-444555666';
  static const String storeAddress = 'Kamayut Township, Yangon, Myanmar';

  /// Generate a PDF document optimized for thermal receipt rolls (58mm or 80mm)
  static Future<Uint8List> generateReceiptPdf({
    required Order order,
    Customer? customer,
    String? staffName,
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) async {
    final pdf = pw.Document();

    // 58mm is ~164pt printable, 80mm is ~226pt printable
    final double rollWidth = paperSize == ReceiptPaperSize.mm58 ? 58 * PdfPageFormat.mm : 80 * PdfPageFormat.mm;
    final double margin = paperSize == ReceiptPaperSize.mm58 ? 8 : 12;
    final double baseFontSize = paperSize == ReceiptPaperSize.mm58 ? 8.5 : 10.0;
    final double titleFontSize = paperSize == ReceiptPaperSize.mm58 ? 13.0 : 16.0;

    final numberFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          rollWidth,
          double.infinity, // roll paper has dynamic length
          marginAll: margin,
        ),
        build: (pw.Context context) {
          final totalUnits = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Store Header
              pw.Center(
                child: pw.Text(
                  storeName,
                  style: pw.TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  storeTagline,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 1.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Tel: $storePhone',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 1.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  storeAddress,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2.0,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),

              // Dashed divider
              _buildDashedLine(),
              pw.SizedBox(height: 4),

              // Title
              pw.Center(
                child: pw.Text(
                  'SALES ORDER RECEIPT',
                  style: pw.TextStyle(
                    fontSize: baseFontSize + 1,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              // Order Metadata
              _buildMetaRow('Invoice #:', order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase(), baseFontSize),
              _buildMetaRow('Date:', dateFormat.format(order.createdAt), baseFontSize),
              if (staffName != null && staffName.isNotEmpty)
                _buildMetaRow('Sales Staff:', staffName, baseFontSize),
              _buildMetaRow('Customer:', order.customerName, baseFontSize),
              if (customer != null && customer.phone.isNotEmpty)
                _buildMetaRow('Cust Phone:', customer.phone, baseFontSize),
              if (customer != null && customer.township.isNotEmpty)
                _buildMetaRow('Location:', '${customer.township}, ${customer.region}', baseFontSize),
              _buildMetaRow('Status:', order.status.displayName, baseFontSize),

              pw.SizedBox(height: 6),
              _buildDashedLine(),
              pw.SizedBox(height: 4),

              // Item Headers
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(
                      'ITEM',
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 0.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'QTY',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 0.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'TOTAL',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: baseFontSize - 0.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              _buildDashedLine(),
              pw.SizedBox(height: 4),

              // Items List
              ...order.items.map((item) {
                final price = item.productPrice ?? 0.0;
                final lineTotal = item.quantity * price;
                final productName = item.productName ?? 'Product';

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        productName,
                        style: pw.TextStyle(
                          fontSize: baseFontSize,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              '@ Ks ${numberFormat.format(price)}',
                              style: pw.TextStyle(
                                fontSize: baseFontSize - 1.5,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              '${item.quantity}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: baseFontSize - 0.5,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              'Ks ${numberFormat.format(lineTotal)}',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: baseFontSize - 0.5,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 4),
              _buildDashedLine(),
              pw.SizedBox(height: 4),

              // Summary
              _buildSummaryRow('Total Items:', '${order.items.length} ($totalUnits pcs)', baseFontSize, false),
              _buildSummaryRow(
                'GRAND TOTAL:',
                'Ks ${numberFormat.format(order.totalAmount)}',
                baseFontSize + 1.5,
                true,
              ),

              pw.SizedBox(height: 6),
              _buildDashedLine(),
              pw.SizedBox(height: 8),

              // QR Code of Order ID
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'MAYSNACKS-ORDER:${order.id}',
                  width: paperSize == ReceiptPaperSize.mm58 ? 45 : 60,
                  height: paperSize == ReceiptPaperSize.mm58 ? 45 : 60,
                ),
              ),
              pw.SizedBox(height: 6),

              // Footer Message
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 1.0,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'May Snacks Co., Ltd.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: baseFontSize - 2.0,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMetaRow(String label, String value, double fontSize) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize - 1.0,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: fontSize - 0.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, double fontSize, bool isBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDashedLine() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey500,
            width: 0.8,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    );
  }

  /// Print receipt directly or open system print dialog
  static Future<void> printReceipt({
    required Order order,
    Customer? customer,
    String? staffName,
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) async {
    final rollWidth = paperSize == ReceiptPaperSize.mm58 ? 58 * PdfPageFormat.mm : 80 * PdfPageFormat.mm;
    await Printing.layoutPdf(
      name: 'Receipt_${order.id.substring(0, 8)}',
      format: PdfPageFormat(rollWidth, double.infinity, marginAll: 8),
      onLayout: (PdfPageFormat format) async {
        return generateReceiptPdf(
          order: order,
          customer: customer,
          staffName: staffName,
          paperSize: paperSize,
        );
      },
    );
  }

  /// Share receipt as PDF file via System Share (e.g., Viber, Telegram, Email)
  static Future<void> shareReceipt({
    required Order order,
    Customer? customer,
    String? staffName,
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) async {
    final pdfBytes = await generateReceiptPdf(
      order: order,
      customer: customer,
      staffName: staffName,
      paperSize: paperSize,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'MaySnacks_Receipt_${order.id.substring(0, 8)}.pdf',
    );
  }

  /// Generate raw ESC/POS byte sequence for direct Bluetooth/Network thermal printers
  static Future<List<int>> generateEscPosBytes({
    required Order order,
    Customer? customer,
    String? staffName,
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == ReceiptPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];
    final numberFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    bytes += generator.reset();
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      storeTagline,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Tel: $storePhone',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      storeAddress,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');

    bytes += generator.text(
      'SALES ORDER RECEIPT',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Invoice: ${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
    );
    bytes += generator.text('Date: ${dateFormat.format(order.createdAt)}');
    if (staffName != null) bytes += generator.text('Staff: $staffName');
    bytes += generator.text('Customer: ${order.customerName}');
    if (customer != null && customer.phone.isNotEmpty) {
      bytes += generator.text('Phone: ${customer.phone}');
    }
    bytes += generator.hr(ch: '-');

    // Headers
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
      PosColumn(text: 'Total', width: 4, styles: const PosStyles(bold: true, align: PosAlign.right)),
    ]);
    bytes += generator.hr(ch: '-');

    for (final item in order.items) {
      final price = item.productPrice ?? 0.0;
      final lineTotal = item.quantity * price;
      bytes += generator.text(item.productName ?? 'Product', styles: const PosStyles(bold: true));
      bytes += generator.row([
        PosColumn(text: '@${numberFormat.format(price)}', width: 5),
        PosColumn(text: '${item.quantity}', width: 3, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: numberFormat.format(lineTotal), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.row([
      PosColumn(text: 'GRAND TOTAL:', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(
        text: 'Ks ${numberFormat.format(order.totalAmount)}',
        width: 6,
        styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size2),
      ),
    ]);
    bytes += generator.hr(ch: '=');

    bytes += generator.qrcode('MAYSNACKS-ORDER:${order.id}');
    bytes += generator.text(
      'Thank you for your business!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
