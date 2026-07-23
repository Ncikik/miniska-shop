import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/responsive_center.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = auth.currentUser;
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    final orders = user == null
        ? <Order>[]
        : (auth.isStaff
              ? orderProvider.allOrders
              : orderProvider.ordersForUser(user.id));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(auth.isStaff ? 'ประวัติการสั่งซื้อ (ทั้งหมด)' : 'ประวัติการสั่งซื้อ'),
        backgroundColor: kBackground,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 800,
          child: orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีประวัติการสั่งซื้อ',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(
                      order: order,
                      priceFormat: priceFormat,
                      showBuyer: auth.isStaff,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final NumberFormat priceFormat;
  final bool showBuyer;

  const _OrderCard({
    required this.order,
    required this.priceFormat,
    required this.showBuyer,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM y  HH:mm');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E1FB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'สำเร็จ',
                  style: TextStyle(
                    color: Color(0xFF1E9E5A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(order.createdAt),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          if (showBuyer) ...[
            const SizedBox(height: 2),
            Text(
              'ผู้ซื้อ: ${order.userName}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
          const Divider(height: 22),
          for (final item in order.items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 48,
                      height: 58,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: kBackground,
                          child: const Icon(
                            Icons.checkroom,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ไซส์ ${item.size} · สี ${item.color} · x${item.quantity}',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    priceFormat.format(item.totalPrice),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoLine(Icons.person_outline, order.receiverName),
                const SizedBox(height: 6),
                _infoLine(Icons.call_outlined, order.phone),
                const SizedBox(height: 6),
                _infoLine(Icons.location_on_outlined, order.address),
                const SizedBox(height: 6),
                _infoLine(Icons.payment_outlined, order.paymentMethod),
              ],
            ),
          ),
          const Divider(height: 22),
          if (order.discountCode != null)
            _summaryLine('โค้ดส่วนลด (${order.discountCode})',
                '-${priceFormat.format(order.discountAmount)}'),
          if (order.freeShipCode != null)
            _summaryLine('โค้ดส่งฟรี (${order.freeShipCode})', 'ส่งฟรี'),
          _summaryLine('ค่าจัดส่ง', priceFormat.format(order.shippingFee)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ยอดชำระทั้งหมด', style: TextStyle(fontWeight: FontWeight.w800)),
              Text(
                priceFormat.format(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: kBrandDark,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: kBrandDark),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
        ),
      ),
    ],
  );

  Widget _summaryLine(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
      ],
    ),
  );
}
