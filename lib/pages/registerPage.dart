import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ email và mật khẩu.");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog("Mật khẩu phải có ít nhất 6 ký tự.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Mật khẩu nhập lại không khớp.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog("Đăng ký thất bại: ${e.toString()}");
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Lỗi"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Thành công"),
        content: const Text("Đăng ký thành công!"),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Đăng ký', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("images/person_&_dog.png"),
                      const SizedBox(height: 30),
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Icon(CupertinoIcons.person_fill, color: CupertinoColors.secondaryLabel),
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: CupertinoColors.lightBackgroundGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Mật khẩu',
                        obscureText: true,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Icon(CupertinoIcons.lock_fill, color: CupertinoColors.secondaryLabel),
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: CupertinoColors.lightBackgroundGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _confirmPasswordController,
                        placeholder: 'Nhập lại mật khẩu',
                        obscureText: true,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Icon(CupertinoIcons.lock_fill, color: CupertinoColors.secondaryLabel),
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: CupertinoColors.lightBackgroundGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSubmitted: (_) => _register(),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: CupertinoColors.systemRed),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text('Đăng ký'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton(
                        child: const Text('Đã có tài khoản? Đăng nhập ngay!'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const LoginPage()
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}