import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testt/pages/loginPage.dart';
import 'package:testt/services/productService.dart';
import '../widgets/productCard.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('products');
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.logout, size: 27, color: CupertinoColors.activeBlue),
          onPressed: () => _logout(context),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, size: 28),
          onPressed: () => ProductService.addProduct(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CupertinoTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: 'Tìm kiếm sản phẩm...',
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.search),
                  onPressed: () {
                    _searchFocusNode.requestFocus();
                  },
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _productsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  final filteredProducts = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['tensanpham'].toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text('Không tìm thấy sản phẩm.'));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: ListView(
                      children: filteredProducts.map((doc) => ProductCard(product: doc)).toList(),
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}