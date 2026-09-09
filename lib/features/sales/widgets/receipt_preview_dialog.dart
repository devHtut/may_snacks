import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/services/receipt_service.dart';

class ReceiptPreviewDialog extends StatefulWidget {
  final Order order;
  final Customer? customer;
  final String? staffName;

  const ReceiptPreviewDialog({
    super.key,
    required this.order,
    this.customer,
    this.staffName,
  });

  static Future<void> show(
    BuildContext context, {
    required Order order,
    Customer? customer,
    String? staffName,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ReceiptPreviewDialog(
        order: order,
        customer: customer,
        staffName: staffName,
      ),
    );
  }

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  ReceiptPaperSize _paperSize = ReceiptPaperSize.mm58;
  bool _isActionInProgress = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortOrderId = widget.order.id.length > 8
        ? widget.order.id.substring(0, 8).toUpperCase()
        : widget.order.id.toUpperCase();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thermal Receipt Preview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Invoice #$shortOrderId | ${widget.order.customerName}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Paper Size Toggle Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Text(
                    'Paper Size:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('58mm (2")', style: TextStyle(fontSize: 12)),
                    selected: _paperSize == ReceiptPaperSize.mm58,
                    onSelected: (selected) {
                      if (selected) setState(() => _paperSize = ReceiptPaperSize.mm58);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('80mm (3")', style: TextStyle(fontSize: 12)),
                    selected: _paperSize == ReceiptPaperSize.mm80,
                    onSelected: (selected) {
                      if (selected) setState(() => _paperSize = ReceiptPaperSize.mm80);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Live Receipt PDF Preview
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                child: PdfPreview(
                  build: (format) => ReceiptService.generateReceiptPdf(
                    order: widget.order,
                    customer: widget.customer,
                    staffName: widget.staffName,
                    paperSize: _paperSize,
                  ),
                  allowPrinting: false,
                  allowSharing: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  maxPageWidth: _paperSize == ReceiptPaperSize.mm58 ? 260 : 360,
                  previewPageMargin: const EdgeInsets.all(12),
                  scrollViewDecoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  pdfFileName: 'MaySnacks_Receipt_$shortOrderId.pdf',
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Share as PDF button (for Viber, Telegram, etc.)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isActionInProgress
                          ? null
                          : () async {
                              setState(() => _isActionInProgress = true);
                              try {
                                await ReceiptService.shareReceipt(
                                  order: widget.order,
                                  customer: widget.customer,
                                  staffName: widget.staffName,
                                  paperSize: _paperSize,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isActionInProgress = false);
                                }
                              }
                            },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Print Receipt Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isActionInProgress
                          ? null
                          : () async {
                              setState(() => _isActionInProgress = true);
                              try {
                                await ReceiptService.printReceipt(
                                  order: widget.order,
                                  customer: widget.customer,
                                  staffName: widget.staffName,
                                  paperSize: _paperSize,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isActionInProgress = false);
                                }
                              }
                            },
                      icon: _isActionInProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print_rounded, size: 18),
                      label: Text(
                        _isActionInProgress ? 'Printing...' : 'Print Receipt',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
