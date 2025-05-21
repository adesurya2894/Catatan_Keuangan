import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:catatan_keuangan/pages/login_page.dart';
import 'package:catatan_keuangan/pages/home_page.dart';
import 'package:catatan_keuangan/pages/riwayat_page.dart';
import 'package:catatan_keuangan/pages/profil_page.dart';
import 'package:catatan_keuangan/pages/setting_page.dart';
import 'package:catatan_keuangan/providers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // ✅ Inisialisasi theme dinamis
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier =
        Provider.of<ThemeNotifier>(context); // ✅ Dapatkan tema

    return MaterialApp(
      title: 'Catatan Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
      ),
      themeMode: themeNotifier.themeMode, // ✅ Terapkan mode tema
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/profil': (context) => const ProfilPage(),
        '/setting': (context) => const SettingPage(),
      },
    );
  }
}
