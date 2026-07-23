import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_center.dart';

class OrdersAdminScreen extends StatelessWidget {
  const OrdersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().allOrders;
    final dateFormat = DateFormat('d MMM yyyy · HH:mm', 'th_TH');
    final priceFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('ออเดอร์ทั้งหมด')),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 900,
          child: orders.isEmpty
              ? const Center(child: Text('ยังไม่มีออเดอร์'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _AdminOrderTile(
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

class _AdminOrderTile extends StatelessWidget {
  final Order order;
  final DateFormat dateFormat;
  final NumberFormat priceFormat;

  const _AdminOrderTile({
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id.substring(order.id.length - 6)} · ${order.userName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                priceFormat.format(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kBrandPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} รายการ · ${order.paymentMethod}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<OrderStatus>(
            value: order.status,
            decoration: const InputDecoration(
              labelText: 'สถานะ',
              isDense: true,
            ),
            items: OrderStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(_statusLabel(s)),
                  ),
                )
                .toList(),
            onChanged: (status) {
              if (status != null) {
                context.read<OrderProvider>().updateStatus(order.id, status);
              }
            },
          ),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus s) => switch (s) {
        OrderStatus.pending => 'รอชำระ',
        OrderStatus.paid => 'ชำระแล้ว',
        OrderStatus.shipped => 'จัดส่งแล้ว',
        OrderStatus.delivered => 'สำเร็จ',
        OrderStatus.cancelled => 'ยกเลิก',
      };
}
