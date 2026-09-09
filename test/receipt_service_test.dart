import 'package:flutter_test/flutter_test.dart';
import 'package:may_snacks/models/order.dart';
import 'package:may_snacks/models/customer.dart';
import 'package:may_snacks/services/receipt_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReceiptService Tests', () {
    late Order testOrder;
    late Customer testCustomer;

    setUp(() {
      testOrder = Order(
        id: 'ord-12345678-abcd',
        customerName: 'Shwe Pyi Mart',
        customerId: 'cust-1',
        status: OrderStatus.pending,
        salesStaffId: 'staff-1',
        createdAt: DateTime(2026, 9, 9, 10, 30),
        items: [
          OrderItem(
            id: 'item-1',
            orderId: 'ord-12345678-abcd',
            productId: 'p-1',
            quantity: 5,
            productName: 'Crispy Potato Crackers 100g',
            productPrice: 1500,
          ),
          OrderItem(
            id: 'item-2',
            orderId: 'ord-12345678-abcd',
            productId: 'p-2',
            quantity: 10,
            productName: 'Spicy Bean Sticks 50g',
            productPrice: 800,
          ),
        ],
      );

      testCustomer = Customer(
        id: 'cust-1',
        name: 'Shwe Pyi Mart',
        region: 'Yangon Region',
        township: 'Hledan',
        phone: '0912345678',
        status: CustomerStatus.approved,
        createdAt: DateTime(2026, 1, 1),
      );
    });

    test('generates valid 58mm PDF receipt bytes', () async {
      final bytes = await ReceiptService.generateReceiptPdf(
        order: testOrder,
        customer: testCustomer,
        staffName: 'U Mg Mg (Sales)',
        paperSize: ReceiptPaperSize.mm58,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
      expect(testOrder.totalAmount, equals(5 * 1500 + 10 * 800)); // 15,500
    });

    test('generates valid 80mm PDF receipt bytes', () async {
      final bytes = await ReceiptService.generateReceiptPdf(
        order: testOrder,
        customer: testCustomer,
        staffName: 'U Mg Mg (Sales)',
        paperSize: ReceiptPaperSize.mm80,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('generates raw ESC/POS byte sequence', () async {
      final escPosBytes = await ReceiptService.generateEscPosBytes(
        order: testOrder,
        customer: testCustomer,
        staffName: 'U Mg Mg (Sales)',
        paperSize: ReceiptPaperSize.mm58,
      );

      expect(escPosBytes, isNotEmpty);
      expect(escPosBytes.length, greaterThan(50));
    });
  });
}
