import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catatan_keuangan/services/user_service.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  void _login() async {
    final emailInput = _emailController.text.trim();
    final passwordInput = _passwordController.text;

    if (!emailInput.contains('@')) {
      setState(() => _errorMessage = 'Format email tidak valid!');
      return;
    }
    if (passwordInput.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter!');
      return;
    }

    try {
      final user = await UserService.getUserByEmail(emailInput);
      final hashedInput = hashPassword(passwordInput);

      if (user != null && user.password == hashedInput) {
        if (user.status != 'aktif') {
          setState(() => _errorMessage = 'Akun Anda belum aktif.');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', user.id!);
        await prefs.setString('registered_name', user.name);
        await prefs.setString('registered_email', user.email);
        await prefs.setString('registered_phone', user.phone);
        await prefs.setString('profile_image', user.avatar ?? '');
        await prefs.setString('registered_password', user.password);

        _emailController.clear();
        _passwordController.clear();
        setState(() => _errorMessage = null);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Email atau password salah!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Email', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text('Password', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Masukkan password',
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
