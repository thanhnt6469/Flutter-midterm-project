import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:testt/pages/productListPage.dart';
import 'package:testt/pages/registerPage.dart';
import '../main.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Vui lòng nhập đầy đủ email và mật khẩu.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const ProductListScreen()),
      );
    } catch (e) {
      _showErrorDialog("Đăng nhập thất bại: ${e.toString()}");
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Image.asset("images/person_on_rocket.png"),
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
                        onSubmitted: (_) => _login(),
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
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton(
                        child: const Text('Chưa có tài khoản? Đăng ký ngay!'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const RegisterPage()),
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