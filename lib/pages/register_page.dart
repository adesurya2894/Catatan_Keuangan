import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Semua kolom wajib diisi!';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Format email tidak valid!';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password minimal 6 karakter!';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Password tidak cocok!';
      });
      return;
    }

    try {
      const defaultAvatarUrl = 'https://i.pravatar.cc/150?img=10';

      final newUser = UserModel(
        name: name,
        email: email,
        phone: phone,
        password: hashPassword(password),
        status: 'aktif',
        dateCreated: DateTime.now().toIso8601String(),
        avatar: defaultAvatarUrl,
      );

      await UserService.registerUser(newUser);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Berhasil!'),
          content: const Text('Pendaftaran berhasil. Silakan login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal daftar. Coba lagi nanti.';
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
              const Center(
                child: Text(
                  'REGISTER',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nama Lengkap', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _nameController,
                decoration:
                    const InputDecoration(hintText: 'Masukkan nama lengkap'),
              ),
              const SizedBox(height: 20),
              const Text('Nomor HP', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(hintText: 'Masukkan nomor HP'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Text('Email', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Masukkan email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text('Password', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: 'Masukkan password'),
              ),
              const SizedBox(height: 20),
              const Text('Konfirmasi Password', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Ulangi password'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Sudah punya akun? Login di sini'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
