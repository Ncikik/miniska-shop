import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final orders = context.watch<OrderProvider>().ordersForUser(user.id);
    final dateFormat = DateFormat('d MMM yyyy · HH:mm', 'th_TH');
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('ประวัติการซื้อ')),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 800,
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ยังไม่มีประวัติการซื้อ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _OrderCard(
                    order: orders[index],
                    dateFormat: dateFormat,
                    priceFormat: priceFormat,
                  ),
                ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final DateFormat dateFormat;
  final NumberFormat priceFormat;

  const _OrderCard({
    required this.order,
    required this.dateFormat,
    required this.priceFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ออเดอร์ #${order.id.substring(order.id.length - 6)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _statusChip(order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(order.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const Divider(height: 20),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} (${item.size}/${item.color}) x${item.quantity}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    priceFormat.format(item.totalPrice),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          // แก้จาก order.promoCode -> order.discountCode ให้ตรงกับชื่อ field จริงในโมเดล Order
          if (order.discountCode != null) ...[
            const SizedBox(height: 4),
            Text(
              'โค้ด: ${order.discountCode}',
              style: const TextStyle(fontSize: 12, color: kBrandPurple),
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ยอดชำระ'),
              Text(
                // แก้จาก order.grandTotal -> order.total ให้ตรงกับชื่อ field จริงในโมเดล Order
                priceFormat.format(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kBrandPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(OrderStatus status) {
    final color = switch (status) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.paid => kBrandBlue,
      OrderStatus.shipped => kBrandPurple,
      OrderStatus.delivered => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
