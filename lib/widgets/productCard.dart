import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/productService.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey2.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: data['hinhanh'] != null && data['hinhanh'].isNotEmpty
                  ? Image.network(
                data['hinhanh'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: CupertinoColors.systemGrey5,
                    child: const Center(
                      child: Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemGrey),
                    ),
                  );
                },
              )
                  : Container(
                color: CupertinoColors.systemGrey5,
                child: const Center(
                  child: Icon(CupertinoIcons.photo_on_rectangle, size: 30, color: CupertinoColors.systemGrey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['tensanpham'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text('Loại: ${data['loaisp']}', style: const TextStyle(color: CupertinoColors.secondaryLabel)),
                const SizedBox(height: 2),
                Text(
                  'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(data['gia'])}',
                  style: const TextStyle(color: CupertinoColors.activeGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.pencil, color: CupertinoColors.activeOrange, size: 26),
                onPressed: () => ProductService.editProduct(context, product),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.systemRed, size: 26),
                onPressed: () => ProductService.deleteProduct(context, product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
