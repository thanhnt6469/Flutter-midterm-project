import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService{
  static CollectionReference get _productsCollection =>
      FirebaseFirestore.instance.collection('products');

  static Future<FirebaseApp> _initializeFirebase2() async {
    return await Firebase.initializeApp(
      name: "Firebase2",
      options: FirebaseOptions(
        apiKey: "AIzaSyABJv7San6Prrel8YB0z5wbVCmKPmgOM3k",
        appId: "1:758763062278:android:8323725b8be04f69182f87",
        messagingSenderId: "758763062278",
        projectId: "findhomeapp-f35c6",
        storageBucket: "findhomeapp-f35c6.appspot.com",
      ),
    );
  }

  static Future<String?> _uploadImageToFirebase2(File imageFile) async {
    try {
      FirebaseApp app = await _initializeFirebase2();
      FirebaseStorage storage = FirebaseStorage.instanceFor(app: app);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child("$fileName.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      return null;
    }
  }

  static Stream<QuerySnapshot> getProductsStream() {
    return _productsCollection.snapshots();
  }

  static Future<void> addProduct(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _categoryController = TextEditingController();
    final _priceController = TextEditingController();
    final _imageController = TextEditingController();

    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Thêm Sản Phẩm Mới'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Tên sản phẩm',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _categoryController,
                    placeholder: 'Loại sản phẩm',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    placeholder: 'Giá',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _imageController,
                          placeholder: 'Hình ảnh (url/tùy chọn)',
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            border: Border.all(color: CupertinoColors.lightBackgroundGray),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          style: const TextStyle(color: CupertinoColors.label),
                        ),
                      ),
                      CupertinoButton(
                        child: const Icon(CupertinoIcons.arrow_up_doc),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null) {
                            File file = File(result.files.single.path!);
                            String? downloadUrl = await _uploadImageToFirebase2(file);
                            if (downloadUrl != null) {
                              _imageController.text = downloadUrl;
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      CupertinoButton(
                        child: const Text('Hủy', style: TextStyle(color: CupertinoColors.systemGrey)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton.filled(
                        child: const Text('Thêm'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              DocumentReference newProduct = await _productsCollection.add({
                                'idsanpham': '',
                                'tensanpham': _nameController.text,
                                'loaisp': _categoryController.text,
                                'gia': double.parse(_priceController.text),
                                'hinhanh': _imageController.text.trim(),
                              });
                              await newProduct.update({'idsanpham': newProduct.id});
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                    CupertinoAlertDialog(
                                      title: const Text("Thông báo"),
                                      content: const Text(
                                          "Sản phẩm đã được thêm thành công!"),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(
                                                context, rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                      ],
                                    ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                    CupertinoAlertDialog(
                                      title: const Text("Thông báo"),
                                      content: Text("Lỗi khi thêm sản phẩm: $e"),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(
                                                context, rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                      ],
                                    ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> editProduct(BuildContext context, DocumentSnapshot product) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product['tensanpham']);
    final _categoryController = TextEditingController(text: product['loaisp']);
    final _priceController = TextEditingController(text: product['gia'].toString());
    final _imageController = TextEditingController(text: product['hinhanh'] ?? '');

    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Chỉnh Sửa Sản Phẩm'),
          content: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Tên sản phẩm',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _categoryController,
                    placeholder: 'Loại sản phẩm',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    placeholder: 'Giá',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: CupertinoColors.lightBackgroundGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: const TextStyle(color: CupertinoColors.label),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _imageController,
                          placeholder: 'Hình ảnh (url/tùy chọn)',
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            border: Border.all(color: CupertinoColors.lightBackgroundGray),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          style: const TextStyle(color: CupertinoColors.label),
                        ),
                      ),
                      CupertinoButton(
                        child: const Icon(CupertinoIcons.arrow_up_doc),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null) {
                            File file = File(result.files.single.path!);
                            String? downloadUrl = await _uploadImageToFirebase2(file);
                            if (downloadUrl != null) {
                              _imageController.text = downloadUrl;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      CupertinoButton(
                        child: const Text('Hủy', style: TextStyle(color: CupertinoColors.systemGrey)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton.filled(
                        child: const Text('Lưu'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await _productsCollection.doc(product.id).update({
                                'tensanpham': _nameController.text,
                                'loaisp': _categoryController.text,
                                'gia': double.parse(_priceController.text),
                                'hinhanh': _imageController.text.trim(),
                              });
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                      CupertinoAlertDialog(
                                        title: const Text("Thông báo"),
                                        content: const Text(
                                            "Sản phẩm đã được cập nhật thành công!"),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(
                                                  context, rootNavigator: true)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                      CupertinoAlertDialog(
                                        title: const Text("Thông báo"),
                                        content: Text(
                                            "Lỗi khi cập nhật sản phẩm: $e"),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(
                                                  context, rootNavigator: true)
                                                  .pop();
                                            },
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> deleteProduct(BuildContext context, String productId) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Hủy', style: TextStyle(color: CupertinoColors.systemGrey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Xóa'),
              onPressed: () async {
                try {
                  await _productsCollection.doc(productId).delete();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();

                    showCupertinoDialog(
                      context: context,
                      builder: (context) =>
                          CupertinoAlertDialog(
                            title: const Text("Thông báo"),
                            content: const Text(
                                "Sản phẩm đã được xóa thành công!"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            ],
                          ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    showCupertinoDialog(
                      context: context,
                      builder: (context) =>
                          CupertinoAlertDialog(
                            title: const Text("Lỗi"),
                            content: Text("Lỗi khi xóa sản phẩm: $e"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            ],
                          ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
