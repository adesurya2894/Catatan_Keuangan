import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_appbar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _showChangePasswordDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHashedPassword = prefs.getString('registered_password') ?? '';
    final userId = prefs.getString('user_id') ?? ''; // ✅ FIX
    final email = prefs.getString('registered_email') ?? '';

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Konfirmasi Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = hashPassword(oldPasswordController.text.trim());
              final newPass = newPasswordController.text.trim();
              final confirmPass = confirmPasswordController.text.trim();

              if (oldPass != storedHashedPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password lama tidak sesuai')),
                );
                return;
              }

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Konfirmasi password tidak cocok')),
                );
                return;
              }

              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password minimal 6 karakter')),
                );
                return;
              }

              final oldUser = await UserService.getUserByEmail(email);
              if (oldUser == null) return;

              final updated = await UserService.updateUser(
                userId,
                oldUser.copyWith(password: hashPassword(newPass)), // ✅ FIX
              );

              if (updated) {
                await prefs.clear(); // keluar dari sesi login lama
                if (context.mounted) {
                  Navigator.pop(context); // tutup dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Password Diubah'),
                      content: const Text(
                          'Password Anda telah berhasil diubah. Silakan login kembali.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // tutup dialog
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal mengubah password')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('registered_email') ?? '';
    final userId = prefs.getString('user_id') ?? '';
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Akun'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ketik email Anda untuk menghapus akun ini.'),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                if (emailController.text.trim() == storedEmail &&
                    userId.isNotEmpty) {
                  final success = await UserService.deleteUser(userId);
                  if (success) {
                    await prefs.clear();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Akun Dihapus'),
                          content:
                              const Text('Akun Anda telah berhasil dihapus.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menghapus akun.')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email tidak cocok.')),
                  );
                }
              },
              child: const Text('Hapus Akun'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Pengaturan'),
      drawer: const CustomDrawer(),
      body: ListView(
        children: [
          const ListTile(
            title:
                Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profil'),
            onTap: () => Navigator.pushNamed(context, '/profil'),
          ),
          const Divider(),
          const ListTile(
            title:
                Text('Keamanan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ubah Password'),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(),
          const ListTile(
            title: Text('Preferensi',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              final isDark = themeNotifier.themeMode == ThemeMode.dark;
              return ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Tema'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeNotifier.toggleTheme(value);
                  },
                ),
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Privasi & Akun',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Hapus Akun'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
          const Divider(),
          const ListTile(
            title:
                Text('Tentang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang Aplikasi'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Aplikasi Catatan Keuangan',
                applicationVersion: 'v1.0.0',
                applicationLegalese: '© 2025 By Ade Suryadi',
              );
            },
          ),
        ],
      ),
    );
  }
}
